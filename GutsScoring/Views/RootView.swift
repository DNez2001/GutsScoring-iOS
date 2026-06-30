import SwiftUI

struct RootView: View {
    @StateObject private var appState = AppState()

    var body: some View {
        Group {
            switch appState.route {
            case .splash:
                SplashView {
                    appState.completeSplash()
                }
            case .login:
                LoginView(appState: appState)
            case .main:
                MainShellView(appState: appState)
            }
        }
    }
}

#Preview {
    RootView()
}
