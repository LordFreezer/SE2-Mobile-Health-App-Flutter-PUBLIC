import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project1/model/doctor_model.dart';
import 'dart:io';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../model/constants.dart';
import '../model/user_info.dart';
import 'email_screen.dart';

class DoctorScreen extends StatefulWidget {
  static const routeName = '/doctorScreen';
  final User user;
  final List<Doctor> doctorList;

  const DoctorScreen({required this.user, required this.doctorList, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DoctorState();
  }
}

class _DoctorState extends State<DoctorScreen> {
  late _Controller con;
  final formKey = GlobalKey<FormState>();
  late Doctor doctor;
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("My Doctors"), actions: []),
        body: ListView.builder(
          itemCount: widget.doctorList.length,
          itemBuilder: (context, index) {
            return Center(
              child: TextButton(
                  onPressed: () async {
                    doctor = widget.doctorList[index];
                    con.navigateEmailScreen();
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                        child: Container(
                          constraints: const BoxConstraints(
                            maxHeight: 75,
                            maxWidth: 75,
                          ),
                          child:
                              Image.network(widget.doctorList[index].docImg!),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Container(
                          padding: const EdgeInsets.all(0.0),
                          width: 10,
                          height: 40,
                        ), //Container
                      ),
                      Text(
                        widget.doctorList[index].name!,
                        style: const TextStyle(height: 0, fontSize: 20),
                      ),
                    ],
                  )),
            );
          },
        ));
  }
}

class _Controller {
  _DoctorState state;
  _Controller(this.state);

  void navigateEmailScreen() async {
    await Navigator.pushNamed(state.context, EmailScreen.routeName, arguments: {
      ArgKey.user: state.widget.user,
      ArgKey.doctor: state.doctor
    });
  }
}
