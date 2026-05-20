enum AuthFormField {
  displayName,
  email,
  password,
  confirmPassword,
}

class AuthFormValidationResult {
  const AuthFormValidationResult(this.errors);

  final Map<AuthFormField, String> errors;

  bool get isValid => errors.isEmpty;

  String? errorFor(AuthFormField field) => errors[field];
}

class AuthFormValidator {
  const AuthFormValidator._();

  static AuthFormValidationResult validateEmailSignIn({
    required String email,
    required String password,
  }) {
    final errors = <AuthFormField, String>{};
    _validateEmail(email, errors);
    _validatePassword(password, errors);
    return AuthFormValidationResult(errors);
  }

  static AuthFormValidationResult validateEmailRegistration({
    required String displayName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final errors = <AuthFormField, String>{};
    _validateDisplayName(displayName, errors);
    _validateEmail(email, errors);
    _validatePassword(password, errors);

    if (password != confirmPassword) {
      errors[AuthFormField.confirmPassword] = '確認密碼必須和密碼相同';
    }

    return AuthFormValidationResult(errors);
  }

  static AuthFormValidationResult validatePasswordReset({
    required String email,
  }) {
    final errors = <AuthFormField, String>{};
    _validateEmail(email, errors);
    return AuthFormValidationResult(errors);
  }

  static void _validateDisplayName(String value, Map<AuthFormField, String> errors) {
    final displayName = value.trim();
    if (displayName.isEmpty || displayName.length > 16) {
      errors[AuthFormField.displayName] = '暱稱長度必須為 1-16 字';
    }
  }

  static void _validateEmail(String value, Map<AuthFormField, String> errors) {
    final email = value.trim();
    if (!_emailPattern.hasMatch(email)) {
      errors[AuthFormField.email] = '請輸入有效的 Email';
    }
  }

  static void _validatePassword(String value, Map<AuthFormField, String> errors) {
    if (value.length < 6) {
      errors[AuthFormField.password] = '密碼至少需要 6 個字元';
    }
  }
}

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
