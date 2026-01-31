import Foundation

/// Steps shown during onboarding.
enum OnboardingStep: String, CaseIterable, Identifiable {
    case role
    case basics
    case volunteer
    case organizer
    case done

    var id: String { rawValue }

    var title: String {
        switch self {
        case .role:
            return "Choose your path"
        case .basics:
            return "Basics & consent"
        case .volunteer:
            return "Volunteer profile"
        case .organizer:
            return "Organizer profile"
        case .done:
            return "You're all set"
        }
    }

    var subtitle: String {
        switch self {
        case .role:
            return "Pick what you want to do right now. You can add more later."
        case .basics:
            return "Share only what organizers need to coordinate."
        case .volunteer:
            return "Tell us what you enjoy and when you’re free."
        case .organizer:
            return "Set up the organization you’ll post events for."
        case .done:
            return "Your profile is ready."
        }
    }
}
