import SwiftUI

struct LoginView: View {
    @ObservedObject var appState: AppState
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Sign in with the same phone OTP used on Android.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Phone") {
                    TextField("+1…", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                    Button("Send code") {
                        Task { await viewModel.sendOtp() }
                    }
                    .disabled(viewModel.isBusy)
                }

                Section("Verification code") {
                    TextField("6-digit code", text: $viewModel.otpCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                    Button("Verify and continue") {
                        Task {
                            if let name = await viewModel.verifyOtp() {
                                appState.didSignIn(displayName: name)
                            }
                        }
                    }
                    .disabled(viewModel.isBusy)
                }

                Section("API") {
                    LabeledContent("Base URL", value: AppConfig.productionAPIBaseURL.absoluteString)
                    LabeledContent("Build", value: "\(AppConfig.appVersion) (\(AppConfig.buildNumber))")
                }

                if let info = viewModel.infoMessage {
                    Section {
                        Text(info).foregroundStyle(.green)
                    }
                }
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Guts Scoring")
        }
    }
}

#Preview {
    LoginView(appState: AppState())
}
