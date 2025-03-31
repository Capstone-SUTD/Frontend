import 'package:capstone_app/common/login_signup_screen.dart';
import 'package:flutter/material.dart';

class WebSplashScreen extends StatefulWidget {
  @override
  _WebSplashScreenState createState() => _WebSplashScreenState();
}

class _WebSplashScreenState extends State<WebSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup fade controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Start fading after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _controller.forward();
    });

    // After fade completes, navigate to login
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginSignUpScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: 'OOG ', style: TextStyle(color: Colors.red)),
                TextSpan(
                    text: 'Navigator', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
