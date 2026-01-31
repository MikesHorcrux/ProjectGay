import SwiftUI
import FirebaseCore
import FirebaseFirestore

/// Application entry point for VolunQueer.
@main
struct VolunQueerApp: App {
    @StateObject private var store: AppStore
    @StateObject private var authStore: AuthStore

    /// Configures Firebase when needed and initializes shared stores.
    init() {
        let isFirebaseConfigured = AppConfiguration.isFirebaseConfigured
        if isFirebaseConfigured {
            FirebaseApp.configure()
            _ = Firestore.firestore()
        }

        let dataSource = AppConfiguration.dataSource

        _store = StateObject(
            wrappedValue: AppStore(
                dataSource: dataSource,
                preload: dataSource == .mock
            )
        )
        _authStore = StateObject(wrappedValue: AuthStore(isConfigured: isFirebaseConfigured))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(authStore)
                .task {
                    if AppConfiguration.seedOnLaunch, store.dataSource == .firestore {
                        await store.seedMockData()
                    }
                }
        }
    }
}
