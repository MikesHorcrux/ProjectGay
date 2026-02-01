import Testing
@testable import VolunQueer

struct EventDraftTests {
    @Test
    func validatesRequiredFields() {
        var draft = EventDraft(now: Date(timeIntervalSince1970: 0))
        draft.title = "Community Dinner"
        draft.locationName = "Center"
        draft.roles = [EventRoleDraft()]
        draft.roles[0].title = "Host"
        draft.roles[0].slotsTotal = 4
        draft.startsAt = Date(timeIntervalSince1970: 0)
        draft.endsAt = Date(timeIntervalSince1970: 3600)

        #expect(draft.validationMessage == nil)
    }

    @Test
    func buildsEventWithTagsAndContact() {
        var draft = EventDraft(now: Date(timeIntervalSince1970: 0))
        draft.title = "Community Dinner"
        draft.description = "Serve food and welcome guests."
        draft.locationName = "Center"
        draft.tags = "Community, Food"
        draft.accessibilityNotes = "Wheelchair accessible"
        draft.accessibilityTags = "ASL, Masks"
        draft.contactName = "Alex"
        draft.contactEmail = "alex@example.com"
        draft.roles = [EventRoleDraft()]
        draft.roles[0].title = "Host"
        draft.roles[0].slotsTotal = 3
        draft.rsvpCapEnabled = true
        draft.rsvpCap = 10
        draft.startsAt = Date(timeIntervalSince1970: 0)
        draft.endsAt = Date(timeIntervalSince1970: 3600)

        let createdAt = Date(timeIntervalSince1970: 0)
        let (event, roles) = draft.buildEvent(userId: "user-1", orgId: "org-1", createdAt: createdAt)

        #expect(event.orgId == "org-1")
        #expect(event.tags == ["Community", "Food"])
        #expect(event.accessibility?.notes == "Wheelchair accessible")
        #expect(event.accessibility?.tags == ["ASL", "Masks"])
        #expect(event.contact?.email == "alex@example.com")
        #expect(event.rsvpCap == 10)
        #expect(roles.count == 1)
        #expect(roles[0].title == "Host")
    }
}
