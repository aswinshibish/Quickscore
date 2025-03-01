import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quickscore45/score.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuickScore',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showSplash = true;
  double _opacity = 0.0;
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Fade Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Fade animation duration
    );
    _controller.forward();

    // Start the image opacity animation
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Start the text opacity animation
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _textOpacity = 1.0;
      });
    });

    // Navigate to QuickScoreScreen after 3 seconds
    Timer(Duration(seconds: 4), () {
      setState(() {
        _showSplash = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => QuickScoreScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: _showSplash
          ? Stack(
              children: [
                Center(
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(seconds: 2),
                    child: Image.asset(
                      'image/Card1.jpg',
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _textOpacity,
                      duration: const Duration(seconds: 2),
                      child: Text(
                        'QuickScore',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }
}
