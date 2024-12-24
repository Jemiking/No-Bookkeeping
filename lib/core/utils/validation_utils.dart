import '../exceptions/validation_exception.dart';

class ValidationUtils {
  static void validateNotNull(Object? value, String paramName) {
    if (value == null) {
      throw ValidationException('Parameter $paramName cannot be null');
    }
  }

  static void validateNotEmpty<T>(List<T>? list, String paramName) {
    validateNotNull(list, paramName);
    if (list!.isEmpty) {
      throw ValidationException('List $paramName cannot be empty');
    }
  }

  static void validatePositive(num value, String paramName) {
    if (value <= 0) {
      throw ValidationException('Parameter $paramName must be positive');
    }
  }

  static void validateNonNegative(num value, String paramName) {
    if (value < 0) {
      throw ValidationException('Parameter $paramName cannot be negative');
    }
  }

  static void validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      throw ValidationException('Start date cannot be after end date');
    }
  }

  static void validateStringNotEmpty(String? value, String paramName) {
    validateNotNull(value, paramName);
    if (value!.trim().isEmpty) {
      throw ValidationException('String $paramName cannot be empty');
    }
  }

  static void validateRange(num value, num min, num max, String paramName) {
    if (value < min || value > max) {
      throw ValidationException('Parameter $paramName must be between $min and $max');
    }
  }

  static void validateId(String? id, String paramName) {
    validateStringNotEmpty(id, paramName);
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id!)) {
      throw ValidationException('Invalid $paramName format');
    }
  }

  static void validateEmail(String? email) {
    validateStringNotEmpty(email, 'email');
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email!)) {
      throw ValidationException('Invalid email format');
    }
  }

  static void validatePhone(String? phone) {
    validateStringNotEmpty(phone, 'phone');
    if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone!)) {
      throw ValidationException('Invalid phone number format');
    }
  }

  static void validateAmount(double amount) {
    if (amount.isNaN || amount.isInfinite) {
      throw ValidationException('Invalid amount value');
    }
  }

  static void validatePercentage(double percentage) {
    validateRange(percentage, 0, 100, 'percentage');
  }

  static void validateYear(int year) {
    validateRange(year, 1900, 9999, 'year');
  }

  static void validateMonth(int month) {
    validateRange(month, 1, 12, 'month');
  }

  static void validateDay(int day) {
    validateRange(day, 1, 31, 'day');
  }

  static void validateHour(int hour) {
    validateRange(hour, 0, 23, 'hour');
  }

  static void validateMinute(int minute) {
    validateRange(minute, 0, 59, 'minute');
  }

  static void validateSecond(int second) {
    validateRange(second, 0, 59, 'second');
  }
} 