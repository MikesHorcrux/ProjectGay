import SwiftUI

/// Profile summary with navigation to editing.
struct ProfileView: View {
    @EnvironmentObject private var store: AppStore
    let userId: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let user = store.user(for: userId) {
                    header(for: user)
                    contactCard(for: user)
                    if user.roles.contains(.volunteer) {
                        volunteerCard(for: user)
                    }
                    if user.roles.contains(.organizer) {
                        organizerCard(for: user)
                    }
                } else {
                    ContentUnavailableView(
                        "Profile unavailable",
                        systemImage: "person.crop.circle.badge.exclam",
                        description: Text("We couldn't find your profile yet.")
                    )
                }
            }
            .padding()
        }
        .background(Theme.cream)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Edit") {
                    ProfileEditView(userId: userId)
                }
            }
        }
    }

    private func header(for user: AppUser) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(user.displayName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Theme.softCharcoal)

            if let pronouns = user.pronouns, !pronouns.isEmpty {
                Text(pronouns)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(user.roles.map { $0.rawValue.capitalized }.joined(separator: " • "))
                .font(.caption)
                .foregroundStyle(Theme.skyTeal)
        }
    }

    private func contactCard(for user: AppUser) -> some View {
        let contact = user.contact
        return cardView(title: "Contact") {
            VStack(alignment: .leading, spacing: 6) {
                Text(contact?.email ?? "Email not set")
                Text(contact?.phone ?? "Phone not set")
                if let channel = contact?.preferredChannel {
                    Text("Preferred: \(channel.rawValue.uppercased())")
                }
            }
            .font(.caption)
            .foregroundStyle(Theme.softCharcoal)
        }
    }

    private func volunteerCard(for user: AppUser) -> some View {
        cardView(title: "Volunteer profile") {
            if let profile = user.volunteerProfile {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Interests: \(profile.interests.joined(separator: ", "))")
                    Text("Skills: \(profile.skills.joined(separator: ", "))")
                    Text("Availability: \(availabilitySummary(profile.availability))")
                    if let needs = profile.accessibilityNeeds?.joined(separator: ", "), !needs.isEmpty {
                        Text("Accessibility: \(needs)")
                    }
                }
                .font(.caption)
                .foregroundStyle(Theme.softCharcoal)
            } else {
                Text("Complete your volunteer details.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func organizerCard(for user: AppUser) -> some View {
        cardView(title: "Organizer profile") {
            VStack(alignment: .leading, spacing: 6) {
                if let profile = user.organizerProfile {
                    if !profile.orgIds.isEmpty {
                        Text("Organizations: \(organizationSummary(profile))")
                    }
                    if let role = profile.contactRole, !role.isEmpty {
                        Text("Role: \(role)")
                    }
                }
            }
            .font(.caption)
            .foregroundStyle(Theme.softCharcoal)
        }
    }

    private func cardView<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.softCharcoal)
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func availabilitySummary(_ availability: Availability?) -> String {
        guard let availability else { return "Not set" }
        let days = availability.weekly.map { $0.weekday.rawValue.prefix(3).capitalized }
        if days.isEmpty { return "Not set" }
        return days.joined(separator: ", ")
    }

    private func organizationSummary(_ profile: OrganizerProfile) -> String {
        let names = profile.orgIds.compactMap { id in
            store.organizations.first { $0.id == id }?.name
        }
        return names.isEmpty ? "Not set" : names.joined(separator: ", ")
    }
}

#Preview {
    NavigationStack {
        ProfileView(userId: "user-alex")
            .environmentObject(AppStore(dataSource: .mock, preload: true))
    }
}

