import SwiftUI

/// Tab wrapper for the user's RSVP list.
struct MyRSVPsTabView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var authStore: AuthStore

    let userId: String
    let service: RSVPService

    var body: some View {
        NavigationStack {
            RSVPListView(userId: userId, service: service)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Reload") {
                            Task { await store.load() }
                        }
                    }

                    if store.dataSource == .firestore {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Seed Firestore") {
                                Task { await store.seedMockData() }
                            }
                        }
                    }

                    ToolbarItem(placement: .bottomBar) {
                        Button("Sign Out") {
                            authStore.signOut()
                        }
                    }
                }
        }
    }
}
