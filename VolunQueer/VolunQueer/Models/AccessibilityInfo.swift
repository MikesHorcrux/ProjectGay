import Foundation

/// Accessibility notes and tags for an event.
struct AccessibilityInfo: Codable, Hashable {
    var notes: String?
    var tags: [String]?
}
