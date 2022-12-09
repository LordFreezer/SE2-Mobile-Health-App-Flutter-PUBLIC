import 'package:flutter/material.dart';
import 'package:project1/model/user_info.dart';
import 'package:intl/intl.dart';
import '../model/activity_model.dart';
import '../model/constants.dart';
import 'activity_screen.dart';

class FriendCompareScreen extends StatefulWidget {
  final UserInformation user;
  final UserInformation friend;
  final List<Activity> userActivities;
  final List<Activity> friendActivities;
  static const String routeName = '/friendCompareScreen';
  const FriendCompareScreen({
    required this.friend,
    required this.user,
    required this.userActivities,
    required this.friendActivities,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FriendCompareState();
  }
}

class _FriendCompareState extends State<FriendCompareScreen> {
  late _Controller con;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friend Compare"),
      ),
      backgroundColor: Colors.blue[700],
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 30,
                child: con.getCompareColumn(
                    widget.friend, widget.friendActivities),
              ),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Expanded(
                flex: 30,
                child: con.getCompareColumn(widget.user, widget.userActivities),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _FriendCompareState state;
  _Controller(this.state);
  var date = DateFormat('dd-MM-yyyy');

  Widget getCompareColumn(UserInformation user, List<Activity> activities) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text(
            "${user.username!}\n",
            style: Theme.of(state.context).textTheme.headline5,
          ),
          const Text("Total Activities:"),
          Text(
            activities.length.toString(),
            style: Theme.of(state.context).textTheme.headline3,
          ),
          const Text("\nTotal Recording Time:"),
          Text(
            totalMinutes(activities).toString(),
            style: Theme.of(state.context).textTheme.headline3,
          ),
          const Text("Minutes\n"),
          for (Activity a in activities)
            Column(
              children: [
                Container(color: Colors.black, height: 3),
                ListTile(
                  leading: Icon(
                    Icons.accessible_forward,
                    size: 30,
                    color: Colors.blue[900],
                  ),
                  title: Text(a.activity!),
                  subtitle: Text(date.format(a.startDate!)),
                  onTap: () {
                    navigateActivityScreen(activities, a);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  int totalMinutes(List<Activity> activities) {
    int total = 0;
    for (Activity a in activities) {
      total += a.endDate!.difference(a.startDate!).inMinutes;
    }
    return total;
  }

  void navigateActivityScreen(
      List<Activity> activityList, Activity activity) async {
    await Navigator.pushNamed(state.context, ActivityScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.activityList: activityList,
          ArgKey.activity: activity,
        });
    state.render(() {});
  }
}
