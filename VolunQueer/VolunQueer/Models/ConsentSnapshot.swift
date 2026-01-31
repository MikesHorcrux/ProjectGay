import Foundation

/// Snapshot of consent flags at RSVP time.
struct ConsentSnapshot: Codable, Hashable {
    var shareEmail: Bool
    var sharePhone: Bool
    var sharePronouns: Bool
    var shareAccessibility: Bool
}
