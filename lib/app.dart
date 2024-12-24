import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/providers/app_state.dart';
import 'core/routes/app_router.dart';
import 'core/services/service_provider.dart';
import 'core/themes/app_theme.dart';

class MoneyTrackerApp extends StatelessWidget {
  final _serviceProvider = ServiceProvider();
  final _appConfig = AppConfig();

  Future<void> initialize() async {
    await _serviceProvider.initialize();
    await _appConfig.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final themeMode = appState.themeManager.themeMode;

    return MaterialApp.router(
      title: 'Money Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
    );
  }
} 