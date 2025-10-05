import Foundation
import UIKit
import CoreImage
import Vision

struct ImageUtils {
    static func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    static func compressImage(_ image: UIImage, quality: CGFloat = 0.8) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }

    static func createThumbnail(from image: UIImage, size: CGFloat = Constants.UI.thumbnailSize) -> UIImage? {
        let thumbnailSize = CGSize(width: size, height: size)
        return resizeImage(image, to: thumbnailSize)
    }

    static func validateImage(_ image: UIImage) -> Bool {
        guard image.size.width > 0 && image.size.height > 0 else { return false }
        guard image.cgImage != nil else { return false }

        let minDimension: CGFloat = 256
        let maxDimension = CGFloat(APIConfig.RequestLimits.maxImageDimension)

        let width = image.size.width
        let height = image.size.height

        return width >= minDimension && height >= minDimension &&
               width <= maxDimension && height <= maxDimension
    }

    static func validateImageData(_ data: Data) -> Bool {
        guard data.count > 0 else { return false }
        guard data.count <= APIConfig.RequestLimits.maxImageSize else { return false }
        guard let image = UIImage(data: data) else { return false }
        return validateImage(image)
    }

    static func validateImageFormat(_ data: Data) -> ImageFormat? {
        guard data.count >= 12 else { return nil }

        let bytes = data.prefix(12)
        let byteArray = [UInt8](bytes)

        if byteArray[0] == 0xFF && byteArray[1] == 0xD8 && byteArray[2] == 0xFF {
            return .jpeg(quality: 0.8)
        }

        if byteArray[0] == 0x89 && byteArray[1] == 0x50 && byteArray[2] == 0x4E && byteArray[3] == 0x47 {
            return .png
        }

        return nil
    }

    static func optimizeImageForAPI(_ image: UIImage) -> UIImage? {
        let maxDimension = CGFloat(APIConfig.RequestLimits.maxImageDimension)

        if image.size.width <= maxDimension && image.size.height <= maxDimension {
            return image
        }

        let scale = min(maxDimension / image.size.width, maxDimension / image.size.height)
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        return resizeImage(image, to: newSize)
    }

    static func createNailMask(for image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))

        let handPoseRequest = VNDetectHumanHandPoseRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([handPoseRequest])

            if let observations = handPoseRequest.results {
                context.setFillColor(UIColor.white.cgColor)

                for observation in observations {
                    let fingerTipKeys: [VNHumanHandPoseObservation.JointName] = [
                        .thumbTip, .indexTip, .middleTip, .ringTip, .littleTip
                    ]

                    for fingerTip in fingerTipKeys {
                        if let point = try? observation.recognizedPoint(fingerTip),
                           point.confidence > 0.3 {

                            let convertedPoint = CGPoint(
                                x: point.location.x * imageSize.width,
                                y: (1 - point.location.y) * imageSize.height
                            )

                            let nailSize: CGFloat = 15.0
                            let nailRect = CGRect(
                                x: convertedPoint.x - nailSize/2,
                                y: convertedPoint.y - nailSize/2,
                                width: nailSize,
                                height: nailSize
                            )

                            context.fillEllipse(in: nailRect)
                        }
                    }
                }
            }
        } catch {
            print("Hand pose detection failed: \(error)")
        }

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    static func detectHands(in image: UIImage, completion: @escaping (Bool, [VNHumanHandPoseObservation]?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(false, nil)
            return
        }

        let request = VNDetectHumanHandPoseRequest { request, error in
            if let error = error {
                print("Hand detection error: \(error)")
                completion(false, nil)
                return
            }

            let observations = request.results as? [VNHumanHandPoseObservation]
            let hasHands = !(observations?.isEmpty ?? true)
            completion(hasHands, observations)
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Hand detection failed: \(error)")
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }
    }

    static func detectNailAreas(in image: UIImage) -> [CGRect] {
        guard let cgImage = image.cgImage else { return [] }

        var nailAreas: [CGRect] = []
        let request = VNDetectHumanHandPoseRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])

            if let observations = request.results {
                let imageSize = CGSize(width: cgImage.width, height: cgImage.height)

                for observation in observations {
                    let fingerTipKeys: [VNHumanHandPoseObservation.JointName] = [
                        .thumbTip, .indexTip, .middleTip, .ringTip, .littleTip
                    ]

                    for fingerTip in fingerTipKeys {
                        if let point = try? observation.recognizedPoint(fingerTip),
                           point.confidence > 0.5 {

                            let convertedPoint = CGPoint(
                                x: point.location.x * imageSize.width,
                                y: (1 - point.location.y) * imageSize.height
                            )

                            let nailSize: CGFloat = 20.0
                            let nailRect = CGRect(
                                x: convertedPoint.x - nailSize/2,
                                y: convertedPoint.y - nailSize/2,
                                width: nailSize,
                                height: nailSize
                            )

                            nailAreas.append(nailRect)
                        }
                    }
                }
            }
        } catch {
            print("Nail area detection failed: \(error)")
        }

        return nailAreas
    }

    static func convertToFormat(_ image: UIImage, format: ImageFormat) -> Data? {
        switch format {
        case .jpeg(let quality):
            return image.jpegData(compressionQuality: quality)
        case .png:
            return image.pngData()
        }
    }

    static func enhanceImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let context = CIContext()
        let ciImage = CIImage(cgImage: cgImage)

        guard let exposureFilter = CIFilter(name: "CIExposureAdjust") else { return image }
        exposureFilter.setValue(ciImage, forKey: kCIInputImageKey)
        exposureFilter.setValue(0.2, forKey: kCIInputEVKey)

        guard let saturationFilter = CIFilter(name: "CIColorControls") else { return image }
        saturationFilter.setValue(exposureFilter.outputImage, forKey: kCIInputImageKey)
        saturationFilter.setValue(1.1, forKey: kCIInputSaturationKey)

        guard let sharpenFilter = CIFilter(name: "CIUnsharpMask") else { return image }
        sharpenFilter.setValue(saturationFilter.outputImage, forKey: kCIInputImageKey)
        sharpenFilter.setValue(0.5, forKey: kCIInputIntensityKey)

        guard let outputImage = sharpenFilter.outputImage,
              let enhancedCGImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return image
        }

        return UIImage(cgImage: enhancedCGImage)
    }

    static func cropToHands(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let request = VNDetectHumanHandPoseRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])

            guard let observations = request.results, !observations.isEmpty else {
                return image
            }

            let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
            var boundingBox = CGRect.null

            for observation in observations {
                let allPoints = observation.availableJointNames.compactMap { jointName in
                    try? observation.recognizedPoint(jointName)
                }.filter { $0.confidence > 0.3 }

                guard !allPoints.isEmpty else { continue }

                let minX = allPoints.map { $0.location.x }.min() ?? 0
                let maxX = allPoints.map { $0.location.x }.max() ?? 1
                let minY = allPoints.map { $0.location.y }.min() ?? 0
                let maxY = allPoints.map { $0.location.y }.max() ?? 1

                let handBounds = CGRect(
                    x: minX * imageSize.width,
                    y: (1 - maxY) * imageSize.height,
                    width: (maxX - minX) * imageSize.width,
                    height: (maxY - minY) * imageSize.height
                )

                boundingBox = boundingBox.isNull ? handBounds : boundingBox.union(handBounds)
            }

            let expandedBounds = boundingBox.insetBy(dx: -boundingBox.width * 0.1, dy: -boundingBox.height * 0.1)
            let clampedBounds = expandedBounds.intersection(CGRect(origin: .zero, size: imageSize))

            guard let croppedCGImage = cgImage.cropping(to: clampedBounds) else {
                return image
            }

            return UIImage(cgImage: croppedCGImage)

        } catch {
            print("Hand cropping failed: \(error)")
            return image
        }
    }

    static func normalizeImageOrientation(_ image: UIImage) -> UIImage? {
        guard image.imageOrientation != .up else { return image }

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: CGRect(origin: .zero, size: image.size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    enum ImageFormat {
        case jpeg(quality: CGFloat)
        case png

        var fileExtension: String {
            switch self {
            case .jpeg: return "jpg"
            case .png: return "png"
            }
        }

        var mimeType: String {
            switch self {
            case .jpeg: return "image/jpeg"
            case .png: return "image/png"
            }
        }
    }

    enum ImageProcessingError: Error, LocalizedError {
        case invalidInput
        case processingFailed
        case unsupportedFormat
        case visionFrameworkError(Error)

        var errorDescription: String? {
            switch self {
            case .invalidInput:
                return "Invalid image input"
            case .processingFailed:
                return "Image processing failed"
            case .unsupportedFormat:
                return "Unsupported image format"
            case .visionFrameworkError(let error):
                return "Vision framework error: \(error.localizedDescription)"
            }
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        return ImageUtils.resizeImage(self, to: size)
    }

    func optimizedForAPI() -> UIImage? {
        return ImageUtils.optimizeImageForAPI(self)
    }

    func compressed(quality: CGFloat = 0.8) -> Data? {
        return ImageUtils.compressImage(self, quality: quality)
    }
}