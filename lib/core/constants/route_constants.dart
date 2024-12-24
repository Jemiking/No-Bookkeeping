/// Application route constants
class RouteConstants {
  // Auth Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main Routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Transaction Routes
  static const String addTransaction = '/transaction/add';
  static const String editTransaction = '/transaction/edit';
  static const String transactionDetail = '/transaction/detail';
  static const String transactionList = '/transaction/list';

  // Account Routes
  static const String accounts = '/accounts';
  static const String addAccount = '/account/add';
  static const String editAccount = '/account/edit';
  static const String accountDetail = '/account/detail';

  // Category Routes
  static const String categories = '/categories';
  static const String addCategory = '/category/add';
  static const String editCategory = '/category/edit';

  // Budget Routes
  static const String budgets = '/budgets';
  static const String addBudget = '/budget/add';
  static const String editBudget = '/budget/edit';
  static const String budgetDetail = '/budget/detail';

  // Statistics Routes
  static const String statistics = '/statistics';
  static const String expenseAnalysis = '/statistics/expense';
  static const String incomeAnalysis = '/statistics/income';
  static const String categoryAnalysis = '/statistics/category';

  // Settings Routes
  static const String settingsProfile = '/settings/profile';
  static const String settingsSecurity = '/settings/security';
  static const String settingsNotification = '/settings/notification';
  static const String settingsAppearance = '/settings/appearance';
  static const String settingsLanguage = '/settings/language';
  static const String settingsCurrency = '/settings/currency';
  static const String settingsBackup = '/settings/backup';
  static const String settingsAbout = '/settings/about';

  // Error Routes
  static const String error = '/error';
  static const String notFound = '/404';
} 