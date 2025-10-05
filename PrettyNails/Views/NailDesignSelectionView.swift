import SwiftUI

struct NailDesignSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: NailDesign.Category?
    @State private var searchText = ""

    private let gridColumns = Array(repeating: GridItem(.flexible()), count: Constants.UI.designGridColumns)

    var body: some View {
        NavigationView {
            VStack {
                searchBar
                categoryFilter
                designGrid
            }
            .navigationTitle("Nail Designs")
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search designs...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                CategoryButton(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(NailDesign.Category.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var designGrid: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: Constants.UI.defaultPadding) {
                ForEach(filteredDesigns) { design in
                    DesignCard(design: design, isSelected: appState.selectedNailDesign?.id == design.id) {
                        appState.selectNailDesign(design)
                    }
                }
            }
            .padding()
        }
    }

    private var filteredDesigns: [NailDesign] {
        var designs = NailDesign.sampleDesigns

        if let category = selectedCategory {
            designs = designs.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            designs = designs.filter { design in
                design.name.localizedCaseInsensitiveContains(searchText) ||
                design.description.localizedCaseInsensitiveContains(searchText) ||
                design.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return designs
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct DesignCard: View {
    let design: NailDesign
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                design.thumbnailImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(design.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)

                    HStack {
                        Image(systemName: design.category.icon)
                            .font(.caption)
                        Text(design.category.displayName)
                            .font(.caption)
                        Spacer()
                        if design.isPopular {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .defaultCardStyle()
    }
}

#Preview {
    NailDesignSelectionView()
        .environmentObject(AppState())
}