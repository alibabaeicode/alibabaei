import SwiftUI

/// The app's root surface.
///
/// For now it opens straight into **Settle**, the first stage of a Moment.
/// The later stages (Name, Note) and Home will route through here as they're
/// built; until Name exists, continuing simply begins a fresh breath.
struct RootView: View {
    @State private var sessionID = UUID()

    var body: some View {
        SettleView(onContinue: { sessionID = UUID() })
            .id(sessionID)
    }
}

#Preview {
    RootView()
}
