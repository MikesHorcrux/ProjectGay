import Foundation
import Combine

/// Loads RSVP entries for a specific event.
@MainActor
final class OrganizerRSVPListViewModel: ObservableObject {
    @Published private(set) var rsvps: [RSVP] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let eventId: String
    private let service: RSVPService

    init(eventId: String, service: RSVPService) {
        self.eventId = eventId
        self.service = service
    }

    /// Loads RSVPs for the event.
    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await service.fetchRsvps(eventId: eventId)
            rsvps = fetched.sorted { $0.createdAt < $1.createdAt }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
