import Foundation

/// Loading state for the app store.
enum AppStoreLoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}
