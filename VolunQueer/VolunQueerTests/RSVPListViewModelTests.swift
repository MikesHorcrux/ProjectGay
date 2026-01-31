import Testing
@testable import VolunQueer

struct RSVPListViewModelTests {
    @Test
    @MainActor
    func loadsOnlyActiveRsvps() async {
        let service = MockRSVPService(seed: MockData.bundle)
        let viewModel = RSVPListViewModel(userId: "user-alex", service: service)

        await viewModel.load(events: MockData.bundle.events)

        #expect(viewModel.rows.count == 1)
        #expect(viewModel.rows.first?.event.id == "event-coffee-hour")
        #expect(viewModel.rows.first?.rsvp.status == .rsvp)
    }
}
