import 'data_validator.dart';
import 'validator.dart';
import 'validation_rule.dart';

class ValidationManager {
  final DataValidator _dataValidator = DataValidator();
  final Map<String, List<ValidationRule>> _modelRules = {};

  // 初始化验证规则
  void initializeValidation() {
    _initializeAccountRules();
    _initializeTransactionRules();
    _initializeCategoryRules();
    _initializeTagRules();
  }

  // 初始化账户验证规则
  void _initializeAccountRules() {
    final rules = [
      CommonValidators.required('name'),
      CommonValidators.maxLength('name', 50),
      CommonValidators.required('type'),
      ValidationRule<num>(
        field: 'balance',
        message: '余额必须大于等于0',
        validate: (value) => value >= 0,
      ),
    ];

    _modelRules['account'] = rules;
    _dataValidator.registerValidator('account', Validator()..addRules(rules));
  }

  // 初始化交易验证规则
  void _initializeTransactionRules() {
    final rules = [
      CommonValidators.required('amount'),
      ValidationRule<num>(
        field: 'amount',
        message: '金额必须大于0',
        validate: (value) => value > 0,
      ),
      CommonValidators.required('type'),
      CommonValidators.required('accountId'),
      ValidationRule<DateTime>(
        field: 'date',
        message: '日期不能晚于当前时间',
        validate: (value) => value.isBefore(DateTime.now()),
      ),
    ];

    _modelRules['transaction'] = rules;
    _dataValidator.registerValidator('transaction', Validator()..addRules(rules));
  }

  // 初始化分类验证规则
  void _initializeCategoryRules() {
    final rules = [
      CommonValidators.required('name'),
      CommonValidators.maxLength('name', 30),
      ValidationRule<String>(
        field: 'parentId',
        message: '父分类ID无效',
        validate: (value) => value.isEmpty || value.length == 36,
      ),
    ];

    _modelRules['category'] = rules;
    _dataValidator.registerValidator('category', Validator()..addRules(rules));
  }

  // 初始化标签验证规则
  void _initializeTagRules() {
    final rules = [
      CommonValidators.required('name'),
      CommonValidators.maxLength('name', 20),
      ValidationRule<String>(
        field: 'color',
        message: '颜色代码无效',
        validate: (value) => value.isEmpty || RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value),
      ),
    ];

    _modelRules['tag'] = rules;
    _dataValidator.registerValidator('tag', Validator()..addRules(rules));
  }

  // 验证数据
  ValidationResult validate(String modelName, Map<String, dynamic> data) {
    return _dataValidator.validateModel(modelName, data);
  }

  // 获取模型验证规则
  List<ValidationRule> getModelRules(String modelName) {
    return List.from(_modelRules[modelName] ?? []);
  }

  // 添加自定义验证规则
  void addCustomRules(String modelName, List<ValidationRule> rules) {
    _modelRules[modelName] = [...(_modelRules[modelName] ?? []), ...rules];
    final validator = Validator()..addRules(_modelRules[modelName]!);
    _dataValidator.registerValidator(modelName, validator);
  }
} 