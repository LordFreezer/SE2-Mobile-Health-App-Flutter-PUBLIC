import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project1/controller/auth_controller.dart';
import 'package:project1/viewscreen/home_screen.dart';
import 'package:project1/viewscreen/signin_screen.dart';

class StartDispatcher extends StatelessWidget{
  static const routeName = '/startDispatcher';

  const StartDispatcher({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: null,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //Auth.user = snapshot.data;
        // return Auth.user == null ? const SignInScreen(): const HomeScreen();
        return const SignInScreen();
      },
    );
  }

}