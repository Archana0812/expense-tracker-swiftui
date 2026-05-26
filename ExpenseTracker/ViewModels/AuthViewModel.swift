import FirebaseAuth
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var isLoading = false

    init() {
        user = FirebaseManager.shared.auth.currentUser
    }

    func login(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await FirebaseManager.shared.auth
                .signIn(withEmail: email.trimmed, password: password)
            user = result.user
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signup(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await FirebaseManager.shared.auth
                .createUser(withEmail: email.trimmed, password: password)
            user = result.user
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        try? FirebaseManager.shared.auth.signOut()
        user = nil
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
