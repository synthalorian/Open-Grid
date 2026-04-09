import 'package:flutter/material.dart';
import 'theme/grid_theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const OpenGridApp());
}

class OpenGridApp extends StatelessWidget {
  const OpenGridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open Grid',
      debugShowCheckedModeBanner: false,
      theme: GridTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
