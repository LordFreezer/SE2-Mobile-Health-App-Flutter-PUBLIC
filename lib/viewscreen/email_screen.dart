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
import 'package:test/test.dart';
import '../model/constants.dart';
import '../model/user_info.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class EmailScreen extends StatefulWidget {
  static const routeName = '/emailScreen';
  final User user;
  final Doctor doctor;

  const EmailScreen({required this.user, required this.doctor, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EmailState();
  }
}

class _EmailState extends State<EmailScreen> {
  late _Controller con;
  final formKey = GlobalKey<FormState>();
  late Doctor doctor;
  int status = 404;
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    String message = "";
    return Scaffold(
      appBar: AppBar(
          title: Text("Send an email to ${widget.doctor.name}"), actions: []),
      body: ListView(
        children: [
          TextField(
            maxLines: 8, //or null
            decoration: InputDecoration(labelText: "Message"),
            onChanged: (value) {
              message = value;
            },
          ),
          TextButton(
              onPressed: (() {
                con.sendEmail(message);
                test('Send Email Status code: Expected 200', () {
                  expect(status, 200);
                });
                Navigator.pop(context);
              }),
              child: const Text("Send"))
        ],
      ),
    );
  }
}

class _Controller {
  _EmailState state;
  _Controller(this.state);

  void sendEmail(String message) {
    final Email email = Email(
      body: message,
      subject:
          'To ${state.widget.doctor.name!} from ${state.widget.user.email}',
      recipients: [state.widget.doctor.docEmail!],
      isHTML: false,
    );
    try {
      FlutterEmailSender.send(email);
      state.status = 200;
    } catch (e) {
      state.status = 503;
    }
  }
}
