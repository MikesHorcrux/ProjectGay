import SwiftUI

/// Step for choosing volunteer and/or organizer roles.
struct OnboardingRoleStepView: View {
    @Binding var selectedRoles: Set<UserRole>

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How do you want to participate?")
                .font(.headline)
                .foregroundStyle(Theme.softCharcoal)

            VStack(spacing: 12) {
                roleCard(
                    title: "Volunteer",
                    subtitle: "Discover events, RSVP fast, and track your impact.",
                    role: .volunteer
                )

                roleCard(
                    title: "Organizer",
                    subtitle: "Post events, manage rosters, and support volunteers.",
                    role: .organizer
                )
            }

            Text("You can change this later in your profile.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func roleCard(title: String, subtitle: String, role: UserRole) -> some View {
        let isSelected = selectedRoles.contains(role)
        return Button {
            toggle(role)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Theme.skyTeal : .secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Theme.softCharcoal)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Theme.lavenderMist : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func toggle(_ role: UserRole) {
        if selectedRoles.contains(role) {
            selectedRoles.remove(role)
        } else {
            selectedRoles.insert(role)
        }
    }
}
