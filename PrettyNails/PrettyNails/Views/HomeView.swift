import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingPhotoOptions = false
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: Constants.UI.defaultPadding) {
                headerSection

                if let currentImage = appState.currentImage {
                    selectedImageSection(currentImage)
                } else {
                    photoSelectionSection
                }

                if appState.selectedNailDesign != nil && appState.currentImage != nil {
                    processButton
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Pretty Nails")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        appState.showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .confirmationDialog("Select Photo", isPresented: $showingPhotoOptions) {
            Button("Camera") {
                showingCamera = true
            }
            Button("Photo Library") {
                showingPhotoPicker = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingCamera) {
            PhotoCaptureView { image in
                appState.setCurrentImage(image)
            }
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerView { image in
                appState.setCurrentImage(image)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Transform Your Nails")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Take a photo and see how nail designs look on your hands")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var photoSelectionSection: some View {
        VStack(spacing: Constants.UI.defaultPadding) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Button("Select Photo") {
                showingPhotoOptions = true
            }
            .primaryButtonStyle()
        }
        .padding()
        .defaultCardStyle()
    }

    private func selectedImageSection(_ image: UIImage) -> some View {
        VStack(spacing: Constants.UI.defaultPadding) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
                .clipShape(RoundedRectangle(cornerRadius: Constants.UI.cornerRadius))

            HStack {
                Button("Change Photo") {
                    showingPhotoOptions = true
                }
                .secondaryButtonStyle()

                Button("Clear") {
                    appState.setCurrentImage(nil)
                }
                .secondaryButtonStyle()
            }
        }
        .defaultCardStyle()
    }

    private var processButton: some View {
        Button("Apply Nail Design") {
            guard let image = appState.currentImage,
                  let design = appState.selectedNailDesign else { return }

            appState.startProcessing(with: image, design: design)
        }
        .primaryButtonStyle()
        .disabled(!appState.canStartProcessing)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}