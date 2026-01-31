import Foundation

/// Computes whether a user needs onboarding.
enum OnboardingStatus {
    static func requiresOnboarding(for user: AppUser?) -> Bool {
        guard let user else { return true }
        if user.roles.isEmpty { return true }
        if user.contact?.email?.isEmpty != false { return true }
        if user.roles.contains(.volunteer), user.volunteerProfile == nil {
            return true
        }
        if user.roles.contains(.organizer), user.organizerProfile == nil {
            return true
        }
        return false
    }
}
