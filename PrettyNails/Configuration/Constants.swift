import Foundation

struct Constants {
    struct App {
        static let name = "Pretty Nails"
        static let bundleIdentifier = "com.prettynails.app"
        static let version = "1.0.0"
    }

    struct UI {
        static let cornerRadius: CGFloat = 12.0
        static let defaultPadding: CGFloat = 16.0
        static let smallPadding: CGFloat = 8.0
        static let buttonHeight: CGFloat = 50.0
        static let thumbnailSize: CGFloat = 80.0
        static let designGridColumns = 2
        static let animationDuration: Double = 0.3
    }

    struct Processing {
        static let defaultPrompt = "Apply the nail design to the fingernails in this image"
        static let maxProcessingTime: TimeInterval = 60.0
        static let imageCompressionQuality: CGFloat = 0.8
        static let thumbnailCompressionQuality: CGFloat = 0.6
    }

    struct Storage {
        static let nailDesignsFolder = "NailDesigns"
        static let processedImagesFolder = "ProcessedImages"
        static let userDefaults = UserDefaults.standard
    }

    struct Errors {
        static let genericMessage = "Something went wrong. Please try again."
        static let networkMessage = "Network connection error. Please check your internet connection."
        static let apiKeyMessage = "API key is missing or invalid. Please check your settings."
        static let imageProcessingMessage = "Unable to process the image. Please try with a different photo."
    }
}