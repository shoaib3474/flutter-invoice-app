import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_invoice_app/services/mock/mock_firebase_service.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelpers {
  static late MockFirebaseAuth _mockAuth;

  static Future<void> setupFirebaseForTesting() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase for testing
    await Firebase.initializeApp();

    // Setup mock auth
    _mockAuth = MockFirebaseAuth();
  }

  static Future<void> signInTestUser() async {
    await _mockAuth.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password123',
    );
  }

  static Future<void> signOutTestUser() async {
    await _mockAuth.signOut();
  }

  static MockFirebaseAuth get mockAuth => _mockAuth;
}
