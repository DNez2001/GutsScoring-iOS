import Foundation

/// Player OTP auth — `POST /auth/player/send-otp` and `verify-otp`.
final class AuthService {
    private let api: APIClient

    init(api: APIClient = .shared) {
        self.api = api
    }

    func sendOtp(phoneNumber: String) async throws {
        let _: MessageResponse = try await api.request(
            "auth/player/send-otp",
            method: "POST",
            body: SendOtpRequest(phoneNumber: phoneNumber)
        )
    }

    func verifyOtp(phoneNumber: String, code: String) async throws -> VerifyOtpResponse {
        let response: VerifyOtpResponse = try await api.request(
            "auth/player/verify-otp",
            method: "POST",
            body: VerifyOtpRequest(phoneNumber: phoneNumber, code: code)
        )
        KeychainTokenStore.shared.saveSession(response: response)
        return response
    }

    func signOut() {
        KeychainTokenStore.shared.clear()
    }
}
