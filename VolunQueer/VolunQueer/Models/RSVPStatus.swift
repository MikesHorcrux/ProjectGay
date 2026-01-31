import Foundation

/// State of an RSVP.
enum RSVPStatus: String, Codable, Hashable {
    case rsvp
    case waitlisted
    case cancelled
    case noShow
}
