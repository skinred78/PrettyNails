> > Think hard Think hard and create a detailed, step-by-step 
implementation plan for the core feature of my iOS app based on 
the updated CLAUDE.md file.

The plan must cover these key areas:
1.  **UI Components:** List the SwiftUI views needed for the user
 to upload a photo and select a nail design.
2.  **API Integration:** Detail the steps required to connect the
 iOS app to the Google Gemini API. This should include how to 
handle the API key securely.
3.  **Image Processing Logic:** Describe the process flow, 
starting from the user uploading an image to sending it to the 
Gemini API with an in-painting mask, and finally displaying the 
edited image.
4.  **File Structure:** List all the new files that need to be 
created and specify which folder they should be in.

Present the final output as a clear, numbered list that we can 
follow. Do not write any code yet.

✻ Thinking…

  The user is asking me to create a detailed step-by-step implementation plan for 
  the core feature of their iOS app. Based on the CLAUDE.md file, this is a mobile
   app for iOS that allows users to see what nail salon designs will look like on 
  their own hands. The core feature involves:

  1. Taking/uploading a photo of a hand
  2. Applying a selected nail design to the fingernails in the image using 
  Google's Gemini API (Imagen model) with in-painting

  The user wants me to cover:
  1. UI Components (SwiftUI views)
  2. API Integration (Google Gemini API with secure API key handling)
  3. Image Processing Logic (flow from upload to API to display)
  4. File Structure (new files and their locations)

  This is a planning task that requires me to think through the architecture and 
  implementation without writing code yet. Since this is a complex multi-step task
   that involves planning multiple components, I should use the TodoWrite tool to 
  organize this planning work.

  Let me break this down systematically:

  1. UI Components needed:
    - Main app view
    - Photo capture/upload view
    - Nail design selection view
    - Image processing/loading view
    - Result display view
  2. API Integration:
    - Secure API key management
    - HTTP client setup
    - Gemini API request formatting
    - Response handling
    - Error handling
  3. Image Processing Logic:
    - Image capture/selection
    - Image preprocessing
    - Mask generation for nails
    - API request with in-painting
    - Result processing and display
  4. File Structure:
    - Views (SwiftUI)
    - Models (data structures)
    - Services (API, image processing)
    - Utilities
    - Configuration

  This is definitely a complex task that warrants using the TodoWrite tool to 
  organize the planning process.

⏺ I'll create a comprehensive implementation plan for your iOS nail design
  app. Let me break this down systematically using a todo list to ensure I
  cover all the key areas you've specified.

✻ Thinking…

  Now I need to work through each area systematically. Let me start with the UI 
  Components analysis since that's marked as in_progress.

  For UI Components, I need to think about the user flow:
  1. User opens app
  2. User either takes a photo or selects from gallery
  3. User selects a nail design from available options
  4. App processes the image
  5. User sees the result

  So the UI components would be:
  - Main/Home view
  - Photo capture view (camera)
  - Photo selection view (gallery)
  - Nail design selection view
  - Processing/loading view
  - Result display view
  - Possibly a settings/profile view

  Let me work through this systematically.

⏺ Detailed Implementation Plan for iOS Nail Design App

  1. UI Components (SwiftUI Views)

✻ Thinking…

  Now let me work on the API Integration details for Google Gemini API.

  Key considerations for API integration:
  1. Secure API key storage - should use iOS Keychain or environment variables, 
  not hardcoded
  2. HTTP client setup - URLSession or Alamofire
  3. Request formatting for Gemini API's Imagen model
  4. Handling multipart form data for image uploads
  5. Response parsing
  6. Error handling and retry logic
  7. Network connectivity checks

  Let me detail this out.

⏺ Required SwiftUI Views:
  - ContentView - Main app container and navigation
  - HomeView - Landing screen with main action buttons
  - PhotoCaptureView - Camera interface for taking new photos
  - PhotoPickerView - Gallery selection interface
  - NailDesignSelectionView - Grid/list of available nail designs
  - ProcessingView - Loading screen during API processing
  - ResultView - Display processed image with save/share options
  - SettingsView - App configuration and API settings

  2. API Integration (Google Gemini API)

