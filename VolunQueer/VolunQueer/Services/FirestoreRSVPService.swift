import Foundation
import FirebaseFirestore

/// Firestore-backed RSVP service.
final class FirestoreRSVPService: RSVPService {
    private let client: FirestoreClient

    init(client: FirestoreClient) {
        self.client = client
    }

    func fetchRSVP(eventId: String, userId: String) async throws -> RSVP? {
        if var rsvp = try await client.fetchDocument("events/\(eventId)/rsvps", id: userId, as: RSVP.self) {
            if rsvp.eventId == nil {
                rsvp.eventId = eventId
            }
            return rsvp
        }
        return nil
    }

    func fetchRsvps(for userId: String) async throws -> [RSVP] {
        try await withCheckedThrowingContinuation { continuation in
            Firestore.firestore()
                .collectionGroup("rsvps")
                .whereField("userId", isEqualTo: userId)
                .getDocuments { snapshot, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    let items: [RSVP] = snapshot?.documents.compactMap { document in
                        do {
                            var rsvp = try RSVP.fromFirestoreData(id: document.documentID, data: document.data())
                            if rsvp.eventId == nil {
                                rsvp.eventId = document.reference.parent.parent?.documentID
                            }
                            return rsvp
                        } catch {
                            return nil
                        }
                    } ?? []
                    continuation.resume(returning: items)
                }
        }
    }

    func fetchRsvps(eventId: String) async throws -> [RSVP] {
        let items = try await client.fetchCollection("events/\(eventId)/rsvps", as: RSVP.self)
        return items.map { rsvp in
            if rsvp.eventId == nil {
                var updated = rsvp
                updated.eventId = eventId
                return updated
            }
            return rsvp
        }
    }

    func submitRSVP(eventId: String, userId: String, roleId: String?, consent: ConsentSnapshot) async throws -> RSVP {
        let now = Date()
        let existing = try await fetchRSVP(eventId: eventId, userId: userId)
        let rsvp = RSVP(
            id: userId,
            userId: userId,
            eventId: eventId,
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
            eventId: eventId,
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
