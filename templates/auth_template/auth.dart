import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'dart:developer' as developer;
import 'dialog_helper.dart';
import 'storage.dart';

/// Authentication result model
class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;
  final String? token;

  AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
    this.token,
  });

  factory AuthResult.success({required User user, String? token}) {
    return AuthResult(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Advanced Authentication Service with comprehensive error handling
/// Supports Google, Apple, Email/Password, Phone OTP, and Facebook authentication
class Auth extends GetxService {
  final FirebaseAuthenticationService _auth = FirebaseAuthenticationService();
  final FacebookAuth _facebookLogin = FacebookAuth.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AuthCredential? _pendingCredential;

  /// Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Sign in with Google
  /// TODO: Configure Google Sign-In as per https://pub.dev/packages/google_sign_in
  Future<AuthResult> signInWithGoogle() async {
    try {
      DialogHelper.showLoading();
      
      final result = await _auth.signInWithGoogle();
      
      if (result.hasError) {
        DialogHelper.hideDialog();
        return AuthResult.error(
          result.errorMessage ?? 'Google sign-in failed',
        );
      }

      if (result.user != null) {
        await _handleAuthSuccess(result.user!);
        DialogHelper.hideDialog();
        
        final token = await result.user!.getIdToken();
        if (kDebugMode) {
          developer.log('Google sign-in successful. Token obtained.');
        }
        
        return AuthResult.success(user: result.user!, token: token);
      }

      DialogHelper.hideDialog();
      return AuthResult.error('Google sign-in failed: No user returned');
    } catch (e) {
      DialogHelper.hideDialog();
      final errorMsg = _getErrorMessage(e);
      if (kDebugMode) {
        developer.log('Google sign-in error: $errorMsg', error: e);
      }
      return AuthResult.error(errorMsg);
    }
  }

  /// Sign in with Apple
  /// TODO: Configure Apple Sign-In as per https://pub.dev/packages/sign_in_with_apple
  /// TODO: Add your Apple redirect URI and client ID from Firebase console
  Future<AuthResult> signInWithApple({
    String? appleRedirectUri,
    String? appleClientId,
  }) async {
    try {
      DialogHelper.showLoading();
      
      final result = await _auth.signInWithApple(
        appleRedirectUri: appleRedirectUri ??
            'https://stacked-firebase-auth-test.firebaseapp.com/__/auth/handler',
        appleClientId: appleClientId ?? '',
      );

      if (result.hasError) {
        DialogHelper.hideDialog();
        return AuthResult.error(
          result.errorMessage ?? 'Apple sign-in failed',
        );
      }

      if (result.user != null) {
        await _handleAuthSuccess(result.user!);
        DialogHelper.hideDialog();
        
        final token = await result.user!.getIdToken();
        if (kDebugMode) {
          developer.log('Apple sign-in successful. Token obtained.');
        }
        
        return AuthResult.success(user: result.user!, token: token);
      }

      DialogHelper.hideDialog();
      return AuthResult.error('Apple sign-in failed: No user returned');
    } catch (e) {
      DialogHelper.hideDialog();
      final errorMsg = _getErrorMessage(e);
      if (kDebugMode) {
        developer.log('Apple sign-in error: $errorMsg', error: e);
      }
      return AuthResult.error(errorMsg);
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (!_validateEmail(email)) {
        return AuthResult.error('Please enter a valid email address');
      }

      if (password.length < 6) {
        return AuthResult.error('Password must be at least 6 characters');
      }

      DialogHelper.showLoading();
      
      final result = await _auth.loginWithEmail(
        email: email.trim(),
        password: password,
      );

      if (result.hasError) {
        DialogHelper.hideDialog();
        return AuthResult.error(
          result.errorMessage ?? 'Email/password sign-in failed',
        );
      }

      if (result.user != null) {
        await _handleAuthSuccess(result.user!);
        DialogHelper.hideDialog();
        
        final token = await result.user!.getIdToken();
        if (kDebugMode) {
          developer.log('Email/password sign-in successful.');
        }
        
        return AuthResult.success(user: result.user!, token: token);
      }

      DialogHelper.hideDialog();
      return AuthResult.error('Email/password sign-in failed: No user returned');
    } catch (e) {
      DialogHelper.hideDialog();
      final errorMsg = _getErrorMessage(e);
      if (kDebugMode) {
        developer.log('Email/password sign-in error: $errorMsg', error: e);
      }
      return AuthResult.error(errorMsg);
    }
  }

  /// Create account with email and password
  Future<AuthResult> createAccountWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (!_validateEmail(email)) {
        return AuthResult.error('Please enter a valid email address');
      }

      if (password.length < 6) {
        return AuthResult.error('Password must be at least 6 characters');
      }

      DialogHelper.showLoading();
      
      final result = await _auth.createAccountWithEmail(
        email: email.trim(),
        password: password,
      );

      if (result.hasError) {
        DialogHelper.hideDialog();
        return AuthResult.error(
          result.errorMessage ?? 'Account creation failed',
        );
      }

      if (result.user != null) {
        await _handleAuthSuccess(result.user!);
        DialogHelper.hideDialog();
        
        final token = await result.user!.getIdToken();
        if (kDebugMode) {
          developer.log('Account creation successful.');
        }
        
        return AuthResult.success(user: result.user!, token: token);
      }

      DialogHelper.hideDialog();
      return AuthResult.error('Account creation failed: No user returned');
    } catch (e) {
      DialogHelper.hideDialog();
      final errorMsg = _getErrorMessage(e);
      if (kDebugMode) {
        developer.log('Account creation error: $errorMsg', error: e);
      }
      return AuthResult.error(errorMsg);
    }
  }

  /// Request OTP for phone number authentication
  /// Phone number should include country code (e.g., +1234567890)
  Future<AuthResult> requestPhoneOTP({
    required String phoneNumber,
    Function(String verificationId)? onCodeSent,
  }) async {
    try {
      if (!_validatePhoneNumber(phoneNumber)) {
        return AuthResult.error('Please enter a valid phone number with country code');
      }

      DialogHelper.showLoading();
      
      await _auth.requestVerificationCode(
        phoneNumber: phoneNumber.trim(),
        onCodeSent: (verificationId) {
          DialogHelper.hideDialog();
          if (kDebugMode) {
            developer.log('OTP sent. Verification ID: $verificationId');
          }
          onCodeSent?.call(verificationId);
        },
      );

      return AuthResult.success(user: null);
    } catch (e) {
      DialogHelper.hideDialog();
      final errorMsg = _getErrorMessage(e);
      if (kDebugMode) {
        developer.log('Phone OTP request error: $errorMsg', error: e);
      }
      return AuthResult.error(errorMsg);
    }
  }

  /// Verify phone OTP
  Future<AuthResult> verifyPhoneOTP({required String otp}) async {
    try {
      if (otp.length < 6) {
        return AuthResult.error('Please enter a valid OTP');
      }

      DialogHelper.showLoading();
      
      final result = await _auth.authenticateWithOtp(otp.trim());

      if (result.hasError) {
        DialogHelper.hideDialog();
        return AuthResult.error(
          result.errorMessage ?? 'OTP verification failed',
        );
      }

      if (result.user != null) {
        await _handleAuthSuccess(result.user!);
        DialogHelper.hideDialog();
        
        final token = await result.user!.getIdToken();
        if (kDebugMode) {
          developer.log('Phone OTP verification successful.');
        }
        
        return AuthResult.success(user: result.user!, token: token);
      }

      DialogHelper.hideDialog();
      return AuthResult.error('OTP verification failed: No user returned');
    } catch (e) {
      DialogHelper.hideDialog();
      final errorMsg = _getErrorMessage(e);
      if (kDebugMode) {
        developer.log('OTP verification error: $errorMsg', error: e);
      }
      return AuthResult.error(errorMsg);
    }
  }

  /// Sign in with Facebook
  /// TODO: Configure Facebook Auth as per https://pub.dev/packages/flutter_facebook_auth
  Future<AuthResult> signInWithFacebook() async {
    try {
      DialogHelper.showLoading();
      
      final result = await _signInWithFacebookInternal();

      if (!result.success) {
        DialogHelper.hideDialog();
        return result;
      }

      if (result.user != null) {
        await _handleAuthSuccess(result.user!);
        DialogHelper.hideDialog();
        
        final token = await result.user!.getIdToken();
        if (kDebugMode) {
          developer.log('Facebook sign-in successful.');
        }
        
        return AuthResult.success(user: result.user!, token: token);
      }

      DialogHelper.hideDialog();
      return AuthResult.error('Facebook sign-in failed: No user returned');
    } catch (e) {
      DialogHelper.hideDialog();
      final errorMsg = _getErrorMessage(e);
      if (kDebugMode) {
        developer.log('Facebook sign-in error: $errorMsg', error: e);
      }
      return AuthResult.error(errorMsg);
    }
  }

  /// Internal Facebook sign-in implementation
  Future<AuthResult> _signInWithFacebookInternal() async {
    try {
      final LoginResult fbLogin = await _facebookLogin.login();

      if (fbLogin.status != LoginStatus.success) {
        return AuthResult.error(
          fbLogin.message ?? 'Facebook login cancelled or failed',
        );
      }

      if (fbLogin.accessToken == null) {
        return AuthResult.error('Facebook access token not available');
      }

      final OAuthCredential facebookCredentials = FacebookAuthProvider.credential(
        fbLogin.accessToken!.token,
      );

      final result = await _firebaseAuth.signInWithCredential(facebookCredentials);

      // Link pending credential if exists
      if (_pendingCredential != null && result.user != null) {
        await result.user!.linkWithCredential(_pendingCredential!);
        _pendingCredential = null;
      }

      return AuthResult.success(user: result.user);
    } catch (e) {
      return AuthResult.error(_getErrorMessage(e));
    }
  }

  /// Handle successful authentication
  Future<void> _handleAuthSuccess(User user) async {
    try {
      final token = await user.getIdToken(true);
      final firebaseUid = user.uid;

      final storageService = Get.find<GetStorageService>();
      storageService.setEncjwToken = token;
      storageService.setFirebaseUid = firebaseUid;

      if (kDebugMode) {
        developer.log('Token stored successfully');
        debugPrint('User ID: ${storageService.getFirebaseUid}');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('Error handling auth success: $e', error: e);
      }
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      DialogHelper.showLoading();
      
      // Clear storage
      Get.find<GetStorageService>().logout();
      
      // Firebase logout
      await _auth.logout();
      
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
      // Sign out from Facebook
      await _facebookLogin.logOut();
      
      DialogHelper.hideDialog();
      
      if (kDebugMode) {
        developer.log('User logged out successfully');
      }
    } catch (e) {
      DialogHelper.hideDialog();
      if (kDebugMode) {
        developer.log('Logout error: $e', error: e);
      }
      rethrow;
    }
  }

  /// Validate email format
  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone number format (should include country code)
  bool _validatePhoneNumber(String phone) {
    return RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(phone);
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        case 'operation-not-allowed':
          return 'This operation is not allowed.';
        case 'invalid-verification-code':
          return 'Invalid verification code.';
        case 'invalid-verification-id':
          return 'Invalid verification ID.';
        case 'credential-already-in-use':
          return 'This credential is already associated with another account.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }
    return error.toString();
  }
}
