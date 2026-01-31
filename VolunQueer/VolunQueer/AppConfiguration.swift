import Foundation

/// Runtime configuration derived from environment variables.
struct AppConfiguration {
    /// Data source for the app store, driven by environment variables.
    static var dataSource: AppStoreDataSource {
        let value = ProcessInfo.processInfo.environment["VOLUNQUEER_DATA_SOURCE"]?.lowercased()
        switch value {
        case "firestore":
            return .firestore
        case "mock":
            return .mock
        default:
            return .mock
        }
    }

    /// Whether to seed Firestore on launch when enabled.
    static var seedOnLaunch: Bool {
        ProcessInfo.processInfo.environment["VOLUNQUEER_SEED"] == "1"
    }
}
