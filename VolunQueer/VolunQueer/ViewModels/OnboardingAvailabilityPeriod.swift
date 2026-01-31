import Foundation

/// Simple availability blocks used during onboarding.
enum OnboardingAvailabilityPeriod: String, CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening

    var id: String { rawValue }

    var label: String {
        switch self {
        case .morning:
            return "Morning"
        case .afternoon:
            return "Afternoon"
        case .evening:
            return "Evening"
        }
    }

    var window: TimeWindow {
        switch self {
        case .morning:
            return TimeWindow(startMinutes: 9 * 60, endMinutes: 12 * 60)
        case .afternoon:
            return TimeWindow(startMinutes: 12 * 60, endMinutes: 17 * 60)
        case .evening:
            return TimeWindow(startMinutes: 17 * 60, endMinutes: 21 * 60)
        }
    }
}
