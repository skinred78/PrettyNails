import Foundation
import UIKit

class GeminiAPIClient {
    static let shared = GeminiAPIClient()

    private let session = URLSession.shared
    private let apiKeyManager = APIKeyManager.shared

    private init() {}

    func generateImage(prompt: String, originalImage: UIImage, maskImage: UIImage? = nil) async throws -> UIImage {
        guard let apiKey = apiKeyManager.geminiAPIKey else {
            throw GeminiAPIError.invalidAPIKey
        }

        guard let imageData = originalImage.optimizedForAPI()?.compressed() else {
            throw GeminiAPIError.invalidRequest
        }

        let request = try createRequest(
            prompt: prompt,
            imageData: imageData,
            maskData: maskImage?.compressed(),
            apiKey: apiKey
        )

        let (data, response) = try await session.data(for: request)

        let result = NetworkUtils.handleHTTPResponse(response, data: data, error: nil)

        switch result {
        case .success(let responseData):
            return try parseImageResponse(responseData)
        case .failure(let error):
            throw mapNetworkError(error)
        }
    }

    private func createRequest(prompt: String, imageData: Data, maskData: Data?, apiKey: String) throws -> URLRequest {
        let urlString = "\(APIConfig.currentEnvironment.baseURL)\(APIConfig.imagenEndpoint)"
        guard let url = URL(string: urlString) else {
            throw GeminiAPIError.invalidRequest
        }

        let requestBody = GeminiImageRequest(
            prompt: prompt,
            imageData: imageData,
            maskData: maskData
        )

        let jsonData = try JSONEncoder().encode(requestBody)

        var request = NetworkUtils.createURLRequest(
            url: url,
            method: .POST,
            headers: [
                "Content-Type": APIConfig.Headers.contentType,
                "Authorization": "Bearer \(apiKey)",
                "User-Agent": APIConfig.Headers.userAgent
            ],
            body: jsonData
        )

        return request
    }

    private func parseImageResponse(_ data: Data) throws -> UIImage {
        let decoder = JSONDecoder()
        let response = try decoder.decode(GeminiImageResponse.self, from: data)

        if let error = response.error {
            throw GeminiAPIError.serverError
        }

        guard let candidate = response.candidates?.first,
              let imageData = candidate.image.imageData,
              let image = UIImage(data: imageData) else {
            throw GeminiAPIError.noImageGenerated
        }

        if let safetyRatings = candidate.safetyRatings,
           safetyRatings.contains(where: { $0.probability == "HIGH" }) {
            throw GeminiAPIError.contentFiltered
        }

        return image
    }

    private func mapNetworkError(_ error: NetworkUtils.NetworkError) -> GeminiAPIError {
        switch error {
        case .unauthorized:
            return .invalidAPIKey
        case .rateLimited:
            return .quotaExceeded
        case .serverError:
            return .serverError
        case .networkError(let networkError):
            return .networkError(networkError)
        default:
            return .invalidResponse
        }
    }
}

extension GeminiAPIClient {
    func processNailDesign(originalImage: UIImage, design: NailDesign) async throws -> UIImage {
        let prompt = """
        Apply this nail design to the fingernails in the image.
        Keep the hands and fingers exactly as they are, only modify the nail polish/design.
        Make the nail design look natural and well-applied.
        Design style: \(design.name) - \(design.description)
        """

        return try await generateImage(
            prompt: prompt,
            originalImage: originalImage
        )
    }
}