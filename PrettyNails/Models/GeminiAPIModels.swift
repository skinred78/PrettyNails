import Foundation

struct GeminiImageRequest: Codable {
    let prompt: String
    let image: ImageData
    let mask: ImageData?
    let numImages: Int
    let aspectRatio: String
    let safetySettings: [SafetySetting]

    struct ImageData: Codable {
        let data: String
        let mimeType: String

        init(data: Data, mimeType: String) {
            self.data = data.base64EncodedString()
            self.mimeType = mimeType
        }
    }

    struct SafetySetting: Codable {
        let category: String
        let threshold: String
    }

    init(prompt: String, imageData: Data, maskData: Data? = nil, numImages: Int = 1) {
        self.prompt = prompt
        self.image = ImageData(data: imageData, mimeType: "image/jpeg")
        self.mask = maskData != nil ? ImageData(data: maskData!, mimeType: "image/jpeg") : nil
        self.numImages = numImages
        self.aspectRatio = "1:1"
        self.safetySettings = [
            SafetySetting(category: "HARM_CATEGORY_HATE_SPEECH", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
            SafetySetting(category: "HARM_CATEGORY_DANGEROUS_CONTENT", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
            SafetySetting(category: "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold: "BLOCK_MEDIUM_AND_ABOVE"),
            SafetySetting(category: "HARM_CATEGORY_HARASSMENT", threshold: "BLOCK_MEDIUM_AND_ABOVE")
        ]
    }
}

struct GeminiImageResponse: Codable {
    let candidates: [ImageCandidate]?
    let error: APIError?

    struct ImageCandidate: Codable {
        let image: GeneratedImage
        let finishReason: String?
        let safetyRatings: [SafetyRating]?

        struct GeneratedImage: Codable {
            let data: String
            let mimeType: String

            var imageData: Data? {
                Data(base64Encoded: data)
            }
        }

        struct SafetyRating: Codable {
            let category: String
            let probability: String
        }
    }

    struct APIError: Codable, Error {
        let code: Int
        let message: String
        let status: String

        var localizedDescription: String {
            return message
        }
    }
}

enum GeminiAPIError: Error, LocalizedError {
    case invalidAPIKey
    case invalidRequest
    case quotaExceeded
    case serverError
    case networkError(Error)
    case invalidResponse
    case noImageGenerated
    case contentFiltered

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "Invalid API key"
        case .invalidRequest:
            return "Invalid request"
        case .quotaExceeded:
            return "API quota exceeded"
        case .serverError:
            return "Server error"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .noImageGenerated:
            return "No image was generated"
        case .contentFiltered:
            return "Content was filtered for safety"
        }
    }
}