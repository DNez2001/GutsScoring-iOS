import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var otpCode = ""
    @Published var isBusy = false
    @Published var errorMessage: String?
    @Published var infoMessage: String?

    private let auth = AuthService()

    func sendOtp() async {
        errorMessage = nil
        infoMessage = nil
        let phone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phone.isEmpty else {
            errorMessage = "Enter your phone number."
            return
        }
        isBusy = true
        defer { isBusy = false }
        do {
            try await auth.sendOtp(phoneNumber: phone)
            infoMessage = "Code sent. Check your phone."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func verifyOtp() async -> String? {
        errorMessage = nil
        infoMessage = nil
        let phone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let code = otpCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phone.isEmpty, !code.isEmpty else {
            errorMessage = "Enter phone number and verification code."
            return nil
        }
        isBusy = true
        defer { isBusy = false }
        do {
            let response = try await auth.verifyOtp(phoneNumber: phone, code: code)
            return response.player.displayName
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
