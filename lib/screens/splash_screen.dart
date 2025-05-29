import 'package:flutter/material.dart';
import 'package:vayujal/screens/login_screen.dart';
import 'package:vayujal/screens/signup_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 800), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Image.asset(
          "assets/images/ayujal_logo.png", // Your image path
          fit: BoxFit.contain,
          width: 200, // Adjust size as needed
          height: 200,
        ),
      ),
    );
  }
}
