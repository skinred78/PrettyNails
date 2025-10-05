# Project Overview
This is a mobile app for iOS that allows users to see what a nail salon design will look like on their own hand. The core feature is to take or upload a photo of a hand and have the app digitally apply a selected nail design to the fingernails in the image.

# Technology Stack
- **Platform:** Native iOS mobile application.
- **UI Framework:** Apple's SwiftUI will be used for a modern, native user experience.
- **AI Image Editing:** Google's Gemini API (specifically the Imagen model) will be used for its in-painting feature to apply nail designs to user-provided photos. The official documentation can be found at https://ai.google.dev/gemini-api/docs/image-generation.

# Architectural Principles
- The architecture must strictly separate the user interface (UI) code from the business logic and data management code.
- The UI will be built using SwiftUI's native styling capabilities to ensure a consistent and platform-idiomatic look and feel.

# Git Workflow
- All feature development must happen on branches named using the format: `feature/short-description`.
- All commit messages must follow the Conventional Commits format, like `feat: add photo upload button`.