# Flutter Invoice App

A comprehensive GST invoice app built with Flutter.

## Features

- Create, view, edit, and delete invoices
- Generate GST-compliant PDF invoices
- Share, print, and save PDF invoices
- Track invoice status (draft, issued, paid, etc.)
- Support for different invoice types (sales, purchase, credit note, debit note)
- GST calculations (CGST, SGST, IGST, Cess)
- Customer management
- Product catalog
- GST returns (GSTR1, GSTR3B, GSTR4, GSTR9, GSTR9C)
- Firebase integration for data storage and authentication

## Getting Started

### Prerequisites

- Flutter SDK (2.19.0 or higher)
- Dart SDK (2.19.0 or higher)
- Android Studio / VS Code
- Firebase project (for authentication and Firestore)

### Installation

1. Clone the repository:
   \`\`\`
   git clone https://github.com/yourusername/flutter_invoice_app.git
   \`\`\`

2. Navigate to the project directory:
   \`\`\`
   cd flutter_invoice_app
   \`\`\`

3. Install dependencies:
   \`\`\`
   flutter pub get
   \`\`\`

4. Configure Firebase:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android and iOS apps to your Firebase project
   - Download and add the `google-services.json` file to the `android/app` directory
   - Download and add the `GoogleService-Info.plist` file to the `ios/Runner` directory

5. Run the app:
   \`\`\`
   flutter run
   \`\`\`

## Testing PDF Generation

To test the PDF generation functionality:

1. Launch the app
2. Navigate to the home screen
3. Click on the "Test PDF" button in the Quick Actions section
4. Use the buttons to:
   - View PDF: Opens the generated PDF in your device's PDF viewer
   - Share PDF: Shares the PDF via your device's share sheet
   - Print PDF: Opens the print dialog to print the PDF
   - Save PDF: Saves the PDF to your device's storage
   - Show/Hide Preview: Toggles the PDF preview

## Building APK

To build a release APK:

1. Run the following command:
   \`\`\`
   flutter build apk --release
   \`\`\`

2. The APK will be generated at:
   \`\`\`
   build/app/outputs/flutter-apk/app-release.apk
   \`\`\`

## Project Structure

- `lib/models/`: Data models
- `lib/screens/`: UI screens
- `lib/widgets/`: Reusable UI components
- `lib/services/`: Business logic and services
- `lib/utils/`: Utility functions
- `lib/providers/`: State management
- `lib/repositories/`: Data access layer
- `lib/api/`: API clients
- `lib/theme/`: App theme configuration

## Additional Notes

- The app uses Firebase Authentication for user management
- Firestore is used for data storage
- PDF generation is handled by the `pdf` and `printing` packages
- The app supports both light and dark themes

## License

This project is licensed under the MIT License - see the LICENSE file for details.
\`\`\`

Let's also add a missing dependency to the pubspec.yaml:

```typescriptreact file="pubspec.yaml"
[v0-no-op-code-block-prefix]name: flutter_invoice_app
description: A Flutter Invoice App with GST support
publish_to: 'none' 
version: 1.0.0+1

environment:
  sdk: '>=2.19.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.5
  # Firebase
  firebase_core: ^2.13.0
  firebase_auth: ^4.6.1
  cloud_firestore: ^4.7.1
  firebase_storage: ^11.2.1
  # PDF generation and printing
  pdf: ^3.10.4
  printing: ^5.11.0
  open_file_plus: ^3.4.1
  path_provider: ^2.0.15
  share_plus: ^7.0.2
  # UI helpers
  google_fonts: ^5.0.0
  intl: ^0.18.1
  flutter_svg: ^2.0.5
  fl_chart: ^0.63.0
  cached_network_image: ^3.2.3
  image_picker: ^0.8.7+5
  # State management
  provider: ^6.0.5
  # Utils
  uuid: ^3.0.7
  http: ^0.13.6
  shared_preferences: ^2.1.1
  connectivity_plus: ^4.0.1
  url_launcher: ^6.1.11
  file_picker: ^5.3.0
  permission_handler: ^10.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.1

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
