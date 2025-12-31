import 'package:flutter/material.dart';
import 'package:scure_pass/views/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent.shade100,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );

    final darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent.shade100,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
    return MaterialApp(
      title: 'Scure Pass',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: LoginView(),
    );
  }
}
