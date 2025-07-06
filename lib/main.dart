import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'notification_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const RuangBelajarApp());
}

class RuangBelajarApp extends StatefulWidget {
  const RuangBelajarApp({super.key});

  @override
  State<RuangBelajarApp> createState() => _RuangBelajarAppState();

  static _RuangBelajarAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_RuangBelajarAppState>();
}

class _RuangBelajarAppState extends State<RuangBelajarApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ruang Belajar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: const LoginPage(),
    );
  }
}
