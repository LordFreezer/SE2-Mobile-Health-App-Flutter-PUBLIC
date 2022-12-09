import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:project1/controller/firestore_controller.dart';
import 'package:flutter/material.dart';
import 'package:project1/model/activity_model.dart';
import 'package:project1/viewscreen/activity_screen.dart';
import 'package:project1/viewscreen/view/view_util.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../model/constants.dart';
import '../model/user_info.dart';

class RecordScreen extends StatefulWidget {
  static const routeName = '/recordScreen';
  final User user;
  final UserInformation userInfo;
  final List<Activity> activityList;
  const RecordScreen({
    required this.user,
    required this.userInfo,
    required this.activityList,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RecordState();
  }
}

class _RecordState extends State<RecordScreen> {
  // Variables for accelerometer data
  double x = 150, y = 200;
  double move = 0, count = 0;
  List<double> moves = [];
  int i = 0, size = 50;

  // Variables for DateTime picker
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  //String _startdate = DateFormat('dd/MM/yyyy').format(DateTime.now().subtract(const Duration(days: 4)));
  //String _enddate = DateFormat('dd/MM/yyyy').format(DateTime.now().add(const Duration(days: 3)));
  DateTime _startdate = DateTime.now().subtract(const Duration(days: 4));
  DateTime _enddate = DateTime.now().add(const Duration(days: 3));

  late _Controller con;
  final formKey = GlobalKey<FormState>();
  late bool _isRecording;
  late StreamSubscription subscription;
  FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();
  late int timeLeft;

  List<Activity> activityList = [];
  List<Activity> filteredList = [];
  Activity activity = Activity();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => render(() {}));
    activityList = widget.activityList;
    _isRecording = false;

    con = _Controller(this);
    activity.activity = '';
    activity.tasks = [];
    activity.startDate = DateTime.now();
    notification.initialize(const InitializationSettings(
        android: AndroidInitializationSettings("app_icon")));
    timeLeft = con.minutesLeft();
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Record Screen"),
        actions: [
          IconButton(
            icon: Icon(_isRecording ? Icons.stop : Icons.play_arrow),
            onPressed: (() {
              timeLeft = con.minutesLeft();
              if (!_isRecording && formKey.currentState!.validate()) {
                if (timeLeft > 0) {
                  formKey.currentState!.save();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recording Activity')),
                  );
                  activity.tasks = [];
                  activity.startDate = DateTime.now();
                  con.toggleRecord();
                  con.delayRender();
                } else {
                  showSnackBar(
                      context: context,
                      message:
                          "You cannot record any more. Please contact an admin.");
                }
              } else if (_isRecording) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Activity Saved!')),
                );
                activity.endDate = DateTime.now();

                con.createActivity();
                con.getActivityList();
                con.toggleRecord();
                con.delayRender();
              }
            }),
          ),
        ],
      ),
      body: Stack(
        children: [
          _isRecording
              ? StreamBuilder<Object>(
                  stream: SensorsPlatform.instance.userAccelerometerEvents,
                  builder: (context, snapshot) {
                    subscription =
                        userAccelerometerEvents.listen((event) async {
                      x += event.x * 10;
                      y += event.y * 10;

                      print(event);
                      print(i);

                      moves.add(sqrt((pow(event.x, 2) +
                              pow(event.y, 2) +
                              pow(event.z, 2)))
                          .toDouble());

                      i += 1;

                      if (i >= size) {
                        i = 0;
                        move = 0;
                        for (var m in moves) {
                          move += m;
                        }

                        move = move / size;
                        activity.tasks!.add(move);
                        moves.clear();
                        if (DateTime.now()
                                .difference(activity.startDate!)
                                .inMinutes >
                            timeLeft) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Activity Saved!')),
                          );
                          activity.endDate = DateTime.now();

                          con.createActivity();
                          con.getActivityList();
                          con.toggleRecord();
                          con.delayRender();
                        }
                      }

                      con.dispose();
                    });

                    return ListView(
                      children: [
                        Text("Average Movement: $move"),
                        activity.tasks == null || activity.tasks!.isEmpty
                            ? const Text("Recording...")
                            : Container(
                                color: Colors.blueGrey[800],
                                height: 300,
                                child: LineChart(
                                  painter: LineChartPainter(
                                    lineChartContainer: LineChartTopContainer(
                                      chartData: ChartData(
                                        dataRows: [activity.getTasks()],
                                        xUserLabels: con.getUserLabels(),
                                        dataRowsLegends: const ["Legend"],
                                        chartOptions: const ChartOptions(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    );
                  })
              : Stack(
                  children: [
                    const Text("Activity Name"),
                    Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                activity.activity = 'Unknown Activity';
                                return 'Enter Activity Name';
                              } else {
                                activity.activity = val;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 50),
                          (activityList.isNotEmpty && filteredList.isEmpty)
                              ? Expanded(
                                  child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: activityList.length,
                                  itemBuilder: (context, index) {
                                    var date = DateFormat('dd-MM-yyyy');
                                    var time = DateFormat('kk:mm:a');
                                    return Center(
                                      child: TextButton(
                                        onPressed: () {
                                          con.navigateActivityScreen(
                                              activityList[index]);
                                        },
                                        child: Text(
                                            "${activityList[index].activity!} on ${date.format(activityList[index].startDate!)} at ${time.format(activityList[index].startDate!)}"),
                                      ),
                                    );
                                  },
                                ))
                              : (filteredList.isNotEmpty)
                                  ? Expanded(
                                      child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: filteredList.length,
                                      itemBuilder: (context, index) {
                                        var date = DateFormat('dd-MM-yyyy');
                                        var time = DateFormat('kk:mm:a');
                                        return Center(
                                          child: TextButton(
                                            onPressed: () {
                                              con.navigateActivityScreen(
                                                  filteredList[index]);
                                            },
                                            child: Text(
                                                "${filteredList[index].activity!} on ${date.format(filteredList[index].startDate!)} at ${time.format(filteredList[index].startDate!)}"),
                                          ),
                                        );
                                      },
                                    ))
                                  : const Text("No Activities Yet!"),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.lightBlue[300],
              ),
              child: const Text(
                'Filter Dates',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
            ),
            SfDateRangePicker(
              onSelectionChanged: con._onSelectionChanged,
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: PickerDateRange(
                  DateTime.now().subtract(const Duration(days: 4)),
                  DateTime.now().add(const Duration(days: 3))),
            ),
            TextButton(
              onPressed: con.filterDates,
              child: const Text("Find"),
            ),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  _RecordState state;
  _Controller(this.state);
  Activity action = Activity();

  void filterDates() {
    //print("SELECTED START: ${state._startdate}");
    //print("SELECTED END: ${state._enddate}");
    state.filteredList.clear();
    for (int i = 0; i < state.activityList.length; i++) {
      //String sd = DateFormat('dd/MM/yyyy').format(state.activityList[i].startDate!);
      //String ed = DateFormat('dd/MM/yyyy').format(state.activityList[i].endDate!);
      DateTime sd = state.activityList[i].startDate!;
      DateTime ed = state.activityList[i].endDate!;
      if (sd.compareTo(state._startdate) >= 0 &&
          ed.compareTo(state._enddate) <= 0) {
        //print("ACTIVITY $i START: $sd");
        //print("ACTIVITY $i END: $ed");
        state.filteredList.add(state.activityList[i]);
      }
    }
    state.render(() => {});
    print("---------------------");
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    /// The argument value will return the changed date as [DateTime] when the
    /// widget [SfDateRangeSelectionMode] set as single.
    ///
    /// The argument value will return the changed dates as [List<DateTime>]
    /// when the widget [SfDateRangeSelectionMode] set as multiple.
    ///
    /// The argument value will return the changed range as [PickerDateRange]
    /// when the widget [SfDateRangeSelectionMode] set as range.
    ///
    /// The argument value will return the changed ranges as
    /// [List<PickerDateRange] when the widget [SfDateRangeSelectionMode] set as
    /// multi range.
    state.setState(() {
      state._startdate = args.value.startDate;
      state._enddate = args.value.endDate ?? args.value.startDate;
      //state._startdate = DateFormat('dd/MM/yyyy').format(args.value.startDate);
      //state._enddate = DateFormat('dd/MM/yyyy')
      //   .format(args.value.endDate ?? args.value.startDate);
      if (args.value is PickerDateRange) {
        state._range =
            '${DateFormat('dd/MM/yyyy').format(args.value.startDate)} -'
            // ignore: lines_longer_than_80_chars
            ' ${DateFormat('dd/MM/yyyy').format(args.value.endDate ?? args.value.startDate)}';
      } else if (args.value is DateTime) {
        state._selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        state._dateCount = args.value.length.toString();
      } else {
        state._rangeCount = args.value.length.toString();
      }
    });
  }

  void dispose() {
    state.subscription.cancel();
  }

  void toggleRecord() {
    if (!state._isRecording) {
      state._isRecording = true;
      state.notification.show(
        1,
        "Recroding!",
        "You're recording your physical activity",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            "record",
            "record",
            playSound: false,
            enableVibration: false,
            usesChronometer: true,
          ),
        ),
      );
    } else {
      state._isRecording = false;
      state.notification.cancelAll();
    }
  }

  void getActivityList() async {
    try {
      state.activityList = await FirestoreController.getActivityList(
          email: state.widget.user.email!);
    } catch (e) {
      state.activityList = [];
    }
  }

  int minutesLeft() {
    if (state.widget.userInfo.maxRecord == null ||
        state.widget.userInfo.maxRecord == 0) {
      return 864; //24 Hours
    } else {
      int total = 0;
      for (Activity a in state.widget.activityList) {
        total += a.endDate!.difference(a.startDate!).inMinutes;
      }
      return state.widget.userInfo.maxRecord! - total;
    }
  }

  List<String> getUserLabels() {
    // Empty for now
    List<String> result = [];
    for (var a in state.activity.getTasks()) {
      result.add("");
    }
    return result;
  }

  void delayRender() async {
    await Future.delayed(const Duration(seconds: 1));
    state.render(() {});
  }

  void sleepBlock() {
    state.subscription.pause();
    sleep(const Duration(milliseconds: 1000));
    state.subscription.resume();
  }

  Future<void> createActivity() async {
    /* FormState? currentState = state.formKey.currentState;
    if (currentState == null) {
      print("NULL: SOMETHING IS BROKEN");
      return;
    }
    if (!currentState.validate()) return;
    currentState.save();*/

    state.activity.email = state.widget.user.email;
    state.activity.docId = '';

    String docId =
        await FirestoreController.addActivity(activity: state.activity);
    state.activity.docId = docId;

    await FirestoreController.replaceDocIDActivity(
        docID: state.activity.docId!, documentID: state.activity.docId!);
    state.widget.activityList.add(state.activity);
  }

  void navigateActivityScreen(Activity activity) async {
    await Navigator.pushNamed(state.context, ActivityScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.activityList: state.widget.activityList,
          ArgKey.activity: activity,
        });
    state.render(() {});
  }
}
