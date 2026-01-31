import Foundation
import Combine

/// Loads RSVP statuses for the current user across events.
@MainActor
final class EventRSVPStatusViewModel: ObservableObject {
    @Published private(set) var statuses: [String: RSVPStatus] = [:]
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let userId: String
    private let service: RSVPService

    init(userId: String, service: RSVPService) {
        self.userId = userId
        self.service = service
    }

    /// Loads RSVP statuses for the provided events.
    func load(events: [Event]) async {
        guard !events.isEmpty else {
            statuses = [:]
            errorMessage = nil
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let rsvps = try await service.fetchRsvps(for: userId)
            let eventIds = Set(events.map { $0.id })
            var map: [String: RSVPStatus] = [:]
            for rsvp in rsvps {
                guard let eventId = rsvp.eventId, eventIds.contains(eventId) else { continue }
                guard rsvp.status != .cancelled else { continue }
                map[eventId] = rsvp.status
            }
            statuses = map
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
