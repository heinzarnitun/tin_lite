import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';

// Entry point
void main() {
  runApp(MyApp());
}

// Main app widget that manages the login state
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// State class for MyApp
class _MyAppState extends State<MyApp> {
  // Track whether the user is logged in
  bool _isLoggedIn = false;

  // Pin used for login
  final String _pin = "1234";

  // Function to handle login
  void _handleLogin(String pin) {
    setState(() {
      // Set login state to true after login
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Theme setup
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Show either login screen or home depending on login status
      home: Scaffold(
        body: Stack(
          children: [
            _isLoggedIn
                ? HomeScreen()
                : LoginScreen(
              onLogin: _handleLogin,
              correctPin: _pin,
            ),
            // Text at the bottom of the screen
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Developed by Hain Zarni Tun',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
