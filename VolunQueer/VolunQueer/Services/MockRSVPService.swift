import Foundation

/// In-memory RSVP service for mock data and previews.
actor MockRSVPService: RSVPService {
    private var rsvpsByEvent: [String: [String: RSVP]]

    init(seed: MockDataBundle = MockData.bundle) {
        var table: [String: [String: RSVP]] = [:]
        for (eventId, rsvps) in seed.rsvpsByEvent {
            var perUser: [String: RSVP] = [:]
            for rsvp in rsvps {
                perUser[rsvp.userId] = rsvp
            }
            table[eventId] = perUser
        }
        rsvpsByEvent = table
    }

    func fetchRSVP(eventId: String, userId: String) async throws -> RSVP? {
        rsvpsByEvent[eventId]?[userId]
    }

    func submitRSVP(eventId: String, userId: String, roleId: String?, consent: ConsentSnapshot) async throws -> RSVP {
        let now = Date()
        let existing = rsvpsByEvent[eventId]?[userId]
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
        var eventTable = rsvpsByEvent[eventId] ?? [:]
        eventTable[userId] = rsvp
        rsvpsByEvent[eventId] = eventTable
        return rsvp
    }

    func cancelRSVP(eventId: String, userId: String) async throws -> RSVP {
        let now = Date()
        let existing = rsvpsByEvent[eventId]?[userId]
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
        var eventTable = rsvpsByEvent[eventId] ?? [:]
        eventTable[userId] = rsvp
        rsvpsByEvent[eventId] = eventTable
        return rsvp
    }
}
