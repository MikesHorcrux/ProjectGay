import SwiftUI

/// Step for basic profile and consent settings.
struct OnboardingBasicsStepView: View {
    @Binding var displayName: String
    @Binding var pronouns: String
    @Binding var email: String
    @Binding var phone: String
    @Binding var preferredChannel: ContactChannel
    @Binding var shareEmail: Bool
    @Binding var sharePhone: Bool
    @Binding var sharePronouns: Bool
    @Binding var shareAccessibility: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Display name", text: $displayName)
                    .textFieldStyle(.roundedBorder)

                TextField("Pronouns (optional)", text: $pronouns)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 12) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                TextField("Phone (optional)", text: $phone)
                    .keyboardType(.phonePad)
                    .textFieldStyle(.roundedBorder)

                Picker("Preferred contact", selection: $preferredChannel) {
                    Text("Email").tag(ContactChannel.email)
                    Text("SMS").tag(ContactChannel.sms)
                    Text("Push").tag(ContactChannel.push)
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("What organizers can see")
                    .font(.headline)
                    .foregroundStyle(Theme.softCharcoal)

                Toggle("Share email", isOn: $shareEmail)
                Toggle("Share phone", isOn: $sharePhone)
                Toggle("Share pronouns", isOn: $sharePronouns)
                Toggle("Share accessibility needs", isOn: $shareAccessibility)
            }
            .font(.caption)

            Text("You can change this later. We only share what you explicitly allow.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
