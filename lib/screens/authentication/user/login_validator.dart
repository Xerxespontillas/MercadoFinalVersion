String? validateEmail(String? value) {
  // Check if value is a valid email or username
  final emailRegex = RegExp(r'^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$');

  if (!emailRegex.hasMatch(value!)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required.';
  } else if (value.length < 6) {
    return 'Password must be at least 6 characters long.';
  }
  return null;
}

String? validateUsername(String? value) {
  if (value == null || value.isEmpty) {
    return 'Username is required';
  }
  return null;
}
