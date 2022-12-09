import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project1/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:project1/model/activity_model.dart';
import 'package:project1/viewscreen/home_screen.dart';
import 'package:project1/viewscreen/record_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:http/http.dart' as http;
import '../model/CovidModel.dart';
import '../model/constants.dart';
import '../model/user_info.dart';

class ActivityScreen extends StatefulWidget {
  static const routeName = '/activityScreen';
  final User user;
  final Activity activity;
  final List<Activity> activityList;

  const ActivityScreen(
      {required this.user,
      required this.activity,
      required this.activityList,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ActivityScreen();
  }
}

class _ActivityScreen extends State<ActivityScreen> {
  late _Controller con;
  final formKey = GlobalKey<FormState>();
  List<Activity> activityList = [];
  late UserInformation userInfo;
  @override
  void initState() {
    super.initState();

    con = _Controller(this);
    con.getUserInfo();
  }

  void render(fn) => setState(fn);

  //Future pause(Duration d) => Future.delayed(d);

  @override
  Widget build(BuildContext context) {
    var date = new DateFormat('dd-MM-yyyy');
    var time = new DateFormat('kk:mm:a');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Screen"),
        actions: [],
      ),
      body: ListView(
        children: [
          Text("Activity: ${widget.activity.activity}"),
          Text(
              "Start: ${date.format(widget.activity.startDate!)} at ${time.format(widget.activity.startDate!)}"),
          Text(
              "End: ${date.format(widget.activity.endDate!)} at ${time.format(widget.activity.endDate!)}"),
          Text(
              "Duration: ${widget.activity.endDate!.difference(widget.activity.startDate!).inMinutes} minutes"),
          widget.activity.tasks == null || widget.activity.tasks!.isEmpty
              ? const Text("No data found")
              : Container(
                  color: Colors.blueGrey[800],
                  height: 300,
                  child: LineChart(
                    painter: LineChartPainter(
                      lineChartContainer: LineChartTopContainer(
                        chartData: ChartData(
                          dataRows: [widget.activity.getTasks()],
                          xUserLabels: con.getUserLabels(),
                          dataRowsLegends: const ["Legend"],
                          chartOptions: const ChartOptions(),
                        ),
                      ),
                    ),
                  ),
                ),
          TextButton(
            onPressed: (() async => {
                  con.deleteActivity(),
                  con.getActivityList(),
                  await Future.delayed(const Duration(seconds: 2)),
                  con.navigateRecordScreen(),
                }),
            child: const Text("Delete Activity"),
          )
        ],
      ),
    );
  }
}

class _Controller {
  _ActivityScreen state;
  _Controller(this.state);

  void deleteActivity() async {
    await FirestoreController.deleteActivity(state.widget.activity);
    state.widget.activityList.remove(state.widget.activity);
  }

  void getActivityList() async {
    try {
      state.activityList = await FirestoreController.getActivityList(
          email: state.widget.user.email!);
    } catch (e) {
      state.activityList = [];
    }
  }

  void getUserInfo() async {
    state.userInfo =
        await FirestoreController.getUserInfo(email: state.widget.user.email!);
  }

  List<String> getUserLabels() {
    // Empty for now
    List<String> result = [];
    for (var a in state.widget.activity.getTasks()) {
      result.add("");
    }
    return result;
  }

  Future<List<CovidModel>> getBlob() async {
    final url = Uri.parse('https://api.covidtracking.com/v1/us/daily.json');
    final response = await http.get(url);
    // access single field: CovidModel.fromJson(jsonDecode(response.body)).date
    print(response.body);
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

  void navigateRecordScreen() async {
    /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordScreen(
                          user: widget.user, activityList: activityList),
                    ),
                  ).then((value) {
                    con.getActivityList(widget.user.email!);
                    //await Future.delayed(const Duration(seconds: 2));
                    render(() {});
                  })*/
    // Navigator.of(context).pop(),
    /*Navigator.pushNamed(context, RecordScreen.routeName,
                      arguments: {
                        ArgKey.user: widget.user,
                        ArgKey.activityList: activityList,
                      })*/

    var blob = getBlob();

    // pops activity_screen back to record_screen
    Navigator.of(state.context).pop();
    // pops record_screen back to home_screen
    Navigator.of(state.context).pop();

    Navigator.pushNamed(state.context, HomeScreen.routeName, arguments: {
      ArgKey.user: state.widget.user,
      ArgKey.userInfo: state.userInfo,
      ArgKey.activityList: state.activityList,
      ArgKey.covidData: blob
      //ArgKey.covidData: !!!!ADD ARGUMENT!!!
    });
    Navigator.pushNamed(state.context, RecordScreen.routeName, arguments: {
      ArgKey.user: state.widget.user,
      ArgKey.userInfo: state.userInfo,
      ArgKey.activityList: state.activityList,
    });
  }
}
