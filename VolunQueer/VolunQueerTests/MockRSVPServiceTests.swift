import Testing
@testable import VolunQueer

struct MockRSVPServiceTests {
    @Test
    func submitAndCancelRsvp() async throws {
        let service = MockRSVPService(seed: MockData.bundle)
        let consent = ConsentSnapshot(shareEmail: true, sharePhone: false, sharePronouns: true, shareAccessibility: true)

        let submitted = try await service.submitRSVP(
            eventId: "event-kits",
            userId: "user-jules",
            roleId: "role-assembler",
            consent: consent
        )

        #expect(submitted.status == .rsvp)
        #expect(submitted.consent.shareEmail == true)

        let fetched = try await service.fetchRSVP(eventId: "event-kits", userId: "user-jules")
        #expect(fetched?.status == .rsvp)

        let cancelled = try await service.cancelRSVP(eventId: "event-kits", userId: "user-jules")
        #expect(cancelled.status == .cancelled)
    }
}
