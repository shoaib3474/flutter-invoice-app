import 'package:flutter/foundation.dart';

// Mock auth service to replace Firebase dependencies
class AuthService {
  // Mock user class
  static const Map<String, dynamic> _mockUser = {
    'uid': 'mock_user_123',
    'email': 'test@example.com',
    'displayName': 'Test User',
  };
  
  bool _isSignedIn = false;
  
  // Auth state stream (mock)
  Stream<Map<String, dynamic>?> get authStateChanges async* {
    yield _isSignedIn ? _mockUser : null;
  }
  
  // Current user (mock)
  Map<String, dynamic>? get currentUser => _isSignedIn ? _mockUser : null;
  
  // Sign in with email and password (mock)
  Future<Map<String, dynamic>> signInWithEmailAndPassword(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      _isSignedIn = true;
      return {'success': true, 'user': _mockUser};
    } catch (e) {
      debugPrint('Error signing in with email and password: $e');
      rethrow;
    }
  }
  
  // Register with email and password (mock)
  Future<Map<String, dynamic>> registerWithEmailAndPassword(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      _isSignedIn = true;
      return {'success': true, 'user': _mockUser};
    } catch (e) {
      debugPrint('Error registering with email and password: $e');
      rethrow;
    }
  }
  
  // Sign in with Google (mock)
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      _isSignedIn = true;
      return {'success': true, 'user': _mockUser};
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }
  
  // Sign out (mock)
  Future<void> signOut() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _isSignedIn = false;
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
  
  // Reset password (mock)
  Future<void> resetPassword(String email) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Password reset email sent to: $email');
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow;
    }
  }
  
  // Update user profile (mock)
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint('Profile updated: $displayName, $photoURL');
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }
  
  // Check if user is signed in
  bool isSignedIn() {
    return _isSignedIn;
  }
  
  // Get user ID
  String? getUserId() {
    return _isSignedIn ? _mockUser['uid'] as String : null;
  }
}
