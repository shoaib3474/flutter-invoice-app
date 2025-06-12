import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// \`\`\`dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// \`\`\`
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Update the Firebase configuration with placeholder values that need to be replaced
  // Replace all "YOUR_*" placeholders with actual values from your Firebase console

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', // Replace with your Web API Key
    appId: '1:123456789:web:abcdefghijklmnop', // Replace with your Web App ID
    messagingSenderId: '123456789', // Replace with your Messaging Sender ID
    projectId: 'flutter-invoice-app-12345', // Replace with your Project ID
    authDomain: 'flutter-invoice-app-12345.firebaseapp.com', // Replace with your Auth Domain
    storageBucket: 'flutter-invoice-app-12345.appspot.com', // Replace with your Storage Bucket
    measurementId: 'G-XXXXXXXXXX', // Replace with your Measurement ID
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', // Replace with your Android API Key
    appId: '1:123456789:android:abcdefghijklmnop', // Replace with your Android App ID
    messagingSenderId: '123456789', // Replace with your Messaging Sender ID
    projectId: 'flutter-invoice-app-12345', // Replace with your Project ID
    storageBucket: 'flutter-invoice-app-12345.appspot.com', // Replace with your Storage Bucket
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosClientId: 'YOUR_MACOS_CLIENT_ID',
    iosBundleId: 'YOUR_MACOS_BUNDLE_ID',
  );
}
