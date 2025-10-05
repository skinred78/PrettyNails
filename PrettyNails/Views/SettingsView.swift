import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var apiKey = ""
    @State private var showingAPIKeyAlert = false
    @State private var autoSaveResults = true
    @State private var preferredImageQuality = ImageQuality.high
    @Environment(\.presentationMode) var presentationMode

    enum ImageQuality: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"

        var compressionQuality: CGFloat {
            switch self {
            case .low: return 0.3
            case .medium: return 0.6
            case .high: return 0.8
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                apiKeySection
                processingSection
                aboutSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadSettings()
        }
        .alert("API Key", isPresented: $showingAPIKeyAlert) {
            TextField("Enter Gemini API Key", text: $apiKey)
            Button("Save") {
                saveAPIKey()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter your Google Gemini API key to enable nail design processing.")
        }
    }

    private var apiKeySection: some View {
        Section(header: Text("API Configuration")) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Gemini API Key")
                        .font(.subheadline)

                    Text(appState.hasSetupAPIKey ? "Configured" : "Not Set")
                        .font(.caption)
                        .foregroundColor(appState.hasSetupAPIKey ? .green : .red)
                }

                Spacer()

                Button(appState.hasSetupAPIKey ? "Update" : "Set") {
                    showingAPIKeyAlert = true
                }
                .foregroundColor(.accentColor)
            }

            if !appState.hasSetupAPIKey {
                VStack(alignment: .leading, spacing: 4) {
                    Text("⚠️ API Key Required")
                        .font(.caption)
                        .foregroundColor(.orange)

                    Text("You need a Gemini API key to process nail designs. Get yours from Google AI Studio.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Button("How to get API key") {
                if let url = URL(string: "https://ai.google.dev/gemini-api/docs/api-key") {
                    UIApplication.shared.open(url)
                }
            }
            .foregroundColor(.accentColor)
        }
    }

    private var processingSection: some View {
        Section(header: Text("Processing Options")) {
            Toggle("Auto-save Results", isOn: $autoSaveResults)
                .onChange(of: autoSaveResults) { value in
                    UserDefaults.standard.set(value, for: .autoSaveResults)
                }

            Picker("Image Quality", selection: $preferredImageQuality) {
                ForEach(ImageQuality.allCases, id: \.self) { quality in
                    Text(quality.rawValue).tag(quality)
                }
            }
            .onChange(of: preferredImageQuality) { quality in
                UserDefaults.standard.set(quality.rawValue, for: .preferredImageQuality)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Processing Tips")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("• Use well-lit photos for best results\n• Ensure hands are clearly visible\n• Higher quality takes more time to process")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var aboutSection: some View {
        Section(header: Text("About")) {
            HStack {
                Text("Version")
                Spacer()
                Text(Constants.App.version)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Privacy Policy")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
            }

            HStack {
                Text("Terms of Service")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
            }

            Button("Contact Support") {
                if let url = URL(string: "mailto:support@prettynails.com") {
                    UIApplication.shared.open(url)
                }
            }
            .foregroundColor(.accentColor)
        }
    }

    private func loadSettings() {
        apiKey = APIKeyManager.shared.geminiAPIKey ?? ""
        autoSaveResults = UserDefaults.standard.value(for: .autoSaveResults, type: Bool.self) ?? true

        if let qualityString = UserDefaults.standard.value(for: .preferredImageQuality, type: String.self),
           let quality = ImageQuality(rawValue: qualityString) {
            preferredImageQuality = quality
        }
    }

    private func saveAPIKey() {
        guard !apiKey.isEmpty, apiKey.isValidAPIKey() else {
            appState.setError("Please enter a valid API key")
            return
        }

        APIKeyManager.shared.geminiAPIKey = apiKey
        appState.checkAPIKeySetup()
        appState.clearError()
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}