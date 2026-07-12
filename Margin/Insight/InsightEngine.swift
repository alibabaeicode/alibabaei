import Foundation

/// A single honest line to show, and which rule produced it (for debugging).
struct Insight: Equatable {
    let text: String
    let ruleID: String
}

/// **The Insight Engine** (CLAUDE.md §5) — deterministic, on-device, no LLM.
///
/// Two hard guardrails govern everything here:
/// 1. **Mirror, not judge.** Lines state a pattern in plain, balanced language.
///    Never interpret, diagnose, evaluate, or prescribe.
/// 2. **Never invent.** A pattern is shown only when it is *literally true* of
///    the data and clears a sufficiency gate. If nothing true can be said, we
///    say a plain, honest non-pattern line (or, when empty, nothing).
///
/// Rules read only structured fields — timestamp, band, bodyLocation. The
/// free-text **note is never read**, by a model or by these rules (§2).
enum InsightEngine {

    /// The standing line for Home. Returns `nil` only when there are no Moments.
    static func standingInsight(for moments: [Moment], now: Date = .now) -> Insight? {
        guard !moments.isEmpty else { return nil }

        let calendar = Calendar.current

        // Pattern rules only ever see the recent window…
        let cutoff = calendar.date(
            byAdding: .day, value: -InsightConfig.standingWindowDays, to: now
        ) ?? .distantPast
        let windowStats = InsightStats(moments.filter { $0.timestamp >= cutoff })

        // …and only run once there is genuinely enough data, across enough days.
        if windowStats.total >= InsightConfig.minMomentsForPattern,
           windowStats.distinctDays >= InsightConfig.minDistinctDaysForPattern {
            for rule in patternRules {
                if let text = rule.evaluate(windowStats) {
                    return report(Insight(text: text, ruleID: rule.id))
                }
            }
        }

        // Nothing literally true to claim → an honest, non-pattern line,
        // judged over everything recorded so far. This covers cold start.
        let overall = InsightStats(moments)
        return report(fallback(total: overall.total, distinctDays: overall.distinctDays))
    }

    // MARK: - Rules (small, genuinely-true, valence-balanced)

    private static let patternRules: [InsightRule] = [timeOfDayRule, balanceRule]

    /// A band's moments concentrate in one part of the day — but only when the
    /// data actually spans more than one part. Symmetric across all bands.
    private static let timeOfDayRule = InsightRule(id: "time-of-day") { stats in
        guard stats.coveredParts.count >= InsightConfig.minCoveredPartsForTimeRule else { return nil }

        var best: (band: Band, part: PartOfDay, share: Double)?
        for (band, count) in stats.bandCounts where count >= InsightConfig.minBandCountForTimeRule {
            guard let (part, partCount) = stats.bandByPart[band]?.max(by: { $0.value < $1.value })
            else { continue }
            let share = Double(partCount) / Double(count)
            guard share >= InsightConfig.timeConcentration else { continue }
            if best == nil || share > best!.share {
                best = (band, part, share)
            }
        }

        guard let hit = best else { return nil }
        return "Your \(hit.band.plainDescriptor) moments tend to gather in the \(hit.part.phrase)."
    }

    /// One band clearly outweighs the next, both directions equally native.
    private static let balanceRule = InsightRule(id: "balance") { stats in
        let ranked = stats.bandCounts.sorted { $0.value > $1.value }
        guard ranked.count >= 2 else { return nil }
        let top = ranked[0], second = ranked[1]
        guard second.value >= InsightConfig.minSecondBandForBalance else { return nil }
        guard Double(top.value) >= InsightConfig.balanceMargin * Double(second.value) else { return nil }
        return "More \(top.key.balanceNoun) than \(second.key.balanceNoun), these last few days."
    }

    // MARK: - Fallback (no pattern — never invents one)

    private static func fallback(total: Int, distinctDays: Int) -> Insight {
        if total <= InsightConfig.coldStartThreshold || distinctDays <= 1 {
            // Reflect the act of pausing, not who someone is (cold start, §5).
            return Insight(
                text: "The map starts here — these first marks are yours.",
                ruleID: "cold-start"
            )
        }
        return Insight(
            text: "No strong pattern yet — just your days, as they are.",
            ruleID: "quiet"
        )
    }

    // MARK: - Debug

    /// Makes it easy to see which rule fired, in Debug builds only.
    private static func report(_ insight: Insight) -> Insight {
        #if DEBUG
        print("Insight ▶ [\(insight.ruleID)] \(insight.text)")
        #endif
        return insight
    }
}

// MARK: - Rule

/// A rule: an id, and an evaluation that returns copy **only when its trigger
/// is literally true**, otherwise `nil`. Sufficiency gates live in the engine
/// (before rules run) and inside each rule; a cooldown for *repeated delivery*
/// belongs to the future notification layer (§5) — the standing line itself
/// doesn't churn because it is a pure function of the data.
private struct InsightRule {
    let id: String
    let evaluate: (InsightStats) -> String?
}

// MARK: - Stats

/// Structured aggregates over a set of Moments. The note is never touched.
private struct InsightStats {
    let total: Int
    let distinctDays: Int
    /// Counts per band; nil-band Moments (written-in words) are excluded from
    /// band-specific rules but still counted in `total`/`distinctDays` (§3).
    let bandCounts: [Band: Int]
    let coveredParts: Set<PartOfDay>
    let bandByPart: [Band: [PartOfDay: Int]]

    init(_ moments: [Moment], calendar: Calendar = .current) {
        var days = Set<Date>()
        var bandCounts: [Band: Int] = [:]
        var covered = Set<PartOfDay>()
        var bandByPart: [Band: [PartOfDay: Int]] = [:]

        for moment in moments {
            days.insert(calendar.startOfDay(for: moment.timestamp))
            let part = PartOfDay(hour: calendar.component(.hour, from: moment.timestamp))
            covered.insert(part)
            if let band = moment.band {
                bandCounts[band, default: 0] += 1
                bandByPart[band, default: [:]][part, default: 0] += 1
            }
        }

        self.total = moments.count
        self.distinctDays = days.count
        self.bandCounts = bandCounts
        self.coveredParts = covered
        self.bandByPart = bandByPart
    }
}

// MARK: - Part of day

private enum PartOfDay: CaseIterable {
    case morning, afternoon, evening, night

    init(hour: Int) {
        switch hour {
        case 5..<12:  self = .morning
        case 12..<17: self = .afternoon
        case 17..<22: self = .evening
        default:      self = .night
        }
    }

    var phrase: String {
        switch self {
        case .morning:   "morning"
        case .afternoon: "afternoon"
        case .evening:   "evening"
        case .night:     "night"
        }
    }
}

// MARK: - Band copy (plain, non-judgmental)

private extension Band {
    /// Plain descriptor for a moment's tone — energy, never good/bad.
    var plainDescriptor: String {
        switch self {
        case .activated: "charged"
        case .weighted:  "heavy"
        case .settled:   "settled"
        }
    }

    /// Noun form for the balance line ("more ease than weight").
    var balanceNoun: String {
        switch self {
        case .activated: "charge"
        case .weighted:  "weight"
        case .settled:   "ease"
        }
    }
}
