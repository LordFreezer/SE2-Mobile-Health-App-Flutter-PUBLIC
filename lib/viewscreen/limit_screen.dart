import 'package:flutter/material.dart';
import 'package:project1/model/user_info.dart';
import 'package:project1/viewscreen/view/view_util.dart';

import '../controller/firestore_controller.dart';

class LimitScreen extends StatefulWidget {
  static const String routeName = "/limitScreen";
  final UserInformation user;

  const LimitScreen({
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LimitState();
  }
}

class _LimitState extends State<LimitScreen> {
  late _Controller con;

  @override
  void initState() {
    con = _Controller(this);
    super.initState();
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Limit usage"),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Text("Set usage limits for",
                style: Theme.of(context).textTheme.headline6),
            Text(widget.user.username.toString(),
                style: Theme.of(context).textTheme.headline4),
            con.getCounter(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: con.save,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  _LimitState state;
  int hours = 0, minutes = 0;

  _Controller(this.state);

  Widget getCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_drop_up),
              iconSize: 50,
              onPressed: incrementHours,
            ),
            Text(hours.toString(),
                style: Theme.of(state.context).textTheme.headline2),
            const Text("Hours"),
            IconButton(
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 50,
              onPressed: decrementHours,
            ),
          ],
        ),
        const SizedBox(width: 20),
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_drop_up),
              iconSize: 50,
              onPressed: incrementMinutes,
            ),
            Text(minutes.toString(),
                style: Theme.of(state.context).textTheme.headline2),
            const Text("Minutes"),
            IconButton(
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 50,
              onPressed: decrementMinutes,
            ),
          ],
        ),
      ],
    );
  }

  void incrementHours() {
    state.render(() {
      if (hours == 23) {
        hours = 0;
      } else {
        hours++;
      }
    });
  }

  void decrementHours() {
    state.render(() {
      if (hours == 0) {
        hours = 23;
      } else {
        hours--;
      }
    });
  }

  void incrementMinutes() {
    state.render(() {
      if (minutes == 59) {
        minutes = 0;
      } else {
        minutes++;
      }
    });
  }

  void decrementMinutes() {
    state.render(() {
      if (minutes == 0) {
        minutes = 59;
      } else {
        minutes--;
      }
    });
  }

  void save() async {
    try {
      Map<String, dynamic> update = {};
      int time = minutes + hours * 60;
      update[DocKeyUserInfo.maxRecord.name] = time;
      await FirestoreController.updateUserInfo(
          docID: state.widget.user.docID!, update: update);
      state.widget.user.maxRecord = time;
      showSnackBar(context: state.context, message: "Limit Saved.");
    } catch (e) {
      showSnackBar(context: state.context, message: "Could not save changes");
    }
  }
}
