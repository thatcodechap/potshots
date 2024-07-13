import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'WelcomeScreen.dart';
import 'DashboardPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  runApp(MyApp(token: token,));
}

class MyApp extends StatelessWidget {
  final String? token;

  const MyApp({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: token == null ? const WelcomeScreen() : DashboardPage(),
    );
  }
}

