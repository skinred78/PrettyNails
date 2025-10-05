import Foundation
import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var selectedNailDesign: NailDesign?
    @Published var currentImage: UIImage?
    @Published var processingResults: [ProcessingResult] = []
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var showingSettings: Bool = false
    @Published var hasSetupAPIKey: Bool = false

    private let apiKeyManager = APIKeyManager.shared

    init() {
        checkAPIKeySetup()
    }

    func checkAPIKeySetup() {
        hasSetupAPIKey = apiKeyManager.geminiAPIKey != nil
    }

    func selectNailDesign(_ design: NailDesign) {
        selectedNailDesign = design
    }

    func setCurrentImage(_ image: UIImage?) {
        currentImage = image
    }

    func startProcessing(with image: UIImage, design: NailDesign) {
        guard let imageData = image.jpegData(compressionQuality: Constants.Processing.imageCompressionQuality) else {
            setError("Failed to process image data")
            return
        }

        let result = ProcessingResult(
            originalImageData: imageData,
            nailDesignId: design.id,
            status: .pending
        )

        processingResults.append(result)
        isProcessing = true
        clearError()
    }

    func updateProcessingResult(_ result: ProcessingResult) {
        if let index = processingResults.firstIndex(where: { $0.id == result.id }) {
            processingResults[index] = result
        }

        if result.status == .completed || result.status == .failed {
            isProcessing = false
        }
    }

    func setError(_ message: String) {
        errorMessage = message
    }

    func clearError() {
        errorMessage = nil
    }

    func clearCurrentSession() {
        selectedNailDesign = nil
        currentImage = nil
        clearError()
    }

    func deleteProcessingResult(_ result: ProcessingResult) {
        processingResults.removeAll { $0.id == result.id }
    }

    var canStartProcessing: Bool {
        return currentImage != nil && selectedNailDesign != nil && !isProcessing && hasSetupAPIKey
    }

    var recentResults: [ProcessingResult] {
        return processingResults
            .sorted { $0.processingDate > $1.processingDate }
            .prefix(10)
            .map { $0 }
    }
}