import 'package:flutter/material.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/home/main_navigation_shell.dart';

class MediCareApp extends StatefulWidget {
  const MediCareApp({super.key});

  @override
  State<MediCareApp> createState() => _MediCareAppState();
}

class _MediCareAppState extends State<MediCareApp> {
  final LocalStorageService _service = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _service.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _service.isLoggedIn
          ? const MainNavigationShell()
          : const WelcomeScreen(),
    );
  }
}
