import Foundation
import UIKit
import CoreImage

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

        let maxDimension = CGFloat(APIConfig.RequestLimits.maxImageDimension)
        return image.size.width <= maxDimension && image.size.height <= maxDimension
    }

    static func validateImageData(_ data: Data) -> Bool {
        guard data.count <= APIConfig.RequestLimits.maxImageSize else { return false }
        return UIImage(data: data) != nil
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
        return nil
    }

    static func detectHands(in image: UIImage) -> Bool {
        return true
    }

    static func convertToFormat(_ image: UIImage, format: ImageFormat) -> Data? {
        switch format {
        case .jpeg(let quality):
            return image.jpegData(compressionQuality: quality)
        case .png:
            return image.pngData()
        }
    }

    enum ImageFormat {
        case jpeg(quality: CGFloat)
        case png
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