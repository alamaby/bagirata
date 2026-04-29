final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Email wajib diisi';
  if (!_emailRegex.hasMatch(v)) return 'Format email tidak valid';
  return null;
}

String? validatePassword(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'Password wajib diisi';
  if (v.length < 6) return 'Password minimal 6 karakter';
  return null;
}
