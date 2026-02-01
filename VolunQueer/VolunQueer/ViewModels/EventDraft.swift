import Foundation

/// Draft state and builders for organizer event creation.
struct EventDraft {
    var title: String = ""
    var description: String = ""
    var startsAt: Date
    var endsAt: Date
    var timezone: String = TimeZone.current.identifier

    var locationName: String = ""
    var locationAddress: String = ""
    var locationCity: String = ""
    var locationRegion: String = ""
    var locationPostalCode: String = ""
    var locationCountry: String = ""

    var accessibilityNotes: String = ""
    var accessibilityTags: String = ""
    var tags: String = ""

    var rsvpCapEnabled: Bool = false
    var rsvpCap: Int = 20

    var contactName: String = ""
    var contactEmail: String = ""
    var contactPhone: String = ""

    var roles: [EventRoleDraft]

    var status: EventStatus = .published

    init(now: Date = Date()) {
        startsAt = now
        endsAt = now.addingTimeInterval(60 * 60)
        roles = [EventRoleDraft()]
    }

    init(event: Event, roles: [EventRole]) {
        title = event.title
        description = event.description ?? ""
        startsAt = event.startsAt
        endsAt = event.endsAt
        timezone = event.timezone
        locationName = event.location.name ?? ""
        locationAddress = event.location.address ?? ""
        locationCity = event.location.city ?? ""
        locationRegion = event.location.region ?? ""
        locationPostalCode = event.location.postalCode ?? ""
        locationCountry = event.location.country ?? ""
        accessibilityNotes = event.accessibility?.notes ?? ""
        accessibilityTags = event.accessibility?.tags?.joined(separator: ", ") ?? ""
        tags = event.tags.joined(separator: ", ")
        if let cap = event.rsvpCap {
            rsvpCapEnabled = true
            rsvpCap = cap
        } else {
            rsvpCapEnabled = false
            rsvpCap = 20
        }
        contactName = event.contact?.name ?? ""
        contactEmail = event.contact?.email ?? ""
        contactPhone = event.contact?.phone ?? ""
        status = event.status
        self.roles = roles.isEmpty ? [EventRoleDraft()] : roles.map { EventRoleDraft(role: $0) }
    }

    var validationMessage: String? {
        if title.trimmed.isEmpty {
            return "Add an event title."
        }
        if startsAt >= endsAt {
            return "End time must be after the start time."
        }
        if locationName.trimmed.isEmpty
            && locationAddress.trimmed.isEmpty
            && locationCity.trimmed.isEmpty
            && locationRegion.trimmed.isEmpty
            && locationPostalCode.trimmed.isEmpty
            && locationCountry.trimmed.isEmpty {
            return "Add a location for the event."
        }
        if rsvpCapEnabled && rsvpCap < 1 {
            return "RSVP cap must be at least 1."
        }
        if roles.isEmpty {
            return "Add at least one role."
        }
        if let roleIssue = roles.first(where: { $0.validationMessage != nil }) {
            return roleIssue.validationMessage
        }
        return nil
    }

    var canSubmit: Bool {
        validationMessage == nil
    }

    func buildEvent(userId: String, orgId: String, eventId: String? = nil, createdAt: Date? = nil, createdBy: String? = nil) -> (Event, [EventRole]) {
        let now = Date()
        let resolvedEventId = eventId ?? "event-\(UUID().uuidString)"
        let resolvedCreatedAt = createdAt ?? now

        let event = Event(
            id: resolvedEventId,
            orgId: orgId,
            title: title.trimmed,
            description: description.trimmed.nilIfEmpty,
            startsAt: startsAt,
            endsAt: endsAt,
            timezone: timezone.trimmed.isEmpty ? TimeZone.current.identifier : timezone.trimmed,
            location: LocationInfo(
                name: locationName.trimmed.nilIfEmpty,
                address: locationAddress.trimmed.nilIfEmpty,
                city: locationCity.trimmed.nilIfEmpty,
                region: locationRegion.trimmed.nilIfEmpty,
                postalCode: locationPostalCode.trimmed.nilIfEmpty,
                country: locationCountry.trimmed.nilIfEmpty,
                geo: nil
            ),
            accessibility: buildAccessibility(),
            tags: parseTags(tags),
            rsvpCap: rsvpCapEnabled ? max(1, rsvpCap) : nil,
            status: status,
            contact: buildContact(),
            createdBy: createdBy ?? userId,
            createdAt: resolvedCreatedAt,
            updatedAt: now
        )

        let builtRoles = roles.map { $0.buildRole() }

        return (event, builtRoles)
    }

    private func buildAccessibility() -> AccessibilityInfo? {
        let notes = accessibilityNotes.trimmed.nilIfEmpty
        let tags = parseTags(accessibilityTags)
        guard notes != nil || !tags.isEmpty else { return nil }
        return AccessibilityInfo(notes: notes, tags: tags.isEmpty ? nil : tags)
    }

    private func buildContact() -> EventContact? {
        let name = contactName.trimmed.nilIfEmpty
        let email = contactEmail.trimmed.nilIfEmpty
        let phone = contactPhone.trimmed.nilIfEmpty
        guard name != nil || email != nil || phone != nil else { return nil }
        return EventContact(name: name, email: email, phone: phone)
    }

    private func parseTags(_ text: String) -> [String] {
        text
            .split(whereSeparator: { $0 == "," || $0 == "\n" })
            .map { String($0).trimmed }
            .filter { !$0.isEmpty }
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nilIfEmpty: String? {
        let value = trimmed
        return value.isEmpty ? nil : value
    }
}
