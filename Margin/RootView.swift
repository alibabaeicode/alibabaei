import SwiftUI

/// The app's root surface. Intentionally empty for now — the skeleton runs,
/// and real screens (the Moment loop, Home, etc.) settle in here later.
struct RootView: View {
    var body: some View {
        Color(.systemBackground)
            .ignoresSafeArea()
    }
}

#Preview {
    RootView()
}
