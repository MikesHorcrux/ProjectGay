import SwiftUI

/// Event detail: first-screen essentials so volunteers can answer "am I comfortable showing up?"
/// — where/when, what you'll do, accessibility, organizer contact, role availability.
struct EventDetailView: View {
    let event: Event
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var authStore: AuthStore

    private var roles: [EventRole] { store.roles(for: event) }
    private var org: Organization? { store.organization(for: event) }
    private var currentUser: AppUser? {
        guard case .signedIn(let userId) = authStore.state else { return nil }
        return store.users.first { $0.id == userId }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                whenWhereSection
                whatYouDoSection
                if let accessibility = event.accessibility, hasAccessibilityContent(accessibility) {
                    accessibilitySection(accessibility)
                }
                if let contact = event.contact, hasContactContent(contact) {
                    contactSection(contact)
                }
                if !roles.isEmpty {
                    rolesSection
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
        .background(Theme.cream)
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            rsvpBar
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let org = org {
                Text(org.name)
                    .font(.subheadline)
                    .foregroundStyle(Theme.skyTeal)
            }
            if !event.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(event.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.lavenderMist)
                            .foregroundStyle(Theme.softCharcoal)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var whenWhereSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("When & where")
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "calendar")
                        .font(.body)
                        .foregroundStyle(Theme.skyTeal)
                        .frame(width: 24, alignment: .center)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(whenText)
                        Text(event.timezone)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                    .foregroundStyle(Theme.softCharcoal)
                }
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "mappin.circle")
                        .font(.body)
                        .foregroundStyle(Theme.skyTeal)
                        .frame(width: 24, alignment: .center)
                    Text(whereText)
                        .font(.subheadline)
                        .foregroundStyle(Theme.softCharcoal)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var whatYouDoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("What you'll do")
            if let description = event.description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundStyle(Theme.softCharcoal)
            }
        }
    }

    private func accessibilitySection(_ info: AccessibilityInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Accessibility")
            VStack(alignment: .leading, spacing: 6) {
                if let notes = info.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(Theme.softCharcoal)
                }
                if let tags = info.tags, !tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.lavenderMist)
                                .foregroundStyle(Theme.softCharcoal)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func contactSection(_ contact: EventContact) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Event contact")
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "person.circle")
                    .font(.body)
                    .foregroundStyle(Theme.skyTeal)
                    .frame(width: 24, alignment: .center)
                VStack(alignment: .leading, spacing: 4) {
                    if let name = contact.name, !name.isEmpty {
                        Text(name)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Theme.softCharcoal)
                    }
                    if let email = contact.email, !email.isEmpty {
                        Text(email)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let phone = contact.phone, !phone.isEmpty {
                        Text(phone)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var rolesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Roles")
            VStack(spacing: 8) {
                ForEach(roles) { role in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(role.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Theme.softCharcoal)
                            if let desc = role.description, !desc.isEmpty {
                                Text(desc)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(role.slotsFilled)/\(role.slotsTotal)")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(Theme.skyTeal)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    private var rsvpBar: some View {
        VStack(spacing: 0) {
            Divider()
            if let userId = currentUserId {
                if isOrganizerForEvent {
                    OrganizerEventBarView(event: event, service: store.rsvpService)
                } else {
                    RSVPBarView(event: event, roles: roles, userId: userId, service: store.rsvpService)
                }
            } else {
                signInPromptBar
            }
        }
    }

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.softCharcoal)
    }

    private var whenText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d 'at' h:mm a"
        formatter.timeZone = TimeZone(identifier: event.timezone) ?? .current
        return formatter.string(from: event.startsAt)
    }

    private var whereText: String {
        let parts = [event.location.name, event.location.address, event.location.city]
            .compactMap { $0 }.filter { !$0.isEmpty }
        return parts.joined(separator: "\n").isEmpty ? "Location TBD" : parts.joined(separator: "\n")
    }

    private func hasAccessibilityContent(_ info: AccessibilityInfo) -> Bool {
        (info.notes?.isEmpty == false) || (info.tags?.isEmpty == false)
    }

    private func hasContactContent(_ contact: EventContact) -> Bool {
        (contact.name?.isEmpty == false) || (contact.email?.isEmpty == false) || (contact.phone?.isEmpty == false)
    }

    private var currentUserId: String? {
        if case .signedIn(let userId) = authStore.state {
            return userId
        }
        return nil
    }

    private var isOrganizerForEvent: Bool {
        guard let user = currentUser else { return false }
        guard user.roles.contains(.organizer) else { return false }
        if event.createdBy == user.id {
            return true
        }
        return user.organizerProfile?.orgIds.contains(event.orgId) ?? false
    }

    private var signInPromptBar: some View {
        VStack(spacing: 8) {
            Text("Sign in to RSVP")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.coralRose)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Theme.cream)
    }
}

#Preview {
    NavigationStack {
        let store = AppStore(dataSource: .mock, preload: true)
        if let event = store.publishedEvents.first {
            EventDetailView(event: event)
                .environmentObject(store)
                .environmentObject(AuthStore(isConfigured: false))
        }
    }
}
