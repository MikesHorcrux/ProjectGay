import SwiftUI
import AuthenticationServices

/// Minimal authentication UI for email/password and Sign in with Apple.
struct AuthView: View {
    @EnvironmentObject private var authStore: AuthStore
    @State private var isCreatingAccount = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome")
                .font(.largeTitle.bold())

            VStack(alignment: .leading, spacing: 12) {
                TextField("Email", text: $authStore.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $authStore.password)
                    .textContentType(.password)
                    .textFieldStyle(.roundedBorder)
            }

            if let message = authStore.errorMessage, !message.isEmpty {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button(isCreatingAccount ? "Create Account" : "Sign In") {
                Task {
                    if isCreatingAccount {
                        await authStore.signUpEmail()
                    } else {
                        await authStore.signInEmail()
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Button(isCreatingAccount ? "Have an account? Sign in" : "Need an account? Sign up") {
                isCreatingAccount.toggle()
            }
            .buttonStyle(.borderless)

            SignInWithAppleButton(.signIn) { request in
                authStore.prepareAppleRequest(request)
            } onCompletion: { result in
                authStore.handleAppleResult(result)
            }
            .frame(height: 44)
            .signInWithAppleButtonStyle(.black)
        }
        .padding(24)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthStore(isConfigured: false))
}
