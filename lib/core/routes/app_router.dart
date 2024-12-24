import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/account_screen.dart';
import '../../screens/budget_screen.dart';
import '../../screens/budget_analysis_screen.dart';
import '../../screens/asset_analysis_screen.dart';
import '../../screens/home_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/accounts',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetScreen(),
      ),
      GoRoute(
        path: '/budget-analysis',
        builder: (context, state) => const BudgetAnalysisScreen(),
      ),
      GoRoute(
        path: '/asset-analysis',
        builder: (context, state) => const AssetAnalysisScreen(),
      ),
    ],
  );
} 