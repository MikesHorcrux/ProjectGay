import SwiftUI

/// Tab wrapper for organizer management (event list + creation).
struct OrganizerTabView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var authStore: AuthStore

    let userId: String

    @State private var isPresentingEditor = false

    var body: some View {
        NavigationStack {
            OrganizerEventListView(userId: userId)
                .navigationTitle("Manage")
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            isPresentingEditor = true
                        } label: {
                            Label("New Event", systemImage: "plus")
                        }

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
        .sheet(isPresented: $isPresentingEditor) {
            NavigationStack {
                EventEditorView(userId: userId)
            }
        }
    }
}

#Preview {
    OrganizerTabView(userId: "user-jules")
        .environmentObject(AppStore(dataSource: .mock, preload: true))
        .environmentObject(AuthStore(isConfigured: false))
}
