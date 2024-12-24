class Validators {
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return '此字段不能为空';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入金额';
    }
    if (double.tryParse(value) == null) {
      return '请输入有效的金额';
    }
    if (double.parse(value) <= 0) {
      return '金额必须大于0';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码长度不能少于6位';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }
    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      return '请输入有效的手机号';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > maxLength) {
      return '长度不能超过$maxLength个字符';
    }
    return null;
  }
} 