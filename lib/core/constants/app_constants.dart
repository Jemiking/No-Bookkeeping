/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Money Tracker';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Shared Preferences Keys
  static const String themePreference = 'theme_preference';
  static const String localePreference = 'locale_preference';
  static const String currencyPreference = 'currency_preference';

  // Default Values
  static const String defaultCurrency = 'CNY';
  static const String defaultLocale = 'zh_CN';
  
  // Database
  static const String databaseName = 'money_tracker.db';
  static const int databaseVersion = 1;

  // API Endpoints (for future use)
  static const String baseApiUrl = 'https://api.moneytracker.com';
  
  // Asset Paths
  static const String imagePath = 'assets/images';
  static const String iconPath = 'assets/icons';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Layout Constants
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultSpacing = 8.0;

  // Text Sizes
  static const double headingTextSize = 24.0;
  static const double titleTextSize = 20.0;
  static const double bodyTextSize = 16.0;
  static const double captionTextSize = 14.0;
  static const double smallTextSize = 12.0;

  // Maximum Values
  static const int maxTransactionNote = 500;
  static const int maxCategoryName = 50;
  static const int maxAccountName = 50;
  static const double maxTransactionAmount = 999999999.99;

  // Minimum Values
  static const double minTransactionAmount = 0.01;

  // Date Formats
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultTimeFormat = 'HH:mm:ss';
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // Currency Format
  static const int defaultDecimalDigits = 2;
  static const String defaultDecimalSeparator = '.';
  static const String defaultThousandsSeparator = ',';
} 