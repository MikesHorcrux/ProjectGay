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
            var results: [RSVPListRow] = []
            for event in events {
                let rsvp = try await service.fetchRSVP(eventId: event.id, userId: userId)
                guard let rsvp, rsvp.status != .cancelled else { continue }
                results.append(RSVPListRow(event: event, rsvp: rsvp))
            }

            rows = results.sorted { $0.event.startsAt < $1.event.startsAt }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
