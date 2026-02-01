import Foundation

/// Draft state for editing an event role.
struct EventRoleDraft: Identifiable, Hashable {
    var id: String
    var title: String
    var description: String
    var slotsTotal: Int
    var slotsFilled: Int
    var skills: String
    var checkInRequired: Bool
    var minAgeEnabled: Bool
    var minAge: Int

    init() {
        id = "role-\(UUID().uuidString)"
        title = "Volunteer"
        description = ""
        slotsTotal = 6
        slotsFilled = 0
        skills = ""
        checkInRequired = false
        minAgeEnabled = false
        minAge = 18
    }

    init(role: EventRole) {
        id = role.id
        title = role.title
        description = role.description ?? ""
        slotsTotal = role.slotsTotal
        slotsFilled = role.slotsFilled
        skills = role.skillsRequired.joined(separator: ", ")
        checkInRequired = role.checkInRequired
        if let minAge = role.minAge {
            minAgeEnabled = true
            self.minAge = minAge
        } else {
            minAgeEnabled = false
            minAge = 18
        }
    }

    var validationMessage: String? {
        if title.trimmed.isEmpty {
            return "Add a role title."
        }
        if slotsTotal < max(1, slotsFilled) {
            return "Slots must be at least \(max(1, slotsFilled))."
        }
        if minAgeEnabled && minAge < 1 {
            return "Minimum age must be at least 1."
        }
        return nil
    }

    func buildRole() -> EventRole {
        EventRole(
            id: id,
            title: title.trimmed,
            description: description.trimmed.nilIfEmpty,
            slotsTotal: max(slotsTotal, max(1, slotsFilled)),
            slotsFilled: slotsFilled,
            skillsRequired: parseTags(skills),
            checkInRequired: checkInRequired,
            minAge: minAgeEnabled ? max(1, minAge) : nil
        )
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
