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
        if var rsvp = rsvpsByEvent[eventId]?[userId] {
            if rsvp.eventId == nil {
                rsvp.eventId = eventId
            }
            return rsvp
        }
        return nil
    }

    func fetchRsvps(for userId: String) async throws -> [RSVP] {
        var results: [RSVP] = []
        for (eventId, perUser) in rsvpsByEvent {
            if var rsvp = perUser[userId] {
                if rsvp.eventId == nil {
                    rsvp.eventId = eventId
                }
                results.append(rsvp)
            }
        }
        return results
    }

    func fetchRsvps(eventId: String) async throws -> [RSVP] {
        let rsvps = rsvpsByEvent[eventId].map { Array($0.values) } ?? []
        return rsvps.map { rsvp in
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
        let existing = rsvpsByEvent[eventId]?[userId]
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
            eventId: eventId,
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
