// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project1/controller/auth_controller.dart';
import 'package:project1/controller/firestore_controller.dart';
import 'package:project1/model/constants.dart';
import 'package:project1/model/signin_screen_model.dart';
import 'package:project1/viewscreen/createaccount_screen.dart';
import 'package:project1/viewscreen/home_screen.dart';
import 'package:project1/viewscreen/passwordreset_screen.dart';
import 'package:project1/viewscreen/view/view_util.dart';
import 'package:test/test.dart';

import '../model/CovidModel.dart';
import '../model/activity_model.dart';
import 'package:http/http.dart' as http;

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  static const routeName = '/signInScreen';

  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
  late _Controller con;
  late SignInScreenModel screenModel;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    screenModel = SignInScreenModel();
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: screenModel.isSignInUnderway
          ? const Center(child: CircularProgressIndicator())
          : signInForm(),
    );
  }

  Widget signInForm() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Health App Name',
                style: Theme.of(context).textTheme.headline3,
              ), //title
              Container(), //this will contain a logo or chart
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Email Address',
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: screenModel.validateEmail,
                onSaved: screenModel.saveEmail,
              ), //Email Sign In
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.question_mark,
                    ),
                    onPressed: con.resetPassword, //forgot password email
                  ),
                ),
                autocorrect: false,
                obscureText: true,
                validator: screenModel.validatePassword,
                onSaved: screenModel.savePassword,
              ), //Password Sign In
              ElevatedButton(
                onPressed: con.signIn,
                child: Text(
                  'Sign In',
                  style: Theme.of(context).textTheme.button,
                ), //Sign In button
              ),
              // ElevatedButton(
              //   onPressed: () {},
              //   child: Text(
              //     'Create Account',
              //     style: Theme.of(context).textTheme.button,
              //   ),
              // ), //Create Account Button
              const SizedBox(
                height: 12.0,
              ),
              TextButton(
                onPressed: con.createAccount,
                child: const Text('Have signed up yet? Create an Account.'),
              ),
              ElevatedButton(
                onPressed: con.dummySignIn,
                child: Text(
                  'Demo Test User',
                  style: Theme.of(context).textTheme.button,
                ), //Sign In button
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignInState state;
  _Controller(this.state);

  User? user;
  List<Activity> activityList = [];

  Future<List<CovidModel>> getBlob() async {
    final url = Uri.parse('https://api.covidtracking.com/v1/us/daily.json');
    final response = await http.get(url);
    // access single field: CovidModel.fromJson(jsonDecode(response.body)).date
    test('Covid API Status code: Expected 200', () {
      expect(response.statusCode, 200);
    });
    if (response.statusCode == 200) {
      List<CovidModel> mList = [];
      //print("COVID DATE: " +CovidModel.fromJson(jsonDecode(response.body)).date.toString());
      var data = json.decode(response.body);
      for (int i = 0; i < 30; i++) {
        CovidModel m = CovidModel.fromJson(json.decode(response.body)[i]);
        mList.add(m);
      }
      //return CovidModel.fromJson(jsonDecode(response.body));
      return mList;
    } else {
      throw Exception(
          'HTTP request response status is ' + response.statusCode.toString());
    }
  }

  Future<void> signIn() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;
    if (!currentState.validate()) return;
    currentState.save();

    state.render(() {
      state.screenModel.isSignInUnderway = true;
    });

    try {
      user = await Auth.signin(
        email: state.screenModel.email!,
        password: state.screenModel.password!,
      );

      var blob = getBlob();

      var tempInfo = await FirestoreController.getUserInfo(
          email: state.screenModel.email!);

      state.render(() {
        state.screenModel.isSignInUnderway = false;
      });

      Navigator.pushNamed(
        state.context,
        HomeScreen.routeName,
        arguments: {
          ArgKey.userInfo: tempInfo,
          ArgKey.user: user!,
          ArgKey.activityList: activityList,
          ArgKey.covidData: blob,
        },
      );

      //FirebaseAuth.instance.authStateChanged() will be triggered
    } on FirebaseAuthException catch (e) {
      state.render(() => state.screenModel.isSignInUnderway = false);
      var error = 'Sign In Error! Reason: ${e.code} ${e.message ?? ""}';
      if (Constant.devMode) {
        print('============ $error');
      }
      showSnackBar(context: state.context, seconds: 20, message: error);
    } catch (e) {
      state.render(() => state.screenModel.isSignInUnderway = false);
      if (Constant.devMode) {
        print('============ Sign In Error! $e');
      }
      showSnackBar(
          context: state.context, seconds: 20, message: 'Sign In Error: $e');
      print('$e');
    }
  }

  void createAccount() {
    //navigate to create account screen
    Navigator.pushNamed(state.context, CreateAccountScreen.routeName);
  }

  void resetPassword() {
    Navigator.pushNamed(state.context, PasswordResetScreen.routeName);
  }

  Future<void> dummySignIn() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) return;

    state.render(() {
      state.screenModel.isSignInUnderway = true;
    });

    try {
      print("auth signin");
      user = await Auth.signin(
        email: "1@test.com",
        password: "111111",
      );
      print("post signin");
      var tempInfo = await FirestoreController.getUserInfo(email: "1@test.com");

      var blob = getBlob();
      print("Post BLOB");

      state.render(() {
        state.screenModel.isSignInUnderway = false;
      });

      Navigator.pushNamed(
        state.context,
        HomeScreen.routeName,
        arguments: {
          ArgKey.userInfo: tempInfo,
          ArgKey.user: user!,
          ArgKey.activityList: activityList,
          ArgKey.covidData: blob,
        },
      );

      //FirebaseAuth.instance.authStateChanged() will be triggered
    } on FirebaseAuthException catch (e) {
      state.render(() => state.screenModel.isSignInUnderway = false);
      var error = 'Sign In Error! Reason: ${e.code} ${e.message ?? ""}';
      if (Constant.devMode) {
        print('============ $error');
      }
      showSnackBar(context: state.context, seconds: 20, message: error);
    } catch (e) {
      state.render(() => state.screenModel.isSignInUnderway = false);
      if (Constant.devMode) {
        print('============ Sign In Error! $e');
      }
      showSnackBar(
          context: state.context, seconds: 20, message: 'Sign In Error: $e');
      print('$e');
    }
  }
}
