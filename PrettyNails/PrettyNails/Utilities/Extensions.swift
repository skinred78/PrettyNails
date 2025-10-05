import Foundation
import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    func defaultCardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(Constants.UI.cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    func primaryButtonStyle() -> some View {
        self
            .frame(height: Constants.UI.buttonHeight)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(Constants.UI.cornerRadius)
    }

    func secondaryButtonStyle() -> some View {
        self
            .frame(height: Constants.UI.buttonHeight)
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(Constants.UI.cornerRadius)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension Color {
    static let primaryBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let separator = Color(.separator)
}

extension UIImage {
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)

        return self.resized(to: newSize) ?? self
    }

    func aspectFittedToWidth(_ newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)

        return self.resized(to: newSize) ?? self
    }
}

extension Data {
    var prettyPrintedSize: String {
        let bytes = Double(self.count)
        let kilobytes = bytes / 1024
        let megabytes = kilobytes / 1024

        if megabytes >= 1 {
            return String(format: "%.1f MB", megabytes)
        } else if kilobytes >= 1 {
            return String(format: "%.1f KB", kilobytes)
        } else {
            return "\(Int(bytes)) bytes"
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

extension String {
    func isValidAPIKey() -> Bool {
        return !self.isEmpty && self.count > 10
    }
}

extension UserDefaults {
    enum Keys: String {
        case hasSeenOnboarding = "hasSeenOnboarding"
        case preferredImageQuality = "preferredImageQuality"
        case autoSaveResults = "autoSaveResults"
    }

    func set<T>(_ value: T, for key: Keys) {
        set(value, forKey: key.rawValue)
    }

    func value<T>(for key: Keys, type: T.Type) -> T? {
        return object(forKey: key.rawValue) as? T
    }
}