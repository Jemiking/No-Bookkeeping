import 'validation_rule.dart';

class Validator {
  final List<ValidationRule> _rules = [];

  void addRule(ValidationRule rule) {
    _rules.add(rule);
  }

  void addRules(List<ValidationRule> rules) {
    _rules.addAll(rules);
  }

  ValidationResult validate(Map<String, dynamic> data) {
    final errors = <String, String>{};

    for (var rule in _rules) {
      if (!rule.validate(data[rule.field])) {
        errors[rule.field] = rule.message;
      }
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}

class CommonValidators {
  static ValidationRule<String> required(String field) {
    return ValidationRule(
      field: field,
      message: '$field不能为空',
      validate: (value) => value.isNotEmpty,
    );
  }

  static ValidationRule<String> minLength(String field, int length) {
    return ValidationRule(
      field: field,
      message: '$field长度不能小于$length',
      validate: (value) => value.length >= length,
    );
  }

  static ValidationRule<String> maxLength(String field, int length) {
    return ValidationRule(
      field: field,
      message: '$field长度不能大于$length',
      validate: (value) => value.length <= length,
    );
  }

  static ValidationRule<num> range(String field, num min, num max) {
    return ValidationRule(
      field: field,
      message: '$field必须在$min到$max之间',
      validate: (value) => value >= min && value <= max,
    );
  }

  static ValidationRule<String> email(String field) {
    return ValidationRule(
      field: field,
      message: '请输入有效的邮箱地址',
      validate: (value) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value),
    );
  }
} 