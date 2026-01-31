import Foundation
import Combine
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Security

/// Handles Firebase authentication state and sign-in flows.
@MainActor
final class AuthStore: ObservableObject {
    @Published private(set) var state: AuthState = .signedOut
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?

    private var authListener: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    private let isConfigured: Bool

    init(isConfigured: Bool) {
        self.isConfigured = isConfigured

        guard isConfigured else {
            state = .unavailable("Firebase is not configured. Add GoogleService-Info.plist to the app target.")
            return
        }

        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.updateState(for: user)
            }
        }

        updateState(for: Auth.auth().currentUser)
    }

    deinit {
        if let authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }

    /// Signs in with email and password.
    func signInEmail() async {
        guard isConfigured else { return }
        guard validateEmailPassword() else { return }
        state = .loading

        do {
            _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, Error>) in
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let result else {
                        continuation.resume(throwing: NSError(domain: "AuthStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing authentication result."]))
                        return
                    }
                    continuation.resume(returning: result)
                }
            }
        } catch {
            handleAuthError(error)
        }
    }

    /// Creates an account with email and password.
    func signUpEmail() async {
        guard isConfigured else { return }
        guard validateEmailPassword() else { return }
        state = .loading

        do {
            _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, Error>) in
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let result else {
                        continuation.resume(throwing: NSError(domain: "AuthStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing authentication result."]))
                        return
                    }
                    continuation.resume(returning: result)
                }
            }
        } catch {
            handleAuthError(error)
        }
    }

    /// Signs out the current user.
    func signOut() {
        guard isConfigured else { return }
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Prepares a Sign in with Apple request.
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }

    /// Handles the Apple sign-in result and signs into Firebase.
    func handleAppleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                errorMessage = "Unable to read Apple ID credential."
                state = .signedOut
                return
            }

            guard let tokenData = appleIDCredential.identityToken,
                  let tokenString = String(data: tokenData, encoding: .utf8) else {
                errorMessage = "Unable to read Apple identity token."
                state = .signedOut
                return
            }

            guard let nonce = currentNonce else {
                errorMessage = "Missing sign-in nonce."
                state = .signedOut
                return
            }

            state = .loading
            let credential = OAuthProvider.credential(providerID: .apple, idToken: tokenString, rawNonce: nonce)
            Task {
                await signIn(with: credential)
            }
        case .failure(let error):
            handleAuthError(error)
        }
    }

    private func signIn(with credential: AuthCredential) async {
        do {
            _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, Error>) in
                Auth.auth().signIn(with: credential) { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let result else {
                        continuation.resume(throwing: NSError(domain: "AuthStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing authentication result."]))
                        return
                    }
                    continuation.resume(returning: result)
                }
            }
        } catch {
            handleAuthError(error)
        }
    }

    private func updateState(for user: User?) {
        if let user {
            state = .signedIn(userID: user.uid)
            errorMessage = nil
        } else {
            state = .signedOut
        }
    }

    private func validateEmailPassword() -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty || password.isEmpty {
            errorMessage = "Email and password are required."
            state = .signedOut
            return false
        }
        return true
    }

    private func handleAuthError(_ error: Error) {
        errorMessage = error.localizedDescription
        state = .signedOut
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}
