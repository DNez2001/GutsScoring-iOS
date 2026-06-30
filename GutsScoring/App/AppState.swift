import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    enum Route {
        case splash
        case login
        case main
    }

    @Published var route: Route = .splash
    @Published var signedInDisplayName: String?

    private let auth = AuthService()

    func bootstrap() {
        if KeychainTokenStore.shared.isLoggedIn {
            signedInDisplayName = KeychainTokenStore.shared.displayName
            route = .main
        } else {
            route = .login
        }
    }

    func completeSplash() {
        bootstrap()
    }

    func didSignIn(displayName: String) {
        signedInDisplayName = displayName
        route = .main
    }

    func signOut() {
        auth.signOut()
        signedInDisplayName = nil
        route = .login
    }
}
