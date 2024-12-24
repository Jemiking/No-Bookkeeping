class ValidationRule<T> {
  final String field;
  final String message;
  final bool Function(T value) validate;

  ValidationRule({
    required this.field,
    required this.message,
    required this.validate,
  });
}

class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  ValidationResult({
    required this.isValid,
    this.errors = const {},
  });

  factory ValidationResult.success() {
    return ValidationResult(isValid: true);
  }

  factory ValidationResult.failure(Map<String, String> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }
} 