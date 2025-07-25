import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/services/notification_service.dart';
import 'package:frontend/welcome_screen/splash_screen.dart';
import 'package:frontend/welcome_screen/welcome_tutorial_screen.dart';
import 'package:frontend/welcome_screen/signup_screen.dart';
import 'package:frontend/welcome_screen/signin_screen.dart';
import 'package:frontend/welcome_screen/forgotpassword_screen.dart';
import 'package:frontend/home_page.dart';
import 'profile_screen/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

// Import Device Preview
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';

Future<void> main() async{
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  // Wrap your app with DevicePreview
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: DevicePreview(
        enabled: false,
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      // ignore: deprecated_member_use
      useInheritedMediaQuery: true, // IMPORTANT: enables responsiveness with Device Preview
      locale: DevicePreview.locale(context), // to use Device Preview locale
      builder: DevicePreview.appBuilder, // wraps app for responsiveness & preview
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      home: SplashScreen(),
      routes: {
        '/welcome': (context) => WelcomeTutorialScreen(),
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen(),
        '/home': (context) => HomePage(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
      },
    );
  }
}
