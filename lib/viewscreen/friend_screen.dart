// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:project1/model/user_info.dart';
import 'package:project1/viewscreen/view/view_util.dart';
import '../controller/firestore_controller.dart';
import '../model/activity_model.dart';
import '../model/constants.dart';
import 'friend_compare_screen.dart';

class FriendScreen extends StatefulWidget {
  static const String routeName = '/friendscreen';
  final UserInformation user;

  const FriendScreen({
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FriendState();
  }
}

class _FriendState extends State<FriendScreen> {
  late _Controller con;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    con.friends = widget.user.friends;
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: const Text("friends Screen"), actions: [
        Row(
          children: [
            Form(
              key: formKey,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Center(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Search Friends',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    autocorrect: true,
                    onSaved: con.saveSearch,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: con.search,
              icon: const Icon(Icons.search),
            ),
          ],
        )
      ]),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('You have ${widget.user.friends.length} friends'),
            for (String friend in con.friends)
              Column(
                children: [
                  ListTile(
                    tileColor: Colors.white,
                    leading: Icon(
                      Icons.account_circle,
                      size: 60,
                      color: Colors.blue[900],
                    ),
                    title: Text(UserInformation.getFriendName(friend)),
                    subtitle: Text(UserInformation.getFriendEmail(friend)),
                    trailing: IconButton(
                      onPressed: () => con.removeFriend(friend),
                      icon: const Icon(Icons.person_remove),
                    ),
                    onTap: () {
                      con.openFriend(UserInformation.getFriendEmail(friend));
                    },
                  ),
                  const SizedBox(height: 5),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  String? query;
  late List<dynamic> friends;
  _FriendState state;
  _Controller(this.state);

  void saveSearch(String? value) {
    query = value;
  }

  void search() {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null) {
      return;
    }
    currentState.save();
    if (query == null || query!.trim() == '') {
      friends = state.widget.user.friends;
    } else {
      friends = [];
      for (String c in state.widget.user.friends) {
        if (c.toLowerCase().contains(query!.toLowerCase())) {
          friends.add(c);
        }
      }
    }
    state.render(() {});
  }

  void removeFriend(String c) async {
    try {
      Map<String, dynamic> update = {};
      state.widget.user.friends.remove(c);
      friends.remove(c);
      update[DocKeyUserInfo.friends.name] = state.widget.user.friends;
      String id =
          await FirestoreController.getUserDocID(state.widget.user.user!);
      await FirestoreController.updateUserInfo(docID: id, update: update);

      showSnackBar(
        context: state.context,
        message: 'Friend deleted.',
      );
      state.render(() {});
    } catch (e) {
      Navigator.of(state.context).pop();
      showSnackBar(
        context: state.context,
        message: 'Friend delete failed: $e',
      );
    }
  }

  void openFriend(String email) async {
    try {
      UserInformation friend =
          await FirestoreController.getUserInfo(email: email);
      List<Activity> userActivities = await FirestoreController.getActivityList(
          email: state.widget.user.user!);
      List<Activity> friendActivities =
          await FirestoreController.getActivityList(email: friend.user!);
      Navigator.pushNamed(state.context, FriendCompareScreen.routeName,
          arguments: {
            ArgKey.user: state.widget.user,
            ArgKey.friend: friend,
            ArgKey.activityList: userActivities,
            ArgKey.friendActivityList: friendActivities,
          });
    } catch (e) {
      showSnackBar(context: state.context, message: e.toString());
    }
  }
}
