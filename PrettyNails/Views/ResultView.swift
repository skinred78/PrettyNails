import SwiftUI

struct ResultView: View {
    let result: ProcessingResult
    @State private var showingShareSheet = false
    @State private var showingSaveAlert = false
    @State private var saveSuccess = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.UI.defaultPadding) {
                    if result.status == .completed {
                        successContent
                    } else {
                        failureContent
                    }
                }
                .padding()
            }
            .navigationTitle("Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                if result.status == .completed {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Share") {
                            showingShareSheet = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let processedImage = result.processedImage {
                ShareSheet(activityItems: [processedImage])
            }
        }
        .alert("Photo Saved", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text(saveSuccess ? "Your nail design has been saved to Photos." : "Failed to save photo.")
        }
    }

    private var successContent: some View {
        VStack(spacing: Constants.UI.defaultPadding * 2) {
            Text("✨ Your Nails Look Amazing!")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            beforeAfterComparison

            actionButtons
        }
    }

    private var failureContent: some View {
        VStack(spacing: Constants.UI.defaultPadding * 2) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            VStack(spacing: 8) {
                Text("Processing Failed")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(result.errorMessage ?? Constants.Errors.genericMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            originalImageOnly

            retryButton
        }
    }

    private var beforeAfterComparison: some View {
        VStack(spacing: Constants.UI.defaultPadding) {
            HStack {
                VStack {
                    Text("Before")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    if let originalImage = result.originalImage {
                        Image(uiImage: originalImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                VStack {
                    Text("After")
                        .font(.headline)
                        .foregroundColor(.accentColor)

                    if let processedImage = result.processedImage {
                        Image(uiImage: processedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .defaultCardStyle()
    }

    private var originalImageOnly: some View {
        VStack(spacing: 8) {
            Text("Original Photo")
                .font(.headline)
                .foregroundColor(.secondary)

            if let originalImage = result.originalImage {
                Image(uiImage: originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .defaultCardStyle()
    }

    private var actionButtons: some View {
        VStack(spacing: Constants.UI.smallPadding) {
            Button("Save to Photos") {
                saveToPhotos()
            }
            .primaryButtonStyle()

            HStack(spacing: Constants.UI.smallPadding) {
                Button("Try Another Design") {
                    presentationMode.wrappedValue.dismiss()
                }
                .secondaryButtonStyle()

                Button("Share") {
                    showingShareSheet = true
                }
                .secondaryButtonStyle()
            }
        }
    }

    private var retryButton: some View {
        Button("Try Again") {
            presentationMode.wrappedValue.dismiss()
        }
        .primaryButtonStyle()
    }

    private func saveToPhotos() {
        guard let processedImage = result.processedImage else { return }

        UIImageWriteToSavedPhotosAlbum(processedImage, nil, nil, nil)
        saveSuccess = true
        showingSaveAlert = true
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

#Preview {
    ResultView(result: ProcessingResult(
        originalImageData: Data(),
        nailDesignId: UUID(),
        status: .completed
    ))
}