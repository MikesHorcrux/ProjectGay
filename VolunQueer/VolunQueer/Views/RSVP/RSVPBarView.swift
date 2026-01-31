import SwiftUI

/// RSVP bar with role selection, consent toggles, and submit button.
struct RSVPBarView: View {
    let event: Event
    let roles: [EventRole]
    let userId: String

    private let service: RSVPService
    @StateObject private var viewModel: RSVPViewModel
    @State private var rsvpCount: Int?

    init(event: Event, roles: [EventRole], userId: String, service: RSVPService) {
        self.event = event
        self.roles = roles
        self.userId = userId
        self.service = service
        _viewModel = StateObject(wrappedValue: RSVPViewModel(eventId: event.id, userId: userId, roles: roles, service: service))
    }

    var body: some View {
        VStack(spacing: 12) {
            if let helper = viewModel.helperText {
                Text(helper)
                    .font(.caption)
                    .foregroundStyle(Theme.softCharcoal.opacity(0.8))
            }

            if !roles.isEmpty {
                Picker("Role", selection: $viewModel.selectedRoleId) {
                    ForEach(roles) { role in
                        Text(role.title).tag(Optional(role.id))
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            consentSection

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let capacityMessage = capacityMessage {
                Text(capacityMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task {
                    await viewModel.toggleRSVP()
                    await loadCapacity()
                }
            } label: {
                Text(viewModel.buttonTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.coralRose)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isActionDisabled)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Theme.cream)
        .task {
            await viewModel.load()
            await loadCapacity()
        }
    }

    private var consentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Share with organizers")
                .font(.caption)
                .foregroundStyle(Theme.softCharcoal.opacity(0.8))

            Toggle("Pronouns", isOn: $viewModel.consent.sharePronouns)
            Toggle("Accessibility needs", isOn: $viewModel.consent.shareAccessibility)
            Toggle("Email", isOn: $viewModel.consent.shareEmail)
            Toggle("Phone", isOn: $viewModel.consent.sharePhone)
        }
        .font(.caption)
    }

    private var isActionDisabled: Bool {
        if viewModel.status == .rsvp {
            return viewModel.isLoading
        }
        return viewModel.isLoading || isCapacityBlocked
    }

    private var isCapacityBlocked: Bool {
        if roles.isEmpty {
            return isCapacityBlockedNoRoles
        }
        if !hasOpenRole {
            return true
        }
        if let selectedRole = selectedRole, selectedRole.slotsFilled >= selectedRole.slotsTotal {
            return true
        }
        return false
    }

    private var hasOpenRole: Bool {
        roles.contains { $0.slotsFilled < $0.slotsTotal }
    }

    private var selectedRole: EventRole? {
        guard let roleId = viewModel.selectedRoleId else { return nil }
        return roles.first { $0.id == roleId }
    }

    private var capacityMessage: String? {
        guard viewModel.status != .rsvp else { return nil }
        if roles.isEmpty {
            if let cap = event.rsvpCap, let count = rsvpCount, count >= cap {
                return "Event RSVP capacity reached."
            }
            return nil
        } else {
            if !hasOpenRole {
                return "All roles are full."
            }
            if let selectedRole = selectedRole, selectedRole.slotsFilled >= selectedRole.slotsTotal {
                return "That role is full. Choose another role."
            }
            return nil
        }
    }

    private var isCapacityBlockedNoRoles: Bool {
        guard roles.isEmpty else { return false }
        guard let cap = event.rsvpCap, let count = rsvpCount else { return false }
        return count >= cap
    }

    private func loadCapacity() async {
        guard roles.isEmpty, let cap = event.rsvpCap, cap > 0 else {
            rsvpCount = nil
            return
        }
        do {
            let rsvps = try await service.fetchRsvps(eventId: event.id)
            rsvpCount = rsvps.filter { $0.status != .cancelled }.count
        } catch {
            rsvpCount = nil
        }
    }
}

#Preview {
    let store = AppStore(dataSource: .mock, preload: true)
    let event = store.publishedEvents.first!
    RSVPBarView(event: event, roles: store.roles(for: event), userId: "user-alex", service: MockRSVPService())
}
