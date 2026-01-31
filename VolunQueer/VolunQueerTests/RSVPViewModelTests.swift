import Testing
@testable import VolunQueer

struct RSVPViewModelTests {
    @Test
    @MainActor
    func loadsExistingRsvp() async {
        let service = MockRSVPService(seed: MockData.bundle)
        let viewModel = RSVPViewModel(
            eventId: "event-coffee-hour",
            userId: "user-alex",
            roles: MockData.bundle.rolesByEvent["event-coffee-hour"] ?? [],
            service: service
        )

        await viewModel.load()

        #expect(viewModel.status == .rsvp)
        #expect(viewModel.selectedRoleId == "role-host")
    }

    @Test
    @MainActor
    func togglesRsvpForNewEvent() async {
        let service = MockRSVPService(seed: MockData.bundle)
        let viewModel = RSVPViewModel(
            eventId: "event-kits",
            userId: "user-alex",
            roles: MockData.bundle.rolesByEvent["event-kits"] ?? [],
            service: service
        )

        #expect(viewModel.status == nil)

        await viewModel.toggleRSVP()
        #expect(viewModel.status == .rsvp)

        await viewModel.toggleRSVP()
        #expect(viewModel.status == .cancelled)
    }
}
