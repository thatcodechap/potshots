import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'DashboardPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({required this.email});

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpPage> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(4, (_) => FocusNode());
    _controllers = List.generate(4, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String get maskedEmail {
    final parts = widget.email.split('@');
    if (parts[0].length > 2) {
      return '${parts[0].substring(0, 2)}***@${parts[1]}';
    }
    return '***@${parts[1]}';
  }

  Future<void> _submitOtp() async {
    String otp = _controllers.map((controller) => controller.text).join();
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': widget.email, 'value': otp}),
    );

    final responseData = jsonDecode(response.body);

    if (responseData.containsKey('token')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', responseData['token']);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(),
        ),
          (Route<dynamic> route)=>false
      );
    } else {
      setState(() {
        _errorMessage = responseData['error'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'OTP Verification',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                'code just sent to $maskedEmail',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return _buildOtpBox(index);
                }),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              const SizedBox(height: 20),
              const Text(
                "Didn't get the otp? Resend",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                ),
                onPressed: _submitOtp,
                child: const Text(
                  'Verify',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Row(
      children: [
      SizedBox(
      width: 50,
      height: 70,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, color: Colors.white), // Adjust the font size
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.symmetric(vertical: 20.0), // Add padding
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0XFFD78217)),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 3) {
              _focusNodes[index].unfocus();
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            }
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index].unfocus();
            FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
          }
        },
      ),
    ),
        const SizedBox(width: 10)
      ],
    );
  }
}
