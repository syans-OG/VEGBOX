String? validateName(String? value) {
  if ((value ?? '').trim().length < 3) return 'Enter your full name.';
  return null;
}

String? validatePhone(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return 'Phone number is required.';
  if (digits.length < 9) return 'Enter a valid phone number.';
  return null;
}

String? validatePassword(String? value) {
  if ((value ?? '').isEmpty) return 'Password is required.';
  if ((value ?? '').length < 6) return 'Use at least 6 characters.';
  return null;
}
