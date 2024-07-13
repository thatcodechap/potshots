import 'package:cli/LoginPage.dart';
import 'package:cli/OtpPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  String _nameError = '';
  String _emailError = '';
  String _error = '';
  String _passwordError = '';
  String _confirmPasswordError = '';

  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');

  void _submitForm() async {
    setState(() {
      _nameError = '';
      _emailError = '';
      _passwordError = '';
      _confirmPasswordError = '';
    });

    bool hasError = false;

    if (_nameController.text.isEmpty) {
      setState(() {
        _nameError = 'Full Name is required';
      });
      hasError = true;
    }

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

    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Confirm Password is required';
      });
      hasError = true;
    } else if (_confirmPasswordController.text != _passwordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      hasError = true;
    }

    if (!hasError) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': _emailController.text,
          'name': _nameController.text,
          'password': _passwordController.text,
        }),
      );

      final responseJson = json.decode(response.body);
      if (responseJson.containsKey('success')) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OtpPage(email: _emailController.text)),
        );
      } else {
        setState(() {
          _error = "Unknown error";
        });
      }
    }
  }

  void _clearErrorMessages() {
    setState(() {
      _nameError = '';
      _emailError = '';
      _passwordError = '';
      _confirmPasswordError = '';
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
                  const Text(
                    'Create an Account',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Please fill the form to continue',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0XFFD78217))
                      ),
                      errorText: _nameError.isNotEmpty ? _nameError : null,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      _clearErrorMessages();
                    },
                    textInputAction: TextInputAction.next,
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
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      errorText: _passwordError.isNotEmpty ? _passwordError : null,
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: !_passwordVisible,
                    onChanged: (value) {
                      _clearErrorMessages();
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
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
                          _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                      errorText: _confirmPasswordError.isNotEmpty ? _confirmPasswordError : null,
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: !_confirmPasswordVisible,
                    onChanged: (value) {
                      _clearErrorMessages();
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      _submitForm();
                    },
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
                      'Create',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_error.isNotEmpty)
                    Text(
                      _error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                    },
                    child: const Text(
                      'Have an account? Log In',
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