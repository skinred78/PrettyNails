import SwiftUI

struct ProcessingView: View {
    let originalImage: UIImage
    let nailDesign: NailDesign
    @State private var progress: Double = 0.0
    @State private var currentStep = ProcessingStep.preparing
    @Environment(\.presentationMode) var presentationMode

    enum ProcessingStep: String, CaseIterable {
        case preparing = "Preparing image..."
        case analyzing = "Analyzing hand structure..."
        case generating = "Applying nail design..."
        case finalizing = "Finalizing result..."

        var progress: Double {
            switch self {
            case .preparing: return 0.25
            case .analyzing: return 0.5
            case .generating: return 0.75
            case .finalizing: return 1.0
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: Constants.UI.defaultPadding * 2) {
                Spacer()

                progressSection

                imagePreview

                designInfo

                Spacer()

                cancelButton
            }
            .padding()
            .navigationTitle("Processing")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            startProcessingAnimation()
        }
    }

    private var progressSection: some View {
        VStack(spacing: Constants.UI.defaultPadding) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)

                    Text("\(Int(progress * 100))%")
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }

            Text(currentStep.rawValue)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var imagePreview: some View {
        HStack(spacing: Constants.UI.defaultPadding) {
            VStack {
                Text("Original")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Image(uiImage: originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Image(systemName: "arrow.right")
                .font(.title2)
                .foregroundColor(.secondary)

            VStack {
                Text("With Design")
                    .font(.caption)
                    .foregroundColor(.secondary)

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    )
            }
        }
    }

    private var designInfo: some View {
        VStack(spacing: 8) {
            Text("Applying Design")
                .font(.headline)

            HStack {
                nailDesign.thumbnailImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(nailDesign.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(nailDesign.category.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .defaultCardStyle()
        }
    }

    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
        .secondaryButtonStyle()
    }

    private func startProcessingAnimation() {
        let steps = ProcessingStep.allCases
        var currentIndex = 0

        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.5)) {
                if currentIndex < steps.count {
                    currentStep = steps[currentIndex]
                    progress = currentStep.progress
                    currentIndex += 1
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}

#Preview {
    ProcessingView(
        originalImage: UIImage(systemName: "photo") ?? UIImage(),
        nailDesign: NailDesign.sampleDesigns[0]
    )
}