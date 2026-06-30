import Foundation
import Security

/// Secure session storage. Mirrors Android `GutsAuthTokenStore` (EncryptedSharedPreferences).
final class KeychainTokenStore {
    static let shared = KeychainTokenStore()

    private let service = "com.nezsports.gutsscoring.ios.auth"
    private let sessionAccount = "session_token"
    private let playerIdAccount = "player_id"
    private let displayNameAccount = "display_name"

    var sessionToken: String? { read(account: sessionAccount) }
    var playerId: String? { read(account: playerIdAccount) }
    var displayName: String? { read(account: displayNameAccount) }

    var isLoggedIn: Bool { sessionToken != nil }

    func saveSession(response: VerifyOtpResponse) {
        write(response.sessionToken, account: sessionAccount)
        write(response.player.playerId, account: playerIdAccount)
        write(response.player.displayName, account: displayNameAccount)
    }

    func clear() {
        delete(account: sessionAccount)
        delete(account: playerIdAccount)
        delete(account: displayNameAccount)
    }

    // MARK: - Keychain helpers

    private func read(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func write(_ value: String, account: String) {
        delete(account: account)
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
