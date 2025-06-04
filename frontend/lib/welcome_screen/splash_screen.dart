import "package:flutter/material.dart";
import 'dart:async';
import 'package:frontend/welcome_screen/welcome_tutorial_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                IntroScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0AB0D6), Theme.of(context).colorScheme.primary]
          )
        ),
      ),
    );
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool showLogo = false;
  bool startCircleAnimation = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500),() {
      if (mounted) setState(() => showLogo = true);
    });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) setState(() => startCircleAnimation = true,);
    });

    Future.delayed(Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:(context, animation, secondaryAnimation) => 
              WelcomeTutorialScreen(),
              transitionsBuilder:(context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child,);
              },
          )
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0AB0D6), Theme.of(context).colorScheme.primary]
              )
            ),
          ),
          Center(
            child: AnimatedOpacity(
              opacity: showLogo ? 1.0 : 0.0, 
              duration: Duration(milliseconds: 1500),
              child: Image.asset(
                "assets/images/logo_white.png",
                width: 200,
                height: 50,
              ),
              ),
          ),
          if (startCircleAnimation) AnimatedCircleTransition(),
        ],
      ),
    );
  }
}

class AnimatedCircleTransition extends StatefulWidget {
  const AnimatedCircleTransition({super.key});

  @override
  State<AnimatedCircleTransition> createState() => _AnimatedCircleTransitionState();
}

class _AnimatedCircleTransitionState extends State<AnimatedCircleTransition> {
  double radius = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          radius = 2000;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: radius),
      duration: Duration(seconds: 1),
      builder: (context, value, child) {
        return ClipPath(
          clipper: CircleClipper(value),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

class CircleClipper extends CustomClipper<Path> {
  final double radius;

  CircleClipper(this.radius);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addOval(
      Rect.fromCircle(center: size.center(Offset.zero), radius: radius));
    return path;
  }

  @override
  bool shouldReclip (CircleClipper oldClipper) {
    return oldClipper.radius != radius;
  }
}
 //for check