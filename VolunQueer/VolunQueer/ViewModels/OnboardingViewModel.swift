import Foundation
import Combine

/// Holds onboarding state and builds profile models.
@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentStepIndex: Int = 0
    @Published var selectedRoles: Set<UserRole> = [.volunteer]

    @Published var displayName: String = ""
    @Published var pronouns: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var preferredChannel: ContactChannel = .email

    @Published var shareEmail: Bool = true
    @Published var sharePhone: Bool = false
    @Published var sharePronouns: Bool = true
    @Published var shareAccessibility: Bool = true

    @Published var volunteerInterests: Set<String> = []
    @Published var volunteerSkills: Set<String> = []
    @Published var volunteerWeekdays: Set<Weekday> = []
    @Published var volunteerPeriod: OnboardingAvailabilityPeriod = .evening
    @Published var accessibilityNeeds: String = ""

    @Published var organizationName: String = ""
    @Published var organizerRoleTitle: String = ""
    @Published var organizationMission: String = ""
    @Published var organizationWebsite: String = ""

    @Published private(set) var errorMessage: String?
    @Published var isSaving: Bool = false
    private var hasPrefilled = false

    var steps: [OnboardingStep] {
        var list: [OnboardingStep] = [.role, .basics]
        if selectedRoles.contains(.volunteer) {
            list.append(.volunteer)
        }
        if selectedRoles.contains(.organizer) {
            list.append(.organizer)
        }
        list.append(.done)
        return list
    }

    var currentStep: OnboardingStep {
        steps[min(currentStepIndex, steps.count - 1)]
    }

    var progressValue: Double {
        Double(currentStepIndex + 1) / Double(steps.count)
    }

    func advance() {
        guard currentStepIndex + 1 < steps.count else { return }
        currentStepIndex += 1
    }

    func back() {
        guard currentStepIndex > 0 else { return }
        currentStepIndex -= 1
    }

    func canAdvance() -> Bool {
        switch currentStep {
        case .role:
            return !selectedRoles.isEmpty
        case .basics:
            guard !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
            guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
            if preferredChannel == .sms {
                return !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            return true
        case .volunteer:
            return true
        case .organizer:
            return !organizationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .done:
            return true
        }
    }

    func buildUser(userId: String, orgId: String?) -> AppUser {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPronouns = pronouns.trimmingCharacters(in: .whitespacesAndNewlines)

        let visibility = UserVisibility(
            shareEmail: shareEmail,
            sharePhone: sharePhone,
            sharePronouns: sharePronouns,
            shareAccessibility: shareAccessibility
        )

        let contact = ContactInfo(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : phone,
            preferredChannel: preferredChannel
        )

        let volunteerProfile = selectedRoles.contains(.volunteer) ? buildVolunteerProfile() : nil
        let organizerProfile = selectedRoles.contains(.organizer) ? buildOrganizerProfile(orgId: orgId) : nil
        let now = Date()

        return AppUser(
            id: userId,
            displayName: trimmedName,
            pronouns: trimmedPronouns.isEmpty ? nil : trimmedPronouns,
            photoURL: nil,
            roles: Array(selectedRoles),
            status: .active,
            visibility: visibility,
            contact: contact,
            volunteerProfile: volunteerProfile,
            organizerProfile: organizerProfile,
            impactSummary: nil,
            createdAt: now,
            updatedAt: now
        )
    }

    func prefillIfNeeded(from user: AppUser?) {
        guard let user, !hasPrefilled else { return }
        hasPrefilled = true
        displayName = user.displayName
        pronouns = user.pronouns ?? ""
        email = user.contact?.email ?? ""
        phone = user.contact?.phone ?? ""
        preferredChannel = user.contact?.preferredChannel ?? .email
        shareEmail = user.visibility.shareEmail
        sharePhone = user.visibility.sharePhone
        sharePronouns = user.visibility.sharePronouns
        shareAccessibility = user.visibility.shareAccessibility
        selectedRoles = Set(user.roles)

        if let profile = user.volunteerProfile {
            volunteerInterests = Set(profile.interests)
            volunteerSkills = Set(profile.skills)
            accessibilityNeeds = profile.accessibilityNeeds?.joined(separator: ", ") ?? ""
            if let availability = profile.availability, let window = availability.weekly.first?.windows.first {
                volunteerWeekdays = Set(availability.weekly.map { $0.weekday })
                volunteerPeriod = periodForWindow(window)
            }
        }

        if let organizer = user.organizerProfile {
            organizerRoleTitle = organizer.contactRole ?? ""
        }
    }

    func buildOrganization(ownerId: String) -> Organization? {
        guard selectedRoles.contains(.organizer) else { return nil }
        let trimmedName = organizationName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return nil }
        let now = Date()
        return Organization(
            id: "org-\(UUID().uuidString)",
            name: trimmedName,
            mission: organizationMission.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : organizationMission,
            website: organizationWebsite.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : organizationWebsite,
            location: nil,
            contact: nil,
            verified: false,
            ownerUid: ownerId,
            createdAt: now,
            updatedAt: now
        )
    }

    func setError(_ message: String) {
        errorMessage = message
    }

    func clearError() {
        errorMessage = nil
    }

    private func buildVolunteerProfile() -> VolunteerProfile {
        let interests = Array(volunteerInterests)
        let skills = Array(volunteerSkills)
        let availability = buildAvailability()
        let accessibility = accessibilityNeeds.trimmingCharacters(in: .whitespacesAndNewlines)
        return VolunteerProfile(
            interests: interests,
            skills: skills,
            availability: availability,
            accessibilityNeeds: accessibility.isEmpty ? nil : [accessibility],
            location: nil,
            bio: nil,
            experienceNotes: nil
        )
    }

    private func buildOrganizerProfile(orgId: String?) -> OrganizerProfile {
        let role = organizerRoleTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        return OrganizerProfile(
            orgIds: orgId.map { [$0] } ?? [],
            contactRole: role.isEmpty ? nil : role,
            verified: false
        )
    }

    private func buildAvailability() -> Availability? {
        guard !volunteerWeekdays.isEmpty else { return nil }
        let windows = [volunteerPeriod.window]
        let weekly = volunteerWeekdays.sorted(by: { $0.rawValue < $1.rawValue }).map { day in
            WeekdayAvailability(weekday: day, windows: windows)
        }
        return Availability(timezone: TimeZone.current.identifier, weekly: weekly)
    }

    private func periodForWindow(_ window: TimeWindow) -> OnboardingAvailabilityPeriod {
        let mid = (window.startMinutes + window.endMinutes) / 2
        switch mid {
        case ..<(12 * 60):
            return .morning
        case ..<(17 * 60):
            return .afternoon
        default:
            return .evening
        }
    }
}
