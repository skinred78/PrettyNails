import Foundation
import SwiftUI

class NailDesignManager: ObservableObject {
    static let shared = NailDesignManager()

    @Published var availableDesigns: [NailDesign] = []
    @Published var featuredDesigns: [NailDesign] = []
    @Published var isLoading = false

    private init() {
        loadDesigns()
    }

    func loadDesigns() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.availableDesigns = self.loadSampleDesigns()
            self.featuredDesigns = self.availableDesigns.filter { $0.isPopular }
            self.isLoading = false
        }
    }

    func refreshDesigns() {
        loadDesigns()
    }

    func getDesign(by id: UUID) -> NailDesign? {
        return availableDesigns.first { $0.id == id }
    }

    func getDesigns(in category: NailDesign.Category) -> [NailDesign] {
        return availableDesigns.filter { $0.category == category }
    }

    func searchDesigns(query: String) -> [NailDesign] {
        guard !query.isEmpty else { return availableDesigns }

        return availableDesigns.filter { design in
            design.name.localizedCaseInsensitiveContains(query) ||
            design.description.localizedCaseInsensitiveContains(query) ||
            design.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    func addCustomDesign(_ design: NailDesign) {
        availableDesigns.append(design)
    }

    func removeDesign(_ design: NailDesign) {
        availableDesigns.removeAll { $0.id == design.id }
        featuredDesigns.removeAll { $0.id == design.id }
    }

    private func loadSampleDesigns() -> [NailDesign] {
        return [
            NailDesign(
                name: "Classic Red",
                description: "Timeless red polish for any occasion",
                imageName: "classic_red",
                category: .classic,
                tags: ["red", "classic", "elegant"],
                isPopular: true
            ),
            NailDesign(
                name: "French Manicure",
                description: "Traditional French tips with white and nude",
                imageName: "french_manicure",
                category: .classic,
                tags: ["french", "white", "nude", "professional"],
                isPopular: true
            ),
            NailDesign(
                name: "Sunset Ombre",
                description: "Beautiful gradient from orange to pink",
                imageName: "sunset_ombre",
                category: .modern,
                tags: ["ombre", "gradient", "sunset", "colorful"],
                isPopular: false
            ),
            NailDesign(
                name: "Floral Garden",
                description: "Delicate flower patterns on pastel base",
                imageName: "floral_garden",
                category: .artistic,
                tags: ["floral", "flowers", "pastel", "spring"],
                isPopular: true
            ),
            NailDesign(
                name: "Geometric Lines",
                description: "Modern geometric patterns in black and white",
                imageName: "geometric_lines",
                category: .modern,
                tags: ["geometric", "lines", "black", "white", "modern"],
                isPopular: false
            ),
            NailDesign(
                name: "Winter Snowflakes",
                description: "Sparkly snowflake designs on blue base",
                imageName: "winter_snowflakes",
                category: .seasonal,
                tags: ["winter", "snowflakes", "blue", "sparkly"],
                isPopular: false
            ),
            NailDesign(
                name: "Rose Gold Glitter",
                description: "Elegant rose gold with fine glitter",
                imageName: "rose_gold_glitter",
                category: .wedding,
                tags: ["rose gold", "glitter", "elegant", "wedding"],
                isPopular: true
            ),
            NailDesign(
                name: "Beach Vibes",
                description: "Ocean-inspired blues and whites",
                imageName: "beach_vibes",
                category: .casual,
                tags: ["beach", "ocean", "blue", "white", "summer"],
                isPopular: false
            ),
            NailDesign(
                name: "Marble Effect",
                description: "Sophisticated marble pattern in gray and white",
                imageName: "marble_effect",
                category: .modern,
                tags: ["marble", "gray", "white", "sophisticated"],
                isPopular: true
            ),
            NailDesign(
                name: "Autumn Leaves",
                description: "Fall-inspired orange and brown leaf patterns",
                imageName: "autumn_leaves",
                category: .seasonal,
                tags: ["autumn", "fall", "leaves", "orange", "brown"],
                isPopular: false
            )
        ]
    }

    var categorizedDesigns: [NailDesign.Category: [NailDesign]] {
        Dictionary(grouping: availableDesigns) { $0.category }
    }

    var popularDesigns: [NailDesign] {
        availableDesigns.filter { $0.isPopular }
    }

    var recentDesigns: [NailDesign] {
        availableDesigns.sorted { $0.createdDate > $1.createdDate }.prefix(5).map { $0 }
    }
}

extension NailDesignManager {
    func preloadDesignImages() {
        for design in availableDesigns {
            let _ = design.thumbnailImage
        }
    }

    func generateDesignThumbnail(for design: NailDesign) -> Image? {
        return Image(design.imageName)
    }
}