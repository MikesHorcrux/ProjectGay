import SwiftUI

/// Step for organizer and organization details.
struct OnboardingOrganizerStepView: View {
    @Binding var organizationName: String
    @Binding var organizerRoleTitle: String
    @Binding var organizationMission: String
    @Binding var organizationWebsite: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("Organization name", text: $organizationName)
                .textFieldStyle(.roundedBorder)

            TextField("Your role (optional)", text: $organizerRoleTitle)
                .textFieldStyle(.roundedBorder)

            TextField("Mission (optional)", text: $organizationMission)
                .textFieldStyle(.roundedBorder)

            TextField("Website (optional)", text: $organizationWebsite)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)

            Text("You can fill out more details later.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
