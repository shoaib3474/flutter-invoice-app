import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/error_logger_service.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final ErrorLoggerService _errorLogger;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    required ErrorLoggerService errorLogger,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _errorLogger = errorLogger;

  Stream<User?> get userStream => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _errorLogger.logInfo('User signed in successfully: ${credential.user?.uid}');
      return credential.user;
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Sign in failed',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'email': email},
      );
      rethrow;
    }
  }

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null && displayName != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      _errorLogger.logInfo('User created successfully: ${credential.user?.uid}');
      return _firebaseAuth.currentUser;
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'User creation failed',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'email': email, 'displayName': displayName},
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _errorLogger.logInfo('User signed out successfully');
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Sign out failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _errorLogger.logInfo('Password reset email sent to: $email');
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Password reset email failed',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'email': email},
      );
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _errorLogger.logInfo('Email verification sent to: ${user.email}');
      }
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Email verification failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<User?> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        await user.reload();
        
        _errorLogger.logInfo('Profile updated for user: ${user.uid}');
        return _firebaseAuth.currentUser;
      }
      return null;
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Profile update failed',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'displayName': displayName, 'photoURL': photoURL},
      );
      rethrow;
    }
  }
}
