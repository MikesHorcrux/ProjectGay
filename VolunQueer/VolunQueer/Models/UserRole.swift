import Foundation

/// High-level roles for a user account.
enum UserRole: String, Codable, Hashable {
    case volunteer
    case organizer
    case programAdmin
}
