import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project1/controller/firestore_controller.dart';
import 'package:project1/model/constants.dart';
import 'package:project1/model/logs_model.dart';
import 'package:project1/viewscreen/view/view_util.dart';

class LogsScreen extends StatefulWidget {
  static const routeName = '/logsScreen';
  final User user;
  List<String> logsList;
  List<bool> completed;

  LogsScreen(
      {required this.user,
      required this.logsList,
      required this.completed,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LogsScreen();
  }
}

class _LogsScreen extends State<LogsScreen> {
  late _Controller con;
  late Logs screenModel;
  final formKey = GlobalKey<FormState>();
  List<String> logs =
      []; /* = [
    'Banana',
    'Nice Picture',
    'Comment',
    'Something Very Long, Does it fit, I need more words to check fi it does work, what happens if i add even more word to this long sentence lets find out!'
  ];*/
  List<bool> completed = [];

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    screenModel = Logs();
    logs.addAll(widget.logsList);
    completed.addAll(widget.completed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: con.createForm,
        child: const Icon(Icons.add),
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      appBar: AppBar(
        title: const Text('Logs Screen'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          //get logs printed out then add completed button then figure out daily update portion
          Expanded(
            child: con.buildLogsList(logs),
          ),
        ],
      ),
    );
  }
}

class _Controller {
  _LogsScreen state;
  _Controller(this.state);
  Logs tempInfo = Logs();

  Widget createForm() {
    return SafeArea(
      child: FutureBuilder<dynamic>(
          future: showDialog(
            context: state.context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Stack(
                  //overflow: Overflow.visible,
                  children: <Widget>[
                    Positioned(
                      right: -40.0,
                      top: -40.0,
                      child: InkResponse(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          child: Icon(Icons.close),
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                    Form(
                      key: state.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Message'),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2.0),
                            child: TextFormField(
                              initialValue: state.screenModel.logs,
                              minLines: 1,
                              maxLines: 10,
                              onSaved: state.screenModel.saveLogs,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: TextButton(
                              child: Text('Submit'),
                              onPressed: submit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            throw UnimplementedError();
          }),
    );
  }

  void submit() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    tempInfo.email = state.widget.user.email;
    tempInfo.logs = state.screenModel.logs!;
    tempInfo.completed = false;
    state.logs.add(state.screenModel.logs.toString().trim());

    await FirestoreController.addLogs(logs: tempInfo);
    state.widget.logsList.clear();
    state.widget.completed.clear();
    state.widget.logsList =
        await FirestoreController.getLogsList(email: state.widget.user.email!);
    state.widget.completed =
        await FirestoreController.getCompleted(email: state.widget.user.email!);
    state.completed.clear();
    state.logs.clear();
    state.logs.addAll(state.widget.logsList);
    state.completed.addAll(state.widget.completed);
    for (int i = 0; i < state.completed.length; i++) {
      print(state.completed[i].toString());
    }
    state.formKey.currentState!.reset(); //this is causing a problem, need to reset form field
    state.setState(() {});
    Navigator.of(state.context).pop();
  }

  Widget buildLogsList(data) {
    return ListView(
      children: [
        for (var i = 0; i < data.length; i++)
          ListTile(
            //add trailing edit/delete
            tileColor:
                state.completed[i] == false ? Colors.black: Colors.yellow[600],
            leading: 
              IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () => deleteLog(i),
                iconSize: 30,
                color: Colors.red,
              ),
            //CircleAvatar(
            //   backgroundColor: Colors.red,
            //   foregroundColor: Colors.black,
            //   maxRadius: 30,
            //   minRadius: 10,
            //   child: Text(state.widget.user.email.toString().substring(0, 1)),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     print('comments was clicked');
            //   },
            //   child: Container(
            //     height: 200.0,
            //     width: 200.0,

            //   ),
            // ),
            title: Text(
              data[i],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
            // subtitle: Text(
            //   state.widget.photoTime[i].toString(),
            // ),
            trailing: Checkbox(
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.white.withOpacity(.32);
                }
                return Colors.white;
              }),
              value: state.completed[
                  i], //need to figure out how to keep them in order when adding a new one
              onChanged: (bool? value) async {
                if (state.completed[i] == false) {
                  state.completed[i] = true;
                  String logComment = state.widget.logsList[i].toString();
                  String change =
                      await FirestoreController.getLogs(comment: logComment);
                  await FirestoreController.replaceLogCompleted(
                      docID: change, completed: true);
                } else {
                  state.completed[i] = false;
                  String logComment = state.widget.logsList[i].toString();
                  String change =
                      await FirestoreController.getLogs(comment: logComment);
                  await FirestoreController.replaceLogCompleted(
                      docID: change, completed: false);
                }
                state.setState(() {});
              },
            ),
          ),
      ],
    );
  }

  void deleteLog(int i) async {
    try {
      for (int j = state.widget.logsList.length - 1; j >= 0; j--) {
        if (state.widget.logsList[j].contains(state.logs[i])) {
          String comment = state.widget.logsList[j].toString();
          print(comment);
          String p = await FirestoreController.getLogs(comment: comment);
          print(p);
          await FirestoreController.deleteLogs(p);
          state.logs.removeAt(i);
          state.widget.logsList = await FirestoreController.getLogsList(
              email: state.widget.user.email!);
          state.widget.completed = await FirestoreController.getCompleted(
              email: state.widget.user.email!);
          state.setState(() {});
        }
      }
    } catch (e) {
      if (Constant.devMode) print('======== failed to delete: $e');
      showSnackBar(
        context: state.context,
        seconds: 20,
        message: 'Failed! Delete Needs Fixing in Logs\n $e',
      );
    }
  }

  bool change() {
    return true;
  }
}
