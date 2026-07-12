import SwiftUI
import SwiftData

/// **Home — "You, lately"** (CLAUDE.md §6.6). This *is* the profile: no name,
/// no avatar, no account. The Field (the ink map) is the primary visual, with
/// a quiet thread of recent Moments beneath it.
///
/// No streaks, counts, scores, or goals. No valence coloring or ranking, no
/// implication of improvement or decline. The insight line isn't built yet —
/// its place is held below, empty, until the engine exists.
struct HomeView: View {

    /// A quiet, unobtrusive way to begin a new Moment.
    var onBegin: () -> Void = {}

    @Query(sort: \Moment.timestamp, order: .reverse) private var moments: [Moment]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            PaperBackground()

            if moments.isEmpty {
                emptyState
            } else {
                filledState
            }

            entryPoint
                .padding(.leading, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xl)
        }
    }

    // MARK: - Empty

    /// Day one. The locked copy, and nothing else — an invitation, not a defect.
    private var emptyState: some View {
        VStack(alignment: .leading) {
            Text("Your first moment settles here.")
                .font(Theme.Font.serif(23, relativeTo: .title2))
                .foregroundStyle(Theme.Color.ink.opacity(0.7))
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.top, Theme.Spacing.xxxl)
    }

    // MARK: - Filled

    private var filledState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Text("You, lately")
                    .font(Theme.Font.serif(20, relativeTo: .title3))
                    .foregroundStyle(Theme.Color.ink.opacity(0.5))

                // The standing insight (§5). Shown inline for now; the staged
                // reveal (insight first, then the Field) comes later.
                insightLine

                FieldView(moments: moments)

                recentThread
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.xxl)
            // Room so the entry point never covers the last row.
            .padding(.bottom, Theme.Spacing.xxxl + Theme.Spacing.xl)
        }
    }

    /// The standing insight, straight from the deterministic engine. If nothing
    /// is honestly true, it shows nothing — a quiet Home is correct.
    @ViewBuilder private var insightLine: some View {
        if let insight = InsightEngine.standingInsight(for: moments) {
            Text(insight.text)
                .font(Theme.Font.serif(20, relativeTo: .title3))
                .foregroundStyle(Theme.Color.ink.opacity(0.75))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// A calm, understated list of the most recent Moments — not a table.
    private var recentThread: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Text("recently")
                .font(Theme.Font.mono(11, relativeTo: .caption2))
                .tracking(1)
                .foregroundStyle(Theme.Color.ink.opacity(0.35))

            ForEach(moments.prefix(MomentConfig.homeRecentCount)) { moment in
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(moment.word)
                        .font(Theme.Font.serif(18, relativeTo: .body))
                        .foregroundStyle(Theme.Color.ink.opacity(0.85))
                    Text(meta(for: moment))
                        .font(Theme.Font.mono(11, relativeTo: .caption2))
                        .tracking(0.5)
                        .foregroundStyle(Theme.Color.ink.opacity(0.4))
                }
            }
        }
    }

    // MARK: - Entry point

    /// The quiet way in — a soft ink dot, not a loud button.
    private var entryPoint: some View {
        Button(action: onBegin) {
            HStack(spacing: Theme.Spacing.sm) {
                ZStack {
                    Circle()
                        .strokeBorder(Theme.Color.stoneFirm, lineWidth: 1)
                        .frame(width: 34, height: 34)
                    Circle()
                        .fill(Theme.Color.ink.opacity(0.55))
                        .frame(width: 7, height: 7)
                }
                Text("take a moment")
                    .font(Theme.Font.mono(12, relativeTo: .footnote))
                    .tracking(1)
                    .foregroundStyle(Theme.Color.ink.opacity(0.5))
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Meta

    /// "word + a soft sense of when" (+ optional body tag). Gentle, non-numeric,
    /// never a count or a score.
    private func meta(for moment: Moment) -> String {
        var parts = [softWhen(moment.timestamp)]
        if let body = moment.bodyLocation { parts.append(body) }
        return parts.joined(separator: " · ")
    }
}

/// A gentle, non-numeric sense of when a Moment happened.
private func softWhen(_ date: Date, now: Date = .now) -> String {
    let calendar = Calendar.current
    if calendar.isDateInToday(date) {
        switch calendar.component(.hour, from: date) {
        case 5..<12:  return "this morning"
        case 12..<17: return "this afternoon"
        case 17..<22: return "this evening"
        default:      return "tonight"
        }
    }
    if calendar.isDateInYesterday(date) { return "yesterday" }

    let start = calendar.startOfDay(for: date)
    let today = calendar.startOfDay(for: now)
    let days = calendar.dateComponents([.day], from: start, to: today).day ?? 0
    if days < 7  { return "earlier this week" }
    if days < 14 { return "last week" }
    return "a while ago"
}

#Preview {
    HomeView()
        .modelContainer(for: Moment.self, inMemory: true)
}
