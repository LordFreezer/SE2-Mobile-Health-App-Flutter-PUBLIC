import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project1/controller/auth_controller.dart';
import 'package:project1/model/constants.dart';
import 'package:project1/model/passwordReset_screen_model.dart';
import 'package:project1/viewscreen/view/view_util.dart';

class PasswordResetScreen extends StatefulWidget{
  const PasswordResetScreen({Key? key}) : super(key: key);

  static const routeName = '/passwordResetScreen';

  @override
  State<StatefulWidget> createState() {
    return _PasswordResetState();
  }

}

class _PasswordResetState extends State<PasswordResetScreen>{

  late _Controller con;
  late PasswordResetScreenModel screenModel;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    screenModel = PasswordResetScreenModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Reset'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter Email',
                  ),
                  initialValue: screenModel.email,
                  autocorrect: false,
                  validator: screenModel.validateEmail,
                  onSaved: screenModel.saveEmail,
                ),
                ElevatedButton(
                  onPressed: con.resetPassword,
                  child: Text(
                    'Reset Password',
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }

}

class _Controller{
  _PasswordResetState state;
  _Controller(this.state);

  Future<void> resetPassword() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    try {
      await Auth.passwordReset(email: state.screenModel.email!);
      if(state.mounted){
      Navigator.of(state.context).pop();  //go back to sign in screen
      } 
      }on FirebaseAuthException catch(e){
      if(Constant.devMode) print('======== Failed to create: $e');
      showSnackBar(context: state.context, message: '${e.code} ${e.message}', seconds: 5);
    } catch (e) {
      if(Constant.devMode) print('======== Failed to create: $e');
      showSnackBar(context: state.context, message: 'Failed to Create: $e', seconds: 5);
    }
  }
}