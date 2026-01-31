import SwiftUI

/// Confirmation step for onboarding.
struct OnboardingDoneStepView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Welcome to VolunQueer!")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.softCharcoal)

            Text("You’re ready to discover events, RSVP quickly, and show up with confidence.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Label("Browse events that match your interests", systemImage: "sparkles")
                Label("Keep track of RSVPs in one place", systemImage: "checklist")
                Label("Update your profile anytime", systemImage: "person.crop.circle")
            }
            .font(.caption)
            .foregroundStyle(Theme.softCharcoal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
