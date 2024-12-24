import 'validator.dart';
import 'validation_rule.dart';

class DataValidator {
  final Map<String, Validator> _validators = {};

  // 注册验证器
  void registerValidator(String modelName, Validator validator) {
    _validators[modelName] = validator;
  }

  // 验证数据
  ValidationResult validateModel(String modelName, Map<String, dynamic> data) {
    final validator = _validators[modelName];
    if (validator == null) {
      throw Exception('未找到$modelName的验证器');
    }
    return validator.validate(data);
  }

  // 批量验证数据
  Map<String, ValidationResult> validateBatch(
    Map<String, Map<String, dynamic>> dataMap,
  ) {
    final results = <String, ValidationResult>{};
    
    dataMap.forEach((modelName, data) {
      results[modelName] = validateModel(modelName, data);
    });

    return results;
  }

  // 自定义验证规则
  ValidationResult validateCustom(
    Map<String, dynamic> data,
    List<ValidationRule> rules,
  ) {
    final validator = Validator()..addRules(rules);
    return validator.validate(data);
  }

  // 验证单个字段
  ValidationResult validateField(
    String field,
    dynamic value,
    ValidationRule rule,
  ) {
    final validator = Validator()..addRule(rule);
    return validator.validate({field: value});
  }
} 