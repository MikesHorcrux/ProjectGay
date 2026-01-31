import Foundation

/// Lifecycle status for a user account.
enum AccountStatus: String, Codable, Hashable {
    case active
    case suspended
    case archived
}
