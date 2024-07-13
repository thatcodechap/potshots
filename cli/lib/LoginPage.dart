import 'package:cli/SignUpPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'DashboardPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  String _emailError = '';
  String _passwordError = '';
  String _error = '';

  final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');

  void _submitForm() async {
    setState(() {
      _emailError = '';
      _passwordError = '';
    });

    bool hasError = false;

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      hasError = true;
    } else if (!emailRegex.hasMatch(_emailController.text)) {
      setState(() {
        _emailError = 'Enter a valid email address';
      });
      hasError = true;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      hasError = true;
    }

    if (!hasError) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final responseJson = json.decode(response.body);
      if (responseJson.containsKey('token')) {
        developer.log(responseJson['token']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseJson['token']);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(),
            ),
                (Route<dynamic> route)=>false
        );
      } else {
        setState(() {
          _error = responseJson['error'];
        });
      }
    }
  }

  void _clearErrorMessages() {
    setState(() {
      _emailError = '';
      _passwordError = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/banner.png', width: 200,),
                  // Placeholder for the image
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please sign in to your account',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: const TextStyle(color: Colors.grey),
                      // filled: true,
                      // fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0XFFD78217))
                      ),
                      errorText: _emailError.isNotEmpty ? _emailError : null,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      _clearErrorMessages();
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      // filled: true,
                      // fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0XFFD78217))
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons
                              .visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      errorText: _passwordError.isNotEmpty
                          ? _passwordError
                          : null,
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: !_passwordVisible,
                    onChanged: (value) {
                      _clearErrorMessages();
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      _submitForm();
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to forgot password page
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  MaterialButton(
                    onPressed: _submitForm,
                    color: Colors.white,
                    height: 50,
                    minWidth: double.infinity,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_error.isNotEmpty)
                    Text(
                      _error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (
                          context) => const SignUpPage()));
                    },
                    child: const Text(
                      'Don\'t have an account? Create one',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}