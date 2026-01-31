import Foundation

/// Types of notifications.
enum NotificationType: String, Codable, Hashable {
    case eventReminder
    case rsvpUpdate
    case orgMessage
    case system
}

// MARK: - Supporting Types
