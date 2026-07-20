import SwiftUI
import SwiftData

/// **Archive — "Where you've been"** (CLAUDE.md §6.6). A calm record of past
/// Moments, grouped by day, newest first. It's for the person to revisit their
/// own moments — not a report to be assessed by.
///
/// No scores, streaks, counts, averages, charts, or trends. No judgment or
/// ranking: band dots are a quiet tone cue, never good/bad; days are never
/// highlighted as better or worse. No insights or pattern claims here — Archive
/// shows what happened, nothing more.
struct ArchiveView: View {

    /// A calm way back to Home.
    var onBack: () -> Void = {}

    @Query(sort: \Moment.timestamp, order: .reverse) private var moments: [Moment]

    var body: some View {
        ZStack {
            PaperBackground()

            VStack(alignment: .leading, spacing: 0) {
                header
                if moments.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Button(action: onBack) {
                Text("‹  home")
                    .font(Theme.Font.mono(12, relativeTo: .footnote))
                    .tracking(1)
                    .foregroundStyle(Theme.Color.ink.opacity(0.5))
            }
            .buttonStyle(.plain)

            Text("Where you've been")
                .font(Theme.Font.serif(23, relativeTo: .title2))
                .foregroundStyle(Theme.Color.ink.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.top, Theme.Spacing.xl)
        .padding(.bottom, Theme.Spacing.lg)
    }

    // MARK: - Empty

    /// Consistent with Home's restraint: one quiet line, no call to action.
    private var emptyState: some View {
        VStack(alignment: .leading) {
            Text("Where you've been will gather here.")
                .font(Theme.Font.serif(20, relativeTo: .title3))
                .foregroundStyle(Theme.Color.ink.opacity(0.6))
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.xl)
        .padding(.top, Theme.Spacing.lg)
    }

    // MARK: - List

    private var list: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxl) {
                ForEach(days) { group in
                    daySection(group)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Theme.Spacing.xl)
            .padding(.top, Theme.Spacing.xs)
            .padding(.bottom, Theme.Spacing.xxxl)
        }
    }

    private func daySection(_ group: DayGroup) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            Text(dayLabel(group.day))
                .font(Theme.Font.mono(11, relativeTo: .caption2))
                .tracking(1)
                .foregroundStyle(Theme.Color.ink.opacity(0.4))

            ForEach(group.items) { moment in
                momentRow(moment)
            }
        }
    }

    private func momentRow(_ moment: Moment) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Circle()
                .fill(moment.band?.tone ?? Theme.Color.neutral)
                .frame(width: 8, height: 8)
                .padding(.top, 7) // aligns the dot with the word's line

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(moment.word)
                    .font(Theme.Font.serif(18, relativeTo: .body))
                    .foregroundStyle(Theme.Color.ink.opacity(0.85))

                Text(meta(for: moment))
                    .font(Theme.Font.mono(11, relativeTo: .caption2))
                    .tracking(0.5)
                    .foregroundStyle(Theme.Color.ink.opacity(0.4))

                // The note the person wrote for themselves — shown quietly.
                if let note = moment.note, !note.isEmpty {
                    Text(note)
                        .font(Theme.Font.serif(15, relativeTo: .subheadline))
                        .foregroundStyle(Theme.Color.ink.opacity(0.55))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Theme.Spacing.xxs)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Grouping

    private struct DayGroup: Identifiable {
        let day: Date
        let items: [Moment]
        var id: Date { day }
    }

    /// Moments grouped by calendar day, newest day first, newest within a day
    /// first. Purely chronological — never sorted or ranked by band or valence.
    private var days: [DayGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: moments) { calendar.startOfDay(for: $0.timestamp) }
        return grouped.keys.sorted(by: >).map { day in
            DayGroup(day: day, items: grouped[day]!.sorted { $0.timestamp > $1.timestamp })
        }
    }

    // MARK: - Labels

    /// A gentle day label: "Today", "Yesterday", a weekday, else a soft date.
    private func dayLabel(_ date: Date, now: Date = .now) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let days = calendar.dateComponents(
            [.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: now)
        ).day ?? 0
        if days < 7 { return date.formatted(.dateTime.weekday(.wide)) }
        return date.formatted(.dateTime.month(.wide).day())
    }

    /// A gentle sense of time within the day (+ optional body) — never a clock
    /// score, never a count.
    private func meta(for moment: Moment) -> String {
        var parts = [timeOfDay(moment.timestamp)]
        if let body = moment.bodyLocation { parts.append(body) }
        return parts.joined(separator: " · ")
    }

    private func timeOfDay(_ date: Date) -> String {
        switch Calendar.current.component(.hour, from: date) {
        case 5..<12:  return "morning"
        case 12..<17: return "afternoon"
        case 17..<22: return "evening"
        default:      return "night"
        }
    }
}

#Preview {
    ArchiveView()
        .modelContainer(for: Moment.self, inMemory: true)
}
