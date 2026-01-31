import Foundation

/// Interface for RSVP persistence.
protocol RSVPService {
    func fetchRSVP(eventId: String, userId: String) async throws -> RSVP?
    func submitRSVP(eventId: String, userId: String, roleId: String?, consent: ConsentSnapshot) async throws -> RSVP
    func cancelRSVP(eventId: String, userId: String) async throws -> RSVP
}
