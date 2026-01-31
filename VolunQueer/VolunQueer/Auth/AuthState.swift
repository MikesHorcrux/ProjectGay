import Foundation

/// Authentication state for the current session.
enum AuthState: Equatable {
    case signedOut
    case signedIn(userID: String)
    case loading
    case unavailable(String)
}
