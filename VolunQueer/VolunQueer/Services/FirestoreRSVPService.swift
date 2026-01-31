import Foundation

/// Firestore-backed RSVP service.
final class FirestoreRSVPService: RSVPService {
    private let client: FirestoreClient

    init(client: FirestoreClient) {
        self.client = client
    }

    func fetchRSVP(eventId: String, userId: String) async throws -> RSVP? {
        try await client.fetchDocument("events/\(eventId)/rsvps", id: userId, as: RSVP.self)
    }

    func submitRSVP(eventId: String, userId: String, roleId: String?, consent: ConsentSnapshot) async throws -> RSVP {
        let now = Date()
        let existing = try await fetchRSVP(eventId: eventId, userId: userId)
        let rsvp = RSVP(
            id: userId,
            userId: userId,
            roleId: roleId,
            status: .rsvp,
            consent: consent,
            answers: nil,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now
        )
        try await client.setDocument("events/\(eventId)/rsvps", id: userId, value: rsvp)
        return rsvp
    }

    func cancelRSVP(eventId: String, userId: String) async throws -> RSVP {
        let now = Date()
        let existing = try await fetchRSVP(eventId: eventId, userId: userId)
        let rsvp = RSVP(
            id: userId,
            userId: userId,
            roleId: existing?.roleId,
            status: .cancelled,
            consent: existing?.consent ?? ConsentSnapshot(shareEmail: false, sharePhone: false, sharePronouns: true, shareAccessibility: true),
            answers: existing?.answers,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now
        )
        try await client.setDocument("events/\(eventId)/rsvps", id: userId, value: rsvp)
        return rsvp
    }
}
