import Foundation

/// Tunable constants for the Moment loop.
///
/// These are *hypotheses* (CLAUDE.md §8), not gospel — kept in one place so they
/// can be tested and flipped cheaply, never hard-scattered through views.
enum MomentConfig {

    /// How many slow exhales the Settle stage asks for.
    /// Hypothesis: **1** for now (§6.2). A single constant so it can be tested.
    static let breathCount = 1

    /// The length of one slow exhale. Unhurried on purpose.
    static let exhaleDuration: TimeInterval = 5

    /// A brief, calm beat before the breath begins.
    static let settleBeat: TimeInterval = 0.8
}
