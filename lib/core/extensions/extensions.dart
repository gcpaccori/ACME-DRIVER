import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

extension StringExtensions on String {
  String get capitalize =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;

  // Validate email format
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  // Validate strong password
  // Minimum 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char
  bool get isStrongPassword {
    if (length < 8) return false;
    if (!contains(RegExp(r'[A-Z]'))) return false;
    if (!contains(RegExp(r'[a-z]'))) return false;
    if (!contains(RegExp(r'[0-9]'))) return false;
    if (!contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]'))) return false;
    return true;
  }

  // Get password strength message
  String get passwordStrengthMessage {
    if (isEmpty) return 'La contraseña es requerida';
    if (length < 8) return 'Mínimo 8 caracteres';
    if (!contains(RegExp(r'[A-Z]'))) return 'Requiere 1 mayúscula';
    if (!contains(RegExp(r'[a-z]'))) return 'Requiere 1 minúscula';
    if (!contains(RegExp(r'[0-9]'))) return 'Requiere 1 número';
    if (!contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>\/?]'))) {
      return 'Requiere 1 carácter especial';
    }
    return '';
  }

  // Validate phone number (9-15 digits)
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^[0-9]{9,15}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'[\s\-\()]+'), ''));
  }

  // Validate IBAN format
  bool get isValidIban {
    final ibanRegex = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$');
    final cleaned = toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');
    return ibanRegex.hasMatch(cleaned);
  }

  // Validate license plate format
  bool get isValidLicensePlate {
    final plateRegex = RegExp(r'^[A-Z0-9]{3,8}$');
    return plateRegex.hasMatch(toUpperCase().replaceAll(RegExp(r'[\s\-]'), ''));
  }

  // Validate driver license number
  bool get isValidLicenseNumber {
    final licenseRegex = RegExp(r'^[A-Z0-9]{6,20}$');
    return licenseRegex.hasMatch(toUpperCase());
  }

  // Validate identification number
  bool get isValidIdentificationNumber {
    final idRegex = RegExp(r'^[0-9A-Z]{6,20}$');
    return idRegex.hasMatch(toUpperCase());
  }

  // Validate address (minimum 10 characters)
  bool get isValidAddress {
    return trim().length >= 10;
  }
}

extension DoubleExtensions on double {
  String get toCurrency => 'S/ ${toStringAsFixed(2)}';
}
