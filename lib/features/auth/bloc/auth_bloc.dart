import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/services/error_logger_service.dart';
import '../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final ErrorLoggerService _errorLogger;
  late StreamSubscription<User?> _userSubscription;

  AuthBloc({
    required AuthRepository authRepository,
    required ErrorLoggerService errorLogger,
  })  : _authRepository = authRepository,
        _errorLogger = errorLogger,
        super(AuthInitial()) {
    
    // Listen to auth state changes
    _userSubscription = _authRepository.userStream.listen(
      (user) => add(AuthUserChanged(user: user)),
    );

    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthEmailVerificationRequested>(_onEmailVerificationRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      _errorLogger.logInfo('Login attempt for email: ${event.email}');
      
      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      
      if (user != null) {
        _errorLogger.logInfo('Login successful for user: ${user.uid}');
        emit(AuthAuthenticated(user: user));
      } else {
        _errorLogger.logWarning('Login failed: User is null');
        emit(const AuthError(message: 'Login failed'));
      }
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Login error',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'email': event.email},
      );
      
      emit(AuthError(
        message: _getErrorMessage(e),
        errorCode: _getErrorCode(e),
        stackTrace: stackTrace,
      ));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      _errorLogger.logInfo('Registration attempt for email: ${event.email}');
      
      final user = await _authRepository.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
        displayName: event.name,
      );
      
      if (user != null) {
        _errorLogger.logInfo('Registration successful for user: ${user.uid}');
        emit(AuthAuthenticated(user: user));
      } else {
        _errorLogger.logWarning('Registration failed: User is null');
        emit(const AuthError(message: 'Registration failed'));
      }
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Registration error',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'email': event.email, 'name': event.name},
      );
      
      emit(AuthError(
        message: _getErrorMessage(e),
        errorCode: _getErrorCode(e),
        stackTrace: stackTrace,
      ));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _errorLogger.logInfo('Logout requested');
      await _authRepository.signOut();
      _errorLogger.logInfo('Logout successful');
      emit(AuthUnauthenticated());
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Logout error',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(AuthError(
        message: _getErrorMessage(e),
        errorCode: _getErrorCode(e),
        stackTrace: stackTrace,
      ));
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _errorLogger.logInfo('Password reset requested for: ${event.email}');
      
      await _authRepository.sendPasswordResetEmail(event.email);
      
      _errorLogger.logInfo('Password reset email sent to: ${event.email}');
      emit(AuthPasswordResetSent(email: event.email));
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Password reset error',
        error: e,
        stackTrace: stackTrace,
        additionalData: {'email': event.email},
      );
      
      emit(AuthError(
        message: _getErrorMessage(e),
        errorCode: _getErrorCode(e),
        stackTrace: stackTrace,
      ));
    }
  }

  void _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      _errorLogger.logInfo('User state changed: authenticated');
      emit(AuthAuthenticated(user: event.user));
    } else {
      _errorLogger.logInfo('User state changed: unauthenticated');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onEmailVerificationRequested(
    AuthEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _errorLogger.logInfo('Email verification requested');
      
      await _authRepository.sendEmailVerification();
      
      _errorLogger.logInfo('Email verification sent');
      emit(AuthEmailVerificationSent());
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Email verification error',
        error: e,
        stackTrace: stackTrace,
      );
      
      emit(AuthError(
        message: _getErrorMessage(e),
        errorCode: _getErrorCode(e),
        stackTrace: stackTrace,
      ));
    }
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      _errorLogger.logInfo('Profile update requested');
      
      final user = await _authRepository.updateProfile(
        displayName: event.displayName,
        photoURL: event.photoURL,
      );
      
      if (user != null) {
        _errorLogger.logInfo('Profile updated successfully');
        emit(AuthProfileUpdated(user: user));
      }
    } catch (e, stackTrace) {
      _errorLogger.logError(
        'Profile update error',
        error: e,
        stackTrace: stackTrace,
        additionalData: {
          'displayName': event.displayName,
          'photoURL': event.photoURL,
        },
      );
      
      emit(AuthError(
        message: _getErrorMessage(e),
        errorCode: _getErrorCode(e),
        stackTrace: stackTrace,
      ));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return error.message ?? 'An authentication error occurred.';
      }
    }
    return error.toString();
  }

  String? _getErrorCode(dynamic error) {
    if (error is FirebaseAuthException) {
      return error.code;
    }
    return null;
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
