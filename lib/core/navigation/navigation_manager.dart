import 'package:flutter/material.dart';

class NavigationManager {
  static final NavigationManager _instance = NavigationManager._internal();
  static NavigationManager get instance => _instance;

  NavigationManager._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // 路由名称常量
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String about = '/about';
  static const String help = '/help';
  static const String bookList = '/book-list';
  static const String bookDetail = '/book-detail';
  static const String categoryManage = '/category-manage';
  static const String accountManage = '/account-manage';
  static const String backup = '/backup';
  static const String sync = '/sync';
  static const String statistics = '/statistics';
  static const String report = '/report';

  // 路由配置
  final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    home: (context) => const MainScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    settings: (context) => const SettingsScreen(),
    profile: (context) => const ProfileScreen(),
    about: (context) => const AboutScreen(),
    help: (context) => const HelpScreen(),
    bookList: (context) => const BookListScreen(),
    bookDetail: (context) => const BookDetailScreen(),
    categoryManage: (context) => const CategoryManageScreen(),
    accountManage: (context) => const AccountManageScreen(),
    backup: (context) => const BackupScreen(),
    sync: (context) => const SyncScreen(),
    statistics: (context) => const StatisticsScreen(),
    report: (context) => const ReportScreen(),
  };

  // 路由观察者
  final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

  // 导航方法
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  Future<T?> replaceTo<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> pushAndRemoveUntil<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  void pop<T>([T? result]) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);
    }
  }

  void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  // 路由生成器
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments;

    // 检查是否是预定义路由
    final builder = routes[routeName];
    if (builder != null) {
      return MaterialPageRoute(
        builder: builder,
        settings: settings,
      );
    }

    // 处理动态路由
    if (routeName?.startsWith('/book-detail/') ?? false) {
      final bookId = routeName?.split('/').last;
      return MaterialPageRoute(
        builder: (context) => BookDetailScreen(bookId: bookId),
        settings: settings,
      );
    }

    // 未找到路由时返回404页面
    return MaterialPageRoute(
      builder: (context) => const NotFoundScreen(),
      settings: settings,
    );
  }

  // 路由中间件
  Route<dynamic>? onGenerateInitialRoute(String initialRoute) {
    // 检查用户是否已登录
    if (!isUserLoggedIn() && initialRoute != login) {
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    }

    // 检查是否需要强制更新
    if (needsForceUpdate()) {
      return MaterialPageRoute(
        builder: (context) => const UpdateScreen(),
      );
    }

    return null;
  }

  // 路由错误处理
  void onUnknownRoute(RouteSettings settings) {
    // 记录未知路由错误
    debugPrint('未知路由: ${settings.name}');
  }

  // 辅助方法
  bool isUserLoggedIn() {
    // TODO: 实现用户登录状态检查
    return false;
  }

  bool needsForceUpdate() {
    // TODO: 实现强制更新检查
    return false;
  }
} 