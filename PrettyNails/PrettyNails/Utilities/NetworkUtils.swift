import Foundation
import Network

class NetworkUtils {
    static let shared = NetworkUtils()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected = false
    @Published var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.updateConnectionType(path)
            }
        }
        monitor.start(queue: queue)
    }

    private func updateConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }

    static func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    static func createURLRequest(
        url: URL,
        method: HTTPMethod = .GET,
        headers: [String: String]? = nil,
        body: Data? = nil,
        timeout: TimeInterval = APIConfig.timeout
    ) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = method.rawValue

        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    static func handleHTTPResponse(_ response: URLResponse?, data: Data?, error: Error?) -> Result<Data, NetworkError> {
        if let error = error {
            return .failure(.networkError(error))
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(.invalidResponse)
        }

        guard let data = data else {
            return .failure(.noData)
        }

        switch httpResponse.statusCode {
        case 200...299:
            return .success(data)
        case 400:
            return .failure(.badRequest)
        case 401:
            return .failure(.unauthorized)
        case 403:
            return .failure(.forbidden)
        case 404:
            return .failure(.notFound)
        case 429:
            return .failure(.rateLimited)
        case 500...599:
            return .failure(.serverError)
        default:
            return .failure(.unknownError(httpResponse.statusCode))
        }
    }

    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
        case PATCH = "PATCH"
    }

    enum NetworkError: Error, LocalizedError {
        case networkError(Error)
        case invalidResponse
        case noData
        case badRequest
        case unauthorized
        case forbidden
        case notFound
        case rateLimited
        case serverError
        case unknownError(Int)

        var errorDescription: String? {
            switch self {
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from server"
            case .noData:
                return "No data received"
            case .badRequest:
                return "Bad request"
            case .unauthorized:
                return "Unauthorized access"
            case .forbidden:
                return "Access forbidden"
            case .notFound:
                return "Resource not found"
            case .rateLimited:
                return "Rate limit exceeded"
            case .serverError:
                return "Server error"
            case .unknownError(let code):
                return "Unknown error (HTTP \(code))"
            }
        }
    }
}