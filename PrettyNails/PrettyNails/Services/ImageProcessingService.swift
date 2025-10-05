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
            guard let cgImage = image.cgImage else {
                continuation.resume(returning: false)
                return
            }

            let request = VNDetectHumanHandPoseRequest { request, error in
                if error != nil {
                    continuation.resume(returning: false)
                    return
                }

                let hasHands = !(request.results?.isEmpty ?? true)
                continuation.resume(returning: hasHands)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: false)
            }
        }
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