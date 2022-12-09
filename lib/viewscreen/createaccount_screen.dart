import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project1/controller/auth_controller.dart';
import 'package:project1/controller/firestore_controller.dart';
import 'package:project1/model/constants.dart';
import 'package:project1/model/createaccount_screen_model.dart';
import 'package:project1/model/user_info.dart';
import 'package:project1/viewscreen/view/view_util.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  static const routeName = '/createAccountScreen';

  @override
  State<StatefulWidget> createState() {
    return _CreateAccountState();
  }
}

class _CreateAccountState extends State<CreateAccountScreen> {
  late _Controller con;
  late CreateAccountScreenModel screenModel;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    screenModel = CreateAccountScreenModel();
  }

  void render(fn) {
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a new account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Text(
                  'Create New Account',
                  style: Theme.of(context).textTheme.headline5,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter Email',
                  ),
                  initialValue: screenModel.email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: screenModel.validateEmail,
                  onSaved: screenModel.saveEmail,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter Password',
                  ),
                  initialValue: screenModel.password,
                  autocorrect: false,
                  obscureText: !screenModel.showPasswords,
                  validator: screenModel.validatePassword,
                  onSaved: screenModel.savePassword,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Confirm Password',
                  ),
                  initialValue: screenModel.passwordConfirm,
                  autocorrect: false,
                  obscureText: !screenModel.showPasswords,
                  validator: screenModel.validatePassword,
                  onSaved: screenModel.savePasswordConfirm,
                ),
                //add username
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter Username',
                  ),
                  initialValue: screenModel.username,
                  autocorrect: false,
                  validator: screenModel.validateUsername,
                  onSaved: screenModel.saveUsername,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: screenModel.showPasswords,
                      onChanged: con.showHidePasswords,
                    ),
                    const Text('Show Passwords'),
                  ],
                ),
                ElevatedButton(
                  onPressed: con.create,
                  child: Text(
                    'Create',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _CreateAccountState state;
  _Controller(this.state);
  UserInformation tempInfo = UserInformation();

  Future<void> create() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    if (state.screenModel.password != state.screenModel.passwordConfirm) {
      showSnackBar(
        context: state.context,
        message: 'Passwords do not match',
        seconds: 5,
      );
      return;
    }

    try {
      await Auth.createAccount(
        email: state.screenModel.email!,
        password: state.screenModel.password!,
      );
      //account created!

      //this is where the username will be uploaded to firestore***
      tempInfo.user = state.screenModel.email;
      tempInfo.username = state.screenModel.username;
      tempInfo.userPhotoURL = '';
      tempInfo.docID = '';
      tempInfo.photoFilename = '';
      tempInfo.phone = '';
      tempInfo.biography = '';
      String docID = await FirestoreController.addUserInfo(
          userInfo: tempInfo); //passes email)
      print('============docID: $docID');
      tempInfo.docID = docID;
      await FirestoreController.replaceDocID(
          docID: tempInfo.docID!, documentID: tempInfo.docID!);

      if (state.mounted) {
        Navigator.of(state.context).pop(); //go back to sign in screen
      }
    } on FirebaseAuthException catch (e) {
      if (Constant.devMode) print('======== Failed to create: $e');
      showSnackBar(
          context: state.context,
          message: '${e.code} ${e.message}',
          seconds: 5);
    } catch (e) {
      if (Constant.devMode) print('======== Failed to create: $e');
      showSnackBar(
          context: state.context, message: 'Failed to Create: $e', seconds: 5);
    }
  }

  void showHidePasswords(bool? value) {
    if (value != null) {
      state.render(() {
        state.screenModel.showPasswords = value;
      });
    }
  }
}
