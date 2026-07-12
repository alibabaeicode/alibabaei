import Foundation
import SwiftData

// TEMP: temporary persistence check — prints stored Moments to the Xcode
// console so we can confirm saving works before the Home/Archive screen
// exists. Remove this whole file (and its two call sites in RootView) once the
// real home screen can show saved Moments.
enum TEMP_MomentLog {

    /// Prints every Moment currently on the device (called on launch).
    static func dumpAll(_ context: ModelContext) {
        let descriptor = FetchDescriptor<Moment>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let moments = (try? context.fetch(descriptor)) ?? []
        print("TEMP ▶ \(moments.count) Moment(s) stored on this device:")
        for moment in moments {
            print("TEMP    • \(line(for: moment))")
        }
    }

    /// Prints a single Moment right after it's saved.
    static func logSaved(_ moment: Moment) {
        print("TEMP ▶ saved a Moment → \(line(for: moment))")
    }

    private static func line(for moment: Moment) -> String {
        let time = moment.timestamp.formatted(date: .abbreviated, time: .shortened)
        let band = moment.band?.rawValue ?? "nil"
        let body = moment.bodyLocation ?? "—"
        let note = moment.note ?? "—"
        return "\(time) — \"\(moment.word)\" [band: \(band)] body: \(body) note: \(note)"
    }
}
