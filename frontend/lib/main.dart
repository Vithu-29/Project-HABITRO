import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/welcome_screen/splash_screen.dart';
import 'package:frontend/welcome_screen/welcome_tutorial_screen.dart';
import 'package:frontend/welcome_screen/signup_screen.dart';
import 'package:frontend/welcome_screen/signin_screen.dart';
import 'package:frontend/welcome_screen/forgotpassword_screen.dart';
import 'package:frontend/home_page.dart';
import 'theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
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
