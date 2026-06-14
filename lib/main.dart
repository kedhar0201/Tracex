import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lost_and_found/screens/splash_screen.dart';
import 'package:lost_and_found/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Wrap this in try-catch so a network failure doesn't crash the app
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Notification init failed (non-fatal): $e');
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lost & Found',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen() // Start with SplashScreen
    );
  }
}
