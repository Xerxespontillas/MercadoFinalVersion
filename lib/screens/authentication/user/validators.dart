import 'package:flutter/material.dart';

String? validateDisplayName(String? value) {
  if (value!.isEmpty) {
    return 'Your full name is required';
  }
  return null;
}

String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'Username is required';
  }

  final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]{3,16}$');
  if (!usernameRegex.hasMatch(value)) {
    return 'Username must be 3-16 characters long and contain only letters, numbers, underscores, or hyphens';
  }

  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required.';
  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Invalid email address.';
  }
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value!.isEmpty) {
    return 'Phone Number is required';
  }

  return null;
}

String? validateBirthdate(String? value) {
  if (value!.isEmpty) {
    return 'Birthdate is required';
  }
  return null;
}

String? validateGender(String? value) {
  if (value == null) {
    return 'Please select your gender.';
  }
  return null;
}

String? validateAddress(String? value) {
  if (value!.isEmpty) {
    return 'Address is required';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value!.isEmpty) {
    return "Please enter your password";
  } else if (value.length < 6) {
    return 'Password must be at least 6 characters.';
  }
  return null;
}

String? validateConfirmPassword(
    String? value, TextEditingController passwordController) {
  if (value!.isEmpty) {
    return 'Confirm password is required';
  }
  if (value != passwordController.text) {
    return 'Passwords do not match';
  }

  return null;
}
