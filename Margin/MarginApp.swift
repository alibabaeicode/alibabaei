import SwiftUI
import SwiftData

@main
struct MarginApp: App {
    /// On-device only: local SwiftData store, **no CloudKit, no sync, no
    /// network**. A locked privacy decision — data never leaves the phone
    /// (CLAUDE.md §1, §2).
    let container: ModelContainer = {
        let schema = Schema([Moment.self])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create the on-device store: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
