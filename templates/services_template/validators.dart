import 'package:flutter/foundation.dart';

/// Input validation utilities
class Validators {
  /// Email validation
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final regex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
    );
    return regex.hasMatch(email);
  }

  /// Phone number validation (international format)
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    final regex = RegExp(r'^\+[1-9]\d{1,14}$');
    return regex.hasMatch(phone);
  }

  /// Password strength validation
  static PasswordStrength validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return PasswordStrength.empty;
    }

    if (password.length < 6) {
      return PasswordStrength.weak;
    }

    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasNumbers = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (hasUpperCase) strength++;
    if (hasLowerCase) strength++;
    if (hasNumbers) strength++;
    if (hasSpecialChars) strength++;
    if (password.length >= 8) strength++;

    if (strength <= 2) return PasswordStrength.weak;
    if (strength <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  /// URL validation
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Credit card validation (Luhn algorithm)
  static bool isValidCreditCard(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) return false;
    
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }

    return (sum % 10) == 0;
  }

  /// Required field validation
  static bool isRequired(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Minimum length validation
  static bool hasMinLength(String? value, int minLength) {
    return value != null && value.length >= minLength;
  }

  /// Maximum length validation
  static bool hasMaxLength(String? value, int maxLength) {
    return value != null && value.length <= maxLength;
  }

  /// Numeric validation
  static bool isNumeric(String? value) {
    if (value == null || value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  /// Integer validation
  static bool isInteger(String? value) {
    if (value == null || value.isEmpty) return false;
    return int.tryParse(value) != null;
  }

  /// Date validation
  static bool isValidDate(String? date, {String? format}) {
    if (date == null || date.isEmpty) return false;
    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Alphanumeric validation
  static bool isAlphanumeric(String? value) {
    if (value == null || value.isEmpty) return false;
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value);
  }
}

/// Password strength levels
enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  factory ValidationResult.valid() => ValidationResult(isValid: true);
  factory ValidationResult.invalid(String message) =>
      ValidationResult(isValid: false, errorMessage: message);
}

