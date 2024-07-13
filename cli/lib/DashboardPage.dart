import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class DashboardPage extends StatefulWidget {
  @override
  _PotListPageState createState() => _PotListPageState();
}

class _PotListPageState extends State<DashboardPage> {
  Future<List<Pot>> fetchPots() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/pot'), headers: {
      'Authorization': 'Bearer '+token!,
    });

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['pots'];
      List<Pot> pots = body.map((dynamic item) => Pot.fromJson(item)).toList();
      return pots;
    } else {
      throw Exception('Failed to load pots');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pots List'),
      ),
      body: FutureBuilder<List<Pot>>(
        future: fetchPots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pots found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Pot pot = snapshot.data![index];
                return ListTile(
                  title: Text(pot.goal),
                  subtitle: Text(pot.targetDate),
                  trailing: Text('${pot.balance}\$'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Pot {
  final int id;
  final String goal;
  final int target;
  final int balance;
  final String targetDate;
  final String creationDate;
  final String owner;
  final int locked;

  Pot({
    required this.id,
    required this.goal,
    required this.target,
    required this.balance,
    required this.targetDate,
    required this.creationDate,
    required this.owner,
    required this.locked,
  });

  factory Pot.fromJson(Map<String, dynamic> json) {
    return Pot(
      id: json['id'],
      goal: json['goal'],
      target: json['target'],
      balance: json['balance'],
      targetDate: json['targetDate'],
      creationDate: json['creationDate'],
      owner: json['owner'],
      locked: json['locked'],
    );
  }
}
