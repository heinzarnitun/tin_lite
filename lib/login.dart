import 'package:flutter/material.dart';

//login screen takes a login function and correct pin
class LoginScreen extends StatefulWidget {
  final Function(String) onLogin;
  final String correctPin;

  const LoginScreen({
    required this.onLogin,
    required this.correctPin,
    Key? key,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _enteredPin = ""; //stores the pin entered by the user

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();

  //called when user taps login or finishes entering 4 digits
  void _login() {
    if (_enteredPin == widget.correctPin) {
      widget.onLogin(_enteredPin); //call the login function passed from parent
    } else {
      //show error if pin is incorrect
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Incorrect PIN"),
          content: const Text("Please enter the correct PIN."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _enteredPin = "";
                });
                _focusNode1.requestFocus();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // base layout for screen
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_background.png'), // Your image here
            fit: BoxFit.cover, // Adjust the image to cover the screen
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Enter PIN to continue"),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPinDigitField(
                      focusNode: _focusNode1,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() => _enteredPin += value);
                          _focusNode2.requestFocus();
                        }
                      },
                    ),
                    _buildPinDigitField(
                      focusNode: _focusNode2,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() => _enteredPin += value);
                          _focusNode3.requestFocus();
                        }
                      },
                    ),
                    _buildPinDigitField(
                      focusNode: _focusNode3,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() => _enteredPin += value);
                          _focusNode4.requestFocus();
                        }
                      },
                    ),
                    _buildPinDigitField(
                      focusNode: _focusNode4,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() => _enteredPin += value);
                          if (_enteredPin.length == 4) {
                            _login();
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color (black)
                    foregroundColor: Colors.white, // Text color (white)
                  ),
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//helper widget to build one digit input field
  Widget _buildPinDigitField({
    required FocusNode focusNode,
    required Function(String) onChanged,
  }) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        obscureText: true,
        keyboardType: TextInputType.number,
        maxLength: 1,
        focusNode: focusNode,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

