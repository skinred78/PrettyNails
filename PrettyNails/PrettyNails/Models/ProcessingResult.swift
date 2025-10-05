import Foundation
import UIKit

struct ProcessingResult: Identifiable, Codable {
    let id: UUID
    let originalImageData: Data
    let processedImageData: Data?
    let nailDesignId: UUID
    let processingDate: Date
    let status: ProcessingStatus
    let errorMessage: String?

    enum ProcessingStatus: String, Codable, CaseIterable {
        case pending = "pending"
        case processing = "processing"
        case completed = "completed"
        case failed = "failed"

        var displayName: String {
            switch self {
            case .pending: return "Waiting"
            case .processing: return "Processing"
            case .completed: return "Complete"
            case .failed: return "Failed"
            }
        }

        var systemImage: String {
            switch self {
            case .pending: return "clock"
            case .processing: return "gearshape.2"
            case .completed: return "checkmark.circle.fill"
            case .failed: return "xmark.circle.fill"
            }
        }
    }

    init(id: UUID = UUID(), originalImageData: Data, nailDesignId: UUID, status: ProcessingStatus = .pending) {
        self.id = id
        self.originalImageData = originalImageData
        self.processedImageData = nil
        self.nailDesignId = nailDesignId
        self.processingDate = Date()
        self.status = status
        self.errorMessage = nil
    }

    var originalImage: UIImage? {
        UIImage(data: originalImageData)
    }

    var processedImage: UIImage? {
        guard let data = processedImageData else { return nil }
        return UIImage(data: data)
    }

    func updating(status: ProcessingStatus, processedImageData: Data? = nil, errorMessage: String? = nil) -> ProcessingResult {
        ProcessingResult(
            id: self.id,
            originalImageData: self.originalImageData,
            processedImageData: processedImageData ?? self.processedImageData,
            nailDesignId: self.nailDesignId,
            processingDate: self.processingDate,
            status: status,
            errorMessage: errorMessage
        )
    }
}

extension ProcessingResult {
    init(id: UUID, originalImageData: Data, processedImageData: Data?, nailDesignId: UUID, processingDate: Date, status: ProcessingStatus, errorMessage: String?) {
        self.id = id
        self.originalImageData = originalImageData
        self.processedImageData = processedImageData
        self.nailDesignId = nailDesignId
        self.processingDate = processingDate
        self.status = status
        self.errorMessage = errorMessage
    }
}