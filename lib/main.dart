import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/home_page.dart';
import 'pages/calendar/models/calendar_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CalendarState(),
        ),
      ],
      child: MaterialApp(
        title: '记账日历',
        theme: ThemeData(
          primaryColor: const Color(0xFF6B5B95),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B5B95),
            primary: const Color(0xFF6B5B95),
          ),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'),
        ],
        home: const HomePage(),
      ),
    );
  }
} 