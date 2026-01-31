import SwiftUI
import FirebaseCore
import FirebaseFirestore

/// Application entry point for VolunQueer.
@main
struct VolunQueerApp: App {
    @StateObject private var store: AppStore

    /// Configures Firebase when needed and initializes the shared store.
    init() {
        let dataSource = AppConfiguration.dataSource
        if dataSource == .firestore {
            FirebaseApp.configure()
            _ = Firestore.firestore()
        }

        _store = StateObject(
            wrappedValue: AppStore(
                dataSource: dataSource,
                preload: dataSource == .mock
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .task {
                    if AppConfiguration.seedOnLaunch, store.dataSource == .firestore {
                        await store.seedMockData()
                    }
                }
        }
    }
}
