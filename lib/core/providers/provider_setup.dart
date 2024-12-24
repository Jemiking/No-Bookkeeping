import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

/// Provider configuration for the application
class ProviderSetup {
  /// Get all providers for the application
  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<AppState>(
        create: (_) => AppState(),
      ),
    ];
  }

  /// Wrap the application with providers
  static Widget wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: getProviders(),
      child: child,
    );
  }
} 