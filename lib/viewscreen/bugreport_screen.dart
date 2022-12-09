import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:project1/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:project1/model/activity_model.dart';
import 'package:project1/model/doctor_model.dart';
import 'package:project1/viewscreen/activity_screen.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../model/constants.dart';
import '../model/user_info.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class BugScreen extends StatefulWidget {
  static const routeName = '/bugScreen';
  final UserInformation user;

  const BugScreen({required this.user, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BugState();
  }
}

class _BugState extends State<BugScreen> {
  late _Controller con;
  final formKey = GlobalKey<FormState>();

  late String body;
  late String title;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tell us what is wrong"), actions: []),
      body: ListView(
        children: [
          TextField(
            decoration: InputDecoration(labelText: "Type of Problem"),
            onChanged: (value) {
              title = value;
            },
          ),
          TextField(
            maxLines: 8, //or null
            decoration: InputDecoration(labelText: "Description of Problem"),
            onChanged: (value) {
              body = value;
            },
          ),
          TextButton(
              onPressed: (() {
                con.createIssue();
              }),
              child: const Text("Send"))
        ],
      ),
    );
  }
}

class _Controller {
  _BugState state;
  _Controller(this.state);

  void createIssue() async {
    final response = await http.post(
      Uri.parse(
          'https://api.github.com/repos/lordfreezer/SE2-Mobile-Health-App-Flutter-PUBLIC/issues'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Accept": "application/vnd.github+json",
        'Authorization':
            'token GITHUB_TOKEN'
      },
      // MAYBE application/vnd.github+json
      body: jsonEncode(<String, String>{
        'owner': 'lordfreezer',
        'repo': 'SE2-Mobile-Health-App-Flutter-PUBLIC',
        'title': state.title,
        'body': "${state.body} by ${state.widget.user.user}",
      }),
    );

    test('GitHub Status code: Expected 201', () {
      expect(response.statusCode.toInt(), 201);
    });

    Navigator.pop(state.context);
  }
}
