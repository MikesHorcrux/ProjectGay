import Foundation

/// Lifecycle status for an event.
enum EventStatus: String, Codable, Hashable {
    case draft
    case published
    case cancelled
    case archived
}
