import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:publishify/utils/theme.dart';
import 'package:publishify/routes/app_routes.dart';

Future<void> main() async {
  // Load .env file
  await dotenv.load(fileName: ".env");
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Publishify',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
