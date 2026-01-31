import SwiftUI

/// Tab wrapper for profile viewing and editing.
struct ProfileTabView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var authStore: AuthStore

    let userId: String

    var body: some View {
        NavigationStack {
            ProfileView(userId: userId)
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