✻ Thinking…

  Now let me work on the Image Processing Logic flow. This is the core 
  functionality that ties everything together.

  The flow should be:
  1. User selects/captures image
  2. App validates image (contains hand, proper format, etc.)
  3. App prepares image for API (resize, format conversion if needed)
  4. App generates or applies a mask for nail areas (this might be part of the 
  prompt to Gemini)
  5. App sends request to Gemini API with original image, mask/instructions, and 
  nail design
  6. App receives processed image from API
  7. App displays result to user
  8. User can save/share the result

  Let me detail this process.

⏺ Secure API Key Management:
  - Store API key in iOS Keychain using Security framework
  - Create APIKeyManager class to handle secure storage/retrieval
  - Use environment-based configuration for development vs. production keys
  - Implement key rotation capability

  HTTP Client Setup:
  - Use native URLSession for API requests
  - Create GeminiAPIClient service class
  - Implement request/response models conforming to Codable
  - Add retry logic with exponential backoff
  - Handle rate limiting and quota management

  Request Structure:
  - Format requests for Gemini's Imagen in-painting endpoint
  - Handle multipart form data for image uploads
  - Include proper headers (API key, content-type, user-agent)
  - Implement request timeout and cancellation

  3. Image Processing Logic Flow

✻ Thinking…

  Now let me work on the File Structure. I need to organize this following 
  iOS/Swift best practices and separating UI from business logic as specified in 
  the CLAUDE.md.

  Typical iOS app structure:
  - Views/ (SwiftUI views)
  - ViewModels/ (if using MVVM)
  - Models/ (data structures)
  - Services/ (API clients, business logic)
  - Utilities/ (helpers, extensions)
  - Resources/ (assets, nail designs)
  - Configuration/ (app settings, constants)

  Let me detail this out with specific files.

⏺ Step-by-Step Process:
  1. Image Acquisition - User captures photo or selects from gallery
  2. Image Validation - Check image quality, format, and hand detection
  3. Image Preprocessing - Resize to optimal dimensions, convert to required
  format
  4. Nail Area Detection - Use CoreML or Vision framework for initial nail
  detection
  5. Mask Generation - Create mask for nail areas to guide in-painting
  6. API Request Assembly - Combine original image, mask, nail design, and
  prompt
  7. Gemini API Call - Send in-painting request with all required parameters
  8. Response Processing - Parse API response and extract processed image
  9. Result Display - Show before/after comparison and save/share options
  10. Error Handling - Manage API failures, network issues, and invalid
  results

  4. File Structure and Organization

✻ Thinking…

  Now I need to compile the final numbered implementation plan that ties 
  everything together in a clear, actionable format. This should be a step-by-step
   guide that can be followed to build the app.

  Let me organize this into logical phases:
  1. Project setup and configuration
  2. UI layer implementation
  3. Business logic and services
  4. API integration
  5. Testing and refinement

  Let me create a comprehensive numbered list.

⏺ Folder Structure:
  PrettyNails/
  ├── Views/
  │   ├── ContentView.swift
  │   ├── HomeView.swift
  │   ├── PhotoCaptureView.swift
  │   ├── PhotoPickerView.swift
  │   ├── NailDesignSelectionView.swift
  │   ├── ProcessingView.swift
  │   ├── ResultView.swift
  │   └── SettingsView.swift
  ├── Models/
  │   ├── NailDesign.swift
  │   ├── ProcessingResult.swift
  │   ├── GeminiAPIModels.swift
  │   └── AppState.swift
  ├── Services/
  │   ├── GeminiAPIClient.swift
  │   ├── ImageProcessingService.swift
  │   ├── NailDesignManager.swift
  │   └── APIKeyManager.swift
  ├── Utilities/
  │   ├── ImageUtils.swift
  │   ├── NetworkUtils.swift
  │   └── Extensions.swift
  ├── Resources/
  │   ├── NailDesigns/
  │   └── Assets.xcassets
  └── Configuration/
      ├── APIConfig.swift
      └── Constants.swift

  ---
  Final Implementation Plan

