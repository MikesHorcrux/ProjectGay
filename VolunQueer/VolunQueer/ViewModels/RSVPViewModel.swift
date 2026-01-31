import Foundation
import Combine

/// View model for RSVP actions on an event.
@MainActor
final class RSVPViewModel: ObservableObject {
    @Published private(set) var status: RSVPStatus?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var selectedRoleId: String?
    @Published var consent: ConsentSnapshot

    private let eventId: String
    private let userId: String
    private let service: RSVPService

    init(eventId: String, userId: String, roles: [EventRole], service: RSVPService) {
        self.eventId = eventId
        self.userId = userId
        self.service = service
        self.selectedRoleId = roles.first?.id
        self.consent = ConsentSnapshot(
            shareEmail: false,
            sharePhone: false,
            sharePronouns: true,
            shareAccessibility: true
        )
    }

    /// Loads the current RSVP state for this event.
    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let rsvp = try await service.fetchRSVP(eventId: eventId, userId: userId)
            status = rsvp?.status
            selectedRoleId = rsvp?.roleId ?? selectedRoleId
            consent = rsvp?.consent ?? consent
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Toggles between RSVP and cancelled states.
    func toggleRSVP() async {
        isLoading = true
        errorMessage = nil
        do {
            if status == .rsvp {
                let rsvp = try await service.cancelRSVP(eventId: eventId, userId: userId)
                status = rsvp.status
            } else {
                let rsvp = try await service.submitRSVP(eventId: eventId, userId: userId, roleId: selectedRoleId, consent: consent)
                status = rsvp.status
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    var buttonTitle: String {
        status == .rsvp ? "Cancel RSVP" : "RSVP"
    }

    var helperText: String? {
        switch status {
        case .rsvp:
            return "You're RSVP'd"
        case .cancelled:
            return "RSVP cancelled"
        case .waitlisted:
            return "You're on the waitlist"
        default:
            return nil
        }
    }
}
