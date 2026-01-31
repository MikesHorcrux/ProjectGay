import Foundation
import Combine

/// Loads RSVP rows for the current user across events.
@MainActor
final class RSVPListViewModel: ObservableObject {
    @Published private(set) var rows: [RSVPListRow] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let userId: String
    private let service: RSVPService

    init(userId: String, service: RSVPService) {
        self.userId = userId
        self.service = service
    }

    /// Loads RSVP rows for the provided events.
    func load(events: [Event]) async {
        guard !events.isEmpty else {
            rows = []
            errorMessage = nil
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let rsvps = try await service.fetchRsvps(for: userId)
            let eventsById = Dictionary(uniqueKeysWithValues: events.map { ($0.id, $0) })
            let filtered = rsvps.compactMap { rsvp -> RSVPListRow? in
                guard rsvp.status != .cancelled else { return nil }
                guard let eventId = rsvp.eventId, let event = eventsById[eventId] else { return nil }
                return RSVPListRow(event: event, rsvp: rsvp)
            }
            rows = filtered.sorted { $0.event.startsAt < $1.event.startsAt }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
