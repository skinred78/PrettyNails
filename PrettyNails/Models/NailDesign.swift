import Foundation
import SwiftUI

struct NailDesign: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let imageName: String
    let category: Category
    let tags: [String]
    let isPopular: Bool
    let createdDate: Date

    enum Category: String, CaseIterable, Codable {
        case classic = "Classic"
        case modern = "Modern"
        case artistic = "Artistic"
        case seasonal = "Seasonal"
        case wedding = "Wedding"
        case casual = "Casual"

        var displayName: String {
            return rawValue
        }

        var icon: String {
            switch self {
            case .classic: return "star.fill"
            case .modern: return "sparkles"
            case .artistic: return "paintbrush.fill"
            case .seasonal: return "leaf.fill"
            case .wedding: return "heart.fill"
            case .casual: return "sun.max.fill"
            }
        }
    }

    init(id: UUID = UUID(), name: String, description: String, imageName: String, category: Category, tags: [String] = [], isPopular: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.imageName = imageName
        self.category = category
        self.tags = tags
        self.isPopular = isPopular
        self.createdDate = Date()
    }

    var thumbnailImage: Image {
        Image(imageName)
    }

    static var sampleDesigns: [NailDesign] {
        return [
            NailDesign(name: "Classic Red", description: "Timeless red polish", imageName: "classic_red", category: .classic, isPopular: true),
            NailDesign(name: "French Manicure", description: "Traditional French tips", imageName: "french_manicure", category: .classic, isPopular: true),
            NailDesign(name: "Sunset Ombre", description: "Beautiful gradient effect", imageName: "sunset_ombre", category: .modern),
            NailDesign(name: "Floral Art", description: "Delicate flower patterns", imageName: "floral_art", category: .artistic)
        ]
    }
}