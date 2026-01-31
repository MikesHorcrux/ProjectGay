import SwiftUI

/// Entry view that switches between auth and app content.
struct RootView: View {
    @EnvironmentObject private var authStore: AuthStore

    var body: some View {
        switch authStore.state {
        case .signedIn:
            ContentView()
        case .signedOut:
            AuthView()
        case .loading:
            ProgressView("Signing in...")
        case .unavailable(let reason):
            ContentUnavailableView(
                "Firebase unavailable",
                systemImage: "bolt.slash",
                description: Text(reason)
            )
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthStore(isConfigured: false))
        .environmentObject(AppStore(dataSource: .mock, preload: true))
}
