import 'package:flutter/material.dart';
import 'package:project1/model/user_info.dart';
import 'package:project1/viewscreen/view/view_util.dart';

import '../controller/firestore_controller.dart';

class UserSearchScreen extends StatefulWidget {
  static const String routeName = '/userSearchScreen';
  final UserInformation user;
  final List<UserInformation> users;

  const UserSearchScreen({
    required this.user,
    required this.users,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UserSearchState();
  }
}

class _UserSearchState extends State<UserSearchScreen> {
  late _Controller con;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    con.users = widget.users;
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: const Text("User Search Screen"), actions: [
        Row(
          children: [
            Form(
              key: formKey,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Center(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Search Users',
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
            Text('There are ${widget.users.length} users'),
            for (UserInformation user in con.users)
              Column(
                children: [
                  ListTile(
                    tileColor: Colors.white,
                    leading: Icon(
                      Icons.account_circle,
                      size: 60,
                      color: Colors.blue[900],
                    ),
                    title: Text((user.username ?? 'No name') +
                        (user.username == widget.user.username
                            ? ' (You)'
                            : '')),
                    subtitle:
                        Text(user.user == null ? "No email found" : user.user!),
                    trailing: user.username != widget.user.username
                        ? !widget.user.friends
                                .contains('${user.username}|${user.user}')
                            ? IconButton(
                                onPressed: () => con.addFriend(user),
                                icon: const Icon(Icons.person_add),
                              )
                            : const Icon(Icons.done, color: Colors.green)
                        : null,
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
  _UserSearchState state;
  late List<UserInformation> users;
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
      users = state.widget.users;
    } else {
      users = [];
      for (var user in state.widget.users) {
        if (user.username == null ||
            user.username!.toLowerCase().contains(query!.toLowerCase()) ||
            (user.user != null &&
                user.user!.toLowerCase().contains(query!.toLowerCase()))) {
          users.add(user);
        }
      }
    }
    state.render(() {});
  }

  void addFriend(UserInformation user) async {
    try {
      Map<String, dynamic> update = {};
      state.widget.user.friends.add('${user.username}|${user.user}');
      update[DocKeyUserInfo.friends.name] = state.widget.user.friends;
      String id =
          await FirestoreController.getUserDocID(state.widget.user.user!);
      await FirestoreController.updateUserInfo(docID: id, update: update);

      showSnackBar(
        context: state.context,
        message: 'Friend added.',
      );
      state.render(() {});
    } catch (e) {
      Navigator.of(state.context).pop();
      showSnackBar(
        context: state.context,
        message: 'Friend add failed: $e',
      );
    }
  }
}
