import SwiftUI

/// Root view: loads data, then shows volunteer discovery (event list → event detail).
struct ContentView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var authStore: AuthStore

    var body: some View {
        Group {
            switch store.loadState {
            case .idle:
                Color.clear
                    .onAppear {
                        Task { await store.load() }
                    }
            case .loading:
                ProgressView("Loading data...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.cream)
            case .loaded:
                tabView
            case .failed(let message):
                ContentUnavailableView(
                    "Unable to load data",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            }
        }
    }

    @ViewBuilder
    private var tabView: some View {
        if case .signedIn(let userId) = authStore.state {
            TabView {
                DiscoverTabView(userId: userId, service: store.rsvpService)
                    .tabItem {
                        Label("Discover", systemImage: "sparkles")
                    }

                MyRSVPsTabView(userId: userId, service: store.rsvpService)
                    .tabItem {
                        Label("My RSVPs", systemImage: "checklist")
                    }
            }
        } else {
            ContentUnavailableView(
                "Sign in required",
                systemImage: "person.crop.circle.badge.exclam",
                description: Text("Sign in to view and manage your RSVPs.")
            )
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStore(dataSource: .mock, preload: true))
        .environmentObject(AuthStore(isConfigured: false))
}
