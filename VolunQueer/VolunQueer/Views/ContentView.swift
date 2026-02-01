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
                contentForLoadedState
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
    private var contentForLoadedState: some View {
        if case .signedIn(let userId) = authStore.state {
            if OnboardingStatus.requiresOnboarding(for: store.user(for: userId)) {
                OnboardingFlowView(userId: userId)
            } else {
                tabView(userId: userId)
            }
        } else {
            ContentUnavailableView(
                "Sign in required",
                systemImage: "person.crop.circle.badge.exclam",
                description: Text("Sign in to view and manage your RSVPs.")
            )
        }
    }

    private func tabView(userId: String) -> some View {
        let user = store.user(for: userId)
        let isVolunteer = user?.roles.contains(.volunteer) ?? true
        let isOrganizer = user?.roles.contains(.organizer) ?? false

        return TabView {
            DiscoverTabView(userId: userId, service: store.rsvpService)
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }

            if isVolunteer {
                MyRSVPsTabView(userId: userId, service: store.rsvpService)
                    .tabItem {
                        Label("My RSVPs", systemImage: "checklist")
                    }
            }

            if isOrganizer {
                OrganizerTabView(userId: userId)
                    .tabItem {
                        Label("Manage", systemImage: "square.and.pencil")
                    }
            }

            ProfileTabView(userId: userId)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStore(dataSource: .mock, preload: true))
        .environmentObject(AuthStore(isConfigured: false))
}
