import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)

            NailDesignSelectionView()
                .tabItem {
                    Image(systemName: "paintbrush")
                    Text("Designs")
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(3)
        }
        .environmentObject(appState)
        .sheet(isPresented: $appState.showingSettings) {
            SettingsView()
                .environmentObject(appState)
        }
        .alert("Error", isPresented: .constant(appState.errorMessage != nil)) {
            Button("OK") {
                appState.clearError()
            }
        } message: {
            Text(appState.errorMessage ?? "")
        }
        .onAppear {
            setupInitialState()
        }
    }

    private func setupInitialState() {
        appState.checkAPIKeySetup()
    }
}

struct HistoryView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationView {
            VStack {
                if appState.processingResults.isEmpty {
                    EmptyStateView(
                        title: "No History",
                        message: "Your nail design results will appear here",
                        systemImage: "clock"
                    )
                } else {
                    List(appState.recentResults) { result in
                        HistoryRowView(result: result)
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

struct HistoryRowView: View {
    let result: ProcessingResult

    var body: some View {
        HStack {
            if let originalImage = result.originalImage {
                Image(uiImage: originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(result.status.displayName)
                    .font(.headline)
                Text(result.processingDate.timeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: result.status.systemImage)
                .foregroundColor(colorForStatus(result.status))
        }
        .padding(.vertical, 4)
    }

    private func colorForStatus(_ status: ProcessingResult.ProcessingStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .failed: return .red
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}