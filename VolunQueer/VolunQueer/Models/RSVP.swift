import Foundation

/// Volunteer RSVP for an event.
struct RSVP: Identifiable, Codable, Hashable, FirestoreDocument {
    var id: String
    var userId: String
    var eventId: String?
    var roleId: String?
    var status: RSVPStatus
    var consent: ConsentSnapshot
    var answers: [String: String]?
    var createdAt: Date
    var updatedAt: Date
}
