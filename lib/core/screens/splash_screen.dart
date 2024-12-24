import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<AppState>(
          builder: (context, appState, _) {
            if (appState.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(appState.errorMessage ?? '初始化失败'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => appState.retryInitialization(),
                    child: const Text('重试'),
                  ),
                ],
              );
            }
            
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(appState.initializationStatus),
              ],
            );
          },
        ),
      ),
    );
  }
} 