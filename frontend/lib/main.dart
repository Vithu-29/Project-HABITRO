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

// Device Preview
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();

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
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,

      // 🔥 Apply font scaling globally here
      builder: (context, child) {
        return DevicePreview.appBuilder(
          context,
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: themeProvider.fontScaleFactor,
            ),
            child: child!,
          ),
        );
      },

      home: const SplashScreen(),
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