✻ Thinking…

  Perfect! I've completed all the todo items and now have a comprehensive 
  implementation plan. Let me present this as a clear, numbered list that can be 
  followed step by step to build the iOS nail design app.

  The plan covers all the key areas requested:
  1. ✅ UI Components - Listed all SwiftUI views needed
  2. ✅ API Integration - Detailed secure API key handling and Gemini API setup  
  3. ✅ Image Processing Logic - Described the complete flow from upload to 
  display
  4. ✅ File Structure - Listed all new files and their folder organization

  Now I'll present the final numbered implementation plan.

⏺ Phase 1: Project Foundation (Steps 1-8)

  1. Create iOS project structure - Set up Xcode project with SwiftUI and
  required frameworks (Vision, Security)
  2. Configure API key management - Create APIKeyManager.swift in Services/ to
   handle secure Keychain storage
  3. Set up API configuration - Create APIConfig.swift and Constants.swift in
  Configuration/ with Gemini API endpoints
  4. Create core data models - Implement NailDesign.swift,
  ProcessingResult.swift, and GeminiAPIModels.swift in Models/
  5. Build utility classes - Create ImageUtils.swift and NetworkUtils.swift in
   Utilities/ for common operations
  6. Set up main app state - Create AppState.swift in Models/ to manage
  app-wide state using ObservableObject
  7. Configure permissions - Add camera and photo library usage descriptions
  to Info.plist
  8. Create basic navigation - Implement ContentView.swift as main app
  container

  Phase 2: UI Layer Implementation (Steps 9-16)

  9. Build home screen - Create HomeView.swift with options to take photo or
  select from gallery
  10. Implement photo capture - Create PhotoCaptureView.swift using
  UIImagePickerController wrapped in UIViewControllerRepresentable
  11. Build photo selection - Create PhotoPickerView.swift for gallery access
  using PHPickerViewController
  12. Create design selection - Implement NailDesignSelectionView.swift with
  grid layout of available designs
  13. Build processing screen - Create ProcessingView.swift with loading
  animation and progress indicator
  14. Implement result display - Create ResultView.swift showing before/after
  images with save/share options
  15. Add settings screen - Create SettingsView.swift for API configuration
  and app preferences
  16. Connect navigation flow - Link all views together with proper navigation
   and state management

  Phase 3: Business Logic and Services (Steps 17-22)

  17. Create nail design manager - Implement NailDesignManager.swift to load
  and manage available nail designs
  18. Build image processing service - Create ImageProcessingService.swift for
   image validation, resizing, and preprocessing
  19. Implement hand/nail detection - Add Vision framework integration for
  basic hand and nail area detection
  20. Create mask generation - Implement functionality to create in-painting
  masks for nail areas
  21. Add image utilities - Complete ImageUtils.swift with format conversion,
  compression, and validation functions
  22. Implement error handling - Add comprehensive error handling across all
  services and UI components

  Phase 4: API Integration (Steps 23-28)

  23. Create HTTP client - Implement GeminiAPIClient.swift with
  URLSession-based networking
  24. Build API request models - Complete request/response structures in
  GeminiAPIModels.swift
  25. Implement in-painting requests - Add specific functionality for Gemini's
   Imagen in-painting API calls
  26. Add retry logic - Implement exponential backoff and retry mechanisms for
   failed requests
  27. Handle API responses - Add response parsing, image extraction, and error
   handling
  28. Test API integration - Verify end-to-end functionality with test images
  and designs

  Phase 5: Polish and Testing (Steps 29-32)

  29. Add loading states - Implement proper loading indicators and progress
  tracking throughout the app
  30. Implement save/share functionality - Add capabilities to save processed
  images to photo library and share
  31. Add error user feedback - Implement user-friendly error messages and
  recovery options
  32. Test complete user flow - Verify entire process from photo capture to
  final result display

  This plan provides a systematic approach to building your iOS nail design
  app, with clear separation between UI and business logic as specified in
  your CLAUDE.md requirements.