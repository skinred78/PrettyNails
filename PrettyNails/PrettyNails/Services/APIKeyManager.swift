import Foundation
import Security

class APIKeyManager {
    static let shared = APIKeyManager()

    private let service = "com.prettynails.apikeys"
    private let geminiAPIKeyAccount = "gemini_api_key"

    private init() {}

    func storeAPIKey(_ key: String, for account: String = "gemini_api_key") -> Bool {
        guard let data = key.data(using: .utf8) else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func retrieveAPIKey(for account: String = "gemini_api_key") -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func deleteAPIKey(for account: String = "gemini_api_key") -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    var geminiAPIKey: String? {
        get { retrieveAPIKey(for: geminiAPIKeyAccount) }
        set {
            if let key = newValue {
                _ = storeAPIKey(key, for: geminiAPIKeyAccount)
            } else {
                _ = deleteAPIKey(for: geminiAPIKeyAccount)
            }
        }
    }
}