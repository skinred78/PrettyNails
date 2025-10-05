import Foundation
import UIKit
import Vision

class ImageProcessingService {
    static let shared = ImageProcessingService()

    private init() {}

    func validateAndPrepareImage(_ image: UIImage) async -> Result<UIImage, ImageProcessingError> {
        guard ImageUtils.validateImage(image) else {
            return .failure(.invalidImage)
        }

        let hasHands = await detectHands(in: image)
        guard hasHands else {
            return .failure(.noHandsDetected)
        }

        guard let optimizedImage = ImageUtils.optimizeImageForAPI(image) else {
            return .failure(.processingFailed)
        }

        return .success(optimizedImage)
    }

    func processImage(_ image: UIImage, with design: NailDesign) async -> Result<ProcessingResult, ImageProcessingError> {
        let prepareResult = await validateAndPrepareImage(image)

        switch prepareResult {
        case .success(let processedImage):
            guard let imageData = processedImage.compressed() else {
                return .failure(.processingFailed)
            }

            let result = ProcessingResult(
                originalImageData: imageData,
                nailDesignId: design.id,
                status: .processing
            )

            do {
                let finalImage = try await GeminiAPIClient.shared.processNailDesign(
                    originalImage: processedImage,
                    design: design
                )

                guard let finalImageData = finalImage.compressed() else {
                    return .failure(.processingFailed)
                }

                let completedResult = result.updating(
                    status: .completed,
                    processedImageData: finalImageData
                )

                return .success(completedResult)

            } catch {
                let failedResult = result.updating(
                    status: .failed,
                    errorMessage: error.localizedDescription
                )
                return .failure(.apiError(error))
            }

        case .failure(let error):
            return .failure(error)
        }
    }

    private func detectHands(in image: UIImage) async -> Bool {
        return await withCheckedContinuation { continuation in
            ImageUtils.detectHands(in: image) { hasHands, observations in
                continuation.resume(returning: hasHands)
            }
        }
    }

    func enhanceImageForProcessing(_ image: UIImage) -> UIImage? {
        guard let normalizedImage = ImageUtils.normalizeImageOrientation(image) else {
            return nil
        }

        guard let enhancedImage = ImageUtils.enhanceImage(normalizedImage) else {
            return normalizedImage
        }

        return ImageUtils.cropToHands(enhancedImage)
    }

    func generateNailMask(for image: UIImage) -> UIImage? {
        return ImageUtils.createNailMask(for: image)
    }

    func analyzeImageQuality(_ image: UIImage) -> ImageQualityAnalysis {
        var issues: [ImageQualityIssue] = []
        let nailAreas = ImageUtils.detectNailAreas(in: image)

        if nailAreas.isEmpty {
            issues.append(.noNailsDetected)
        }

        if image.size.width < 512 || image.size.height < 512 {
            issues.append(.lowResolution)
        }

        if !ImageUtils.validateImage(image) {
            issues.append(.invalidFormat)
        }

        let score = calculateQualityScore(for: image, issues: issues)

        return ImageQualityAnalysis(
            score: score,
            issues: issues,
            detectedNailAreas: nailAreas,
            recommendations: generateRecommendations(for: issues)
        )
    }

    private func calculateQualityScore(for image: UIImage, issues: [ImageQualityIssue]) -> Double {
        var score = 1.0

        for issue in issues {
            switch issue {
            case .noNailsDetected:
                score -= 0.5
            case .lowResolution:
                score -= 0.2
            case .invalidFormat:
                score -= 0.3
            case .poorLighting:
                score -= 0.1
            case .blurry:
                score -= 0.2
            }
        }

        return max(0.0, score)
    }

