/// 验证工具类
class ValidationUtils {
  /// 验证非空
  static void validateNotNull(dynamic value, String fieldName) {
    if (value == null) {
      throw ArgumentError('$fieldName 不能为空');
    }
  }

  /// 验证列表非空
  static void validateNotEmpty<T>(List<T>? list, String fieldName) {
    validateNotNull(list, fieldName);
    if (list!.isEmpty) {
      throw ArgumentError('$fieldName 不能为空列表');
    }
  }

  /// 验证字符串非空
  static void validateStringNotEmpty(String? value, String fieldName) {
    validateNotNull(value, fieldName);
    if (value!.trim().isEmpty) {
      throw ArgumentError('$fieldName 不能为空字符串');
    }
  }

  /// 验证数值范围
  static void validateNumberRange(
    num value,
    String fieldName, {
    num? min,
    num? max,
  }) {
    if (min != null && value < min) {
      throw ArgumentError('$fieldName 不能小于 $min');
    }
    if (max != null && value > max) {
      throw ArgumentError('$fieldName 不能大于 $max');
    }
  }

  /// 验证日期范围
  static void validateDateRange(
    DateTime startDate,
    DateTime endDate, {
    String startFieldName = 'startDate',
    String endFieldName = 'endDate',
  }) {
    validateNotNull(startDate, startFieldName);
    validateNotNull(endDate, endFieldName);
    if (startDate.isAfter(endDate)) {
      throw ArgumentError('$startFieldName 不能晚于 $endFieldName');
    }
  }

  /// 验证电子邮件格式
  static void validateEmail(String? email, {String fieldName = 'email'}) {
    validateStringNotEmpty(email, fieldName);
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    if (!emailRegex.hasMatch(email!)) {
      throw ArgumentError('$fieldName 格式不正确');
    }
  }

  /// 验证手机号格式
  static void validatePhone(String? phone, {String fieldName = 'phone'}) {
    validateStringNotEmpty(phone, fieldName);
    final phoneRegex = RegExp(r'^\d{11}$');
    if (!phoneRegex.hasMatch(phone!)) {
      throw ArgumentError('$fieldName 格式不正确');
    }
  }

  /// 验证密码强度
  static void validatePassword(String? password, {String fieldName = 'password'}) {
    validateStringNotEmpty(password, fieldName);
    if (password!.length < 8) {
      throw ArgumentError('$fieldName 长度不能小于8位');
    }
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigits = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    if (!hasUpperCase || !hasLowerCase || !hasDigits || !hasSpecialCharacters) {
      throw ArgumentError('$fieldName 必须包含大小写字母、数字和特殊字符');
    }
  }

  /// 验证URL格式
  static void validateUrl(String? url, {String fieldName = 'url'}) {
    validateStringNotEmpty(url, fieldName);
    final urlRegex = RegExp(
      r'^(http|https)://[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(:[0-9]+)?(\/\S*)?$',
    );
    if (!urlRegex.hasMatch(url!)) {
      throw ArgumentError('$fieldName 格式不正确');
    }
  }

  /// 验证文件大小
  static void validateFileSize(
    int size,
    int maxSize, {
    String fieldName = 'file',
  }) {
    if (size > maxSize) {
      final maxSizeMB = maxSize / (1024 * 1024);
      throw ArgumentError('$fieldName 大小不能超过 ${maxSizeMB}MB');
    }
  }

  /// 验证文件类型
  static void validateFileType(
    String fileName,
    List<String> allowedExtensions, {
    String fieldName = 'file',
  }) {
    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      throw ArgumentError(
        '$fieldName 类型必须是 ${allowedExtensions.join(', ')} 之一',
      );
    }
  }

  /// 验证金额
  static void validateAmount(
    double amount, {
    String fieldName = 'amount',
    double? min,
    double? max,
  }) {
    validateNumberRange(amount, fieldName, min: min, max: max);
    final decimalPlaces = amount.toString().split('.').last.length;
    if (decimalPlaces > 2) {
      throw ArgumentError('$fieldName 小数位数不能超过2位');
    }
  }

  /// 验证ID格式
  static void validateId(String? id, {String fieldName = 'id'}) {
    validateStringNotEmpty(id, fieldName);
    final idRegex = RegExp(r'^[a-zA-Z0-9\-_]+$');
    if (!idRegex.hasMatch(id!)) {
      throw ArgumentError('$fieldName 格式不正确');
    }
  }

  /// 验证枚举值
  static void validateEnum<T>(
    T value,
    List<T> validValues, {
    String fieldName = 'value',
  }) {
    if (!validValues.contains(value)) {
      throw ArgumentError(
        '$fieldName 必须是 ${validValues.join(', ')} 之一',
      );
    }
  }

  /// 验证经纬度
  static void validateLatLng(
    double lat,
    double lng, {
    String latFieldName = 'latitude',
    String lngFieldName = 'longitude',
  }) {
    validateNumberRange(lat, latFieldName, min: -90, max: 90);
    validateNumberRange(lng, lngFieldName, min: -180, max: 180);
  }

  /// 验证颜色值
  static void validateColor(String? color, {String fieldName = 'color'}) {
    validateStringNotEmpty(color, fieldName);
    final colorRegex = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$');
    if (!colorRegex.hasMatch(color!)) {
      throw ArgumentError('$fieldName 格式不正确');
    }
  }

  /// 验证版本号
  static void validateVersion(String? version, {String fieldName = 'version'}) {
    validateStringNotEmpty(version, fieldName);
    final versionRegex = RegExp(r'^\d+\.\d+\.\d+$');
    if (!versionRegex.hasMatch(version!)) {
      throw ArgumentError('$fieldName 格式不正确');
    }
  }
} 