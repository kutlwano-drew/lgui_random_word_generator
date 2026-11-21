import 'package:flutter/material.dart';
import 'features/presentation/screens/generator_screen.dart';

void main() {
  // Guarantees Flutter services are bound before mounting widgets
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'random word generator',
      debugShowCheckedModeBanner: false,
      
      // High-contrast modern dark mode matching your background
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
          background: const Color(0xFF0D0D12),
        ),
      ),
      home: const GeneratorScreen(),
    );
  }
}