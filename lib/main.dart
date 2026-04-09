import 'package:flutter/material.dart';
import 'theme/grid_theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const GridTapeApp());
}

class GridTapeApp extends StatelessWidget {
  const GridTapeApp({super.key});

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
