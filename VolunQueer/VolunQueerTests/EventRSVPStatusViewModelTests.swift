import Testing
@testable import VolunQueer

struct EventRSVPStatusViewModelTests {
    @Test
    @MainActor
    func loadsStatusesForUser() async {
        let service = MockRSVPService(seed: MockData.bundle)
        let viewModel = EventRSVPStatusViewModel(userId: "user-alex", service: service)

        await viewModel.load(events: MockData.bundle.events)

        #expect(viewModel.statuses["event-coffee-hour"] == .rsvp)
    }
}