    private func generateRecommendations(for issues: [ImageQualityIssue]) -> [String] {
        var recommendations: [String] = []

        for issue in issues {
            switch issue {
            case .noNailsDetected:
                recommendations.append("Ensure your hands are clearly visible in the photo")
            case .lowResolution:
                recommendations.append("Use a higher resolution camera or move closer to your hands")
            case .invalidFormat:
                recommendations.append("Please use a JPEG or PNG image")
            case .poorLighting:
                recommendations.append("Take the photo in better lighting conditions")
            case .blurry:
                recommendations.append("Hold the camera steady when taking the photo")
            }
        }

        return recommendations
    }

    func createNailMask(for image: UIImage) -> UIImage? {
        return nil
    }

    func enhanceImage(_ image: UIImage) -> UIImage? {
        return image
    }

    enum ImageProcessingError: Error, LocalizedError {
        case invalidImage
        case noHandsDetected
        case processingFailed
        case apiError(Error)
        case unsupportedFormat
        case imageTooLarge
        case imageTooSmall
        case visionFrameworkError(Error)
        case compressionFailed

        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "The selected image is not valid"
            case .noHandsDetected:
                return "No hands detected in the image. Please use a photo showing your hands clearly."
            case .processingFailed:
                return "Failed to process the image"
            case .apiError(let error):
                return "API Error: \(error.localizedDescription)"
            case .unsupportedFormat:
                return "Image format is not supported"
            case .imageTooLarge:
                return "Image is too large. Please use a smaller image."
            case .imageTooSmall:
                return "Image is too small. Please use a higher resolution image."
            case .visionFrameworkError(let error):
                return "Vision analysis failed: \(error.localizedDescription)"
            case .compressionFailed:
                return "Failed to compress image for processing"
            }
        }

        var recoverySuggestion: String? {
            switch self {
            case .invalidImage:
                return "Try selecting a different image"
            case .noHandsDetected:
                return "Make sure your hands are clearly visible and well-lit in the photo"
            case .processingFailed:
                return "Try again with a different photo"
            case .apiError:
                return "Check your internet connection and try again"
            case .unsupportedFormat:
                return "Use a JPEG or PNG image"
            case .imageTooLarge:
                return "Resize the image or take a new photo"
            case .imageTooSmall:
                return "Use a higher resolution camera or move closer"
            case .visionFrameworkError:
                return "Try with a clearer photo of your hands"
            case .compressionFailed:
                return "Try with a different image"
            }
        }
    }

    struct ImageQualityAnalysis {
        let score: Double
        let issues: [ImageQualityIssue]
        let detectedNailAreas: [CGRect]
        let recommendations: [String]

        var isAcceptable: Bool {
            return score >= 0.6
        }

        var qualityLevel: QualityLevel {
            switch score {
            case 0.8...1.0:
                return .excellent
            case 0.6..<0.8:
                return .good
            case 0.4..<0.6:
                return .fair
            default:
                return .poor
            }
        }
    }

    enum ImageQualityIssue {
        case noNailsDetected
        case lowResolution
        case invalidFormat
        case poorLighting
        case blurry

        var priority: Int {
            switch self {
            case .noNailsDetected: return 1
            case .invalidFormat: return 2
            case .lowResolution: return 3
            case .blurry: return 4
            case .poorLighting: return 5
            }
        }
    }

    enum QualityLevel: String, CaseIterable {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case poor = "Poor"

        var color: UIColor {
            switch self {
            case .excellent: return .systemGreen
            case .good: return .systemBlue
            case .fair: return .systemOrange
            case .poor: return .systemRed
            }
        }
    }
}

extension ImageProcessingService {
    func batchProcessImages(_ images: [UIImage], with design: NailDesign) async -> [ProcessingResult] {
        var results: [ProcessingResult] = []

        for image in images {
            let result = await processImage(image, with: design)
            switch result {
            case .success(let processingResult):
                results.append(processingResult)
            case .failure(let error):
                let failedResult = ProcessingResult(
                    originalImageData: image.compressed() ?? Data(),
                    nailDesignId: design.id,
                    status: .failed
                ).updating(
                    status: .failed,
                    errorMessage: error.localizedDescription
                )
                results.append(failedResult)
            }
        }

        return results
    }
}