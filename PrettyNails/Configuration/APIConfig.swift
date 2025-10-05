import Foundation

struct APIConfig {
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta"
    static let imagenEndpoint = "/models/imagen-3.0-generate-001:generateImage"
    static let timeout: TimeInterval = 30.0
    static let maxRetries = 3
    static let retryDelay: TimeInterval = 1.0

    enum Environment {
        case development
        case production

        var baseURL: String {
            switch self {
            case .development:
                return APIConfig.geminiBaseURL
            case .production:
                return APIConfig.geminiBaseURL
            }
        }
    }

    static var currentEnvironment: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    struct Headers {
        static let contentType = "application/json"
        static let userAgent = "PrettyNails-iOS/1.0"
        static let accept = "application/json"
    }

    struct RequestLimits {
        static let maxImageSize: Int = 10 * 1024 * 1024
        static let maxImageDimension: Int = 2048
        static let supportedFormats = ["jpg", "jpeg", "png", "webp"]
    }
}