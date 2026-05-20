enum AuthFormField { displayName, email, password, confirmPassword }

class AuthFormValidationResult {
  const AuthFormValidationResult(this.errors);

  final Map<AuthFormField, String> errors;

  bool get isValid => errors.isEmpty;

  String? errorFor(AuthFormField field) => errors[field];
}

class AuthFormValidationMessages {
  const AuthFormValidationMessages({
    required this.emailInvalid,
    required this.passwordInvalid,
    required this.displayNameInvalid,
    required this.confirmPasswordMismatch,
  });

  const AuthFormValidationMessages.zhTw()
    : emailInvalid = '請輸入有效的 Email',
      passwordInvalid = '密碼至少需要 6 個字元',
      displayNameInvalid = '暱稱長度必須為 1-16 字',
      confirmPasswordMismatch = '確認密碼必須和密碼相同';

  final String emailInvalid;
  final String passwordInvalid;
  final String displayNameInvalid;
  final String confirmPasswordMismatch;
}

class AuthFormValidator {
  const AuthFormValidator._();

  static AuthFormValidationResult validateEmailSignIn({
    required String email,
    required String password,
    AuthFormValidationMessages messages =
        const AuthFormValidationMessages.zhTw(),
  }) {
    final errors = <AuthFormField, String>{};
    _validateEmail(email, errors, messages);
    _validatePassword(password, errors, messages);
    return AuthFormValidationResult(errors);
  }

  static AuthFormValidationResult validateEmailRegistration({
    required String displayName,
    required String email,
    required String password,
    required String confirmPassword,
    AuthFormValidationMessages messages =
        const AuthFormValidationMessages.zhTw(),
  }) {
    final errors = <AuthFormField, String>{};
    _validateDisplayName(displayName, errors, messages);
    _validateEmail(email, errors, messages);
    _validatePassword(password, errors, messages);

    if (password != confirmPassword) {
      errors[AuthFormField.confirmPassword] = messages.confirmPasswordMismatch;
    }

    return AuthFormValidationResult(errors);
  }

  static AuthFormValidationResult validatePasswordReset({
    required String email,
    AuthFormValidationMessages messages =
        const AuthFormValidationMessages.zhTw(),
  }) {
    final errors = <AuthFormField, String>{};
    _validateEmail(email, errors, messages);
    return AuthFormValidationResult(errors);
  }

  static void _validateDisplayName(
    String value,
    Map<AuthFormField, String> errors,
    AuthFormValidationMessages messages,
  ) {
    final displayName = value.trim();
    if (displayName.isEmpty || displayName.length > 16) {
      errors[AuthFormField.displayName] = messages.displayNameInvalid;
    }
  }

  static void _validateEmail(
    String value,
    Map<AuthFormField, String> errors,
    AuthFormValidationMessages messages,
  ) {
    final email = value.trim();
    if (!_emailPattern.hasMatch(email)) {
      errors[AuthFormField.email] = messages.emailInvalid;
    }
  }

  static void _validatePassword(
    String value,
    Map<AuthFormField, String> errors,
    AuthFormValidationMessages messages,
  ) {
    if (value.length < 6) {
      errors[AuthFormField.password] = messages.passwordInvalid;
    }
  }
}

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
