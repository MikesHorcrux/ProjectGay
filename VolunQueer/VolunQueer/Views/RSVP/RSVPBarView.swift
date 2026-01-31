import SwiftUI

/// RSVP bar with role selection, consent toggles, and submit button.
struct RSVPBarView: View {
    let event: Event
    let roles: [EventRole]
    let userId: String

    @StateObject private var viewModel: RSVPViewModel

    init(event: Event, roles: [EventRole], userId: String, service: RSVPService) {
        self.event = event
        self.roles = roles
        self.userId = userId
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

            Button {
                Task { await viewModel.toggleRSVP() }
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
            .disabled(viewModel.isLoading)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Theme.cream)
        .task {
            await viewModel.load()
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
}

#Preview {
    let store = AppStore(dataSource: .mock, preload: true)
    let event = store.publishedEvents.first!
    RSVPBarView(event: event, roles: store.roles(for: event), userId: "user-alex", service: MockRSVPService())
}
