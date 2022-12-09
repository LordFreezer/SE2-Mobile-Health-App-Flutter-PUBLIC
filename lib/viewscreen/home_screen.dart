import 'dart:convert';
// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project1/controller/auth_controller.dart';
import 'package:project1/model/CovidModel.dart';
import 'package:project1/model/changeCity_model.dart';
import 'package:project1/model/constants.dart';
import 'package:project1/model/user_info.dart';
import 'package:project1/viewscreen/bugreport_screen.dart';
import 'package:project1/viewscreen/logs_screen.dart';
import 'package:project1/viewscreen/profile_screen.dart';
import 'package:project1/viewscreen/user_search_screen.dart';
import 'package:project1/viewscreen/view/view_util.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'package:project1/viewscreen/weather_screen.dart';
import '../controller/firestore_controller.dart';
import '../model/activity_model.dart';
import 'admin_screen.dart';
import 'friend_screen.dart';
import '../model/doctor_model.dart';
import 'doctor_screen.dart';
import 'record_screen.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.user,
    required this.userInfo,
    required this.activityList,
    required this.covidData,
  }) : super(key: key);

  static const routeName = '/homeScreen';

  final User user;
  final UserInformation userInfo;
  final List<Activity> activityList;
  final covidData;

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late _Controller con;

  late List<Activity> activityList; // = widget.activityList;

  late Duration longestActivityDuration;
  late Activity longestActivity;
  bool initialized = false;
  final formKey = GlobalKey<FormState>();
  late ChangeCity screenModel;

  List<double> covidDeaths = [];

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    screenModel = ChangeCity();
    // Retrieves activity list from firebase
    con.getActivityList();
    con.populateDeaths();
    // Calculate longest activity
    //con.getLongestActivity();
  }

  void render(fn) {
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var date = DateFormat('dd-MM-yyyy');
    var time = DateFormat('kk:mm:a');

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.email}\'s Home'),
        actions: [
          IconButton(onPressed: con.navigateWeatherScreen, icon: const Icon(Icons.sunny))
        ],
      ),
      drawer: drawerView(),
      body: ListView(
        children: [
          TextButton(
            onPressed: ((() {
              con.getLongestActivity();
              render(() => {});
            })),
            child: const Text("Refresh"),
          ),
          (!initialized)
              ? const Text("No Activities found!")
              : ListView(
                  shrinkWrap: true,
                  children: [
                    Text("Activity: ${longestActivity.activity}"),
                    Text(
                        "Start: ${date.format(longestActivity.startDate!)} at ${time.format(longestActivity.startDate!)}"),
                    Text(
                        "End: ${date.format(longestActivity.endDate!)} at ${time.format(longestActivity.endDate!)}"),
                    Text(
                        "Duration: ${longestActivity.endDate!.difference(longestActivity.startDate!).inMinutes} minutes"),
                    longestActivity.tasks == null ||
                            longestActivity.tasks!.isEmpty
                        ? const Text("No data found")
                        : Container(
                            color: Colors.blueGrey[800],
                            height: 300,
                            child: LineChart(
                              painter: LineChartPainter(
                                lineChartContainer: LineChartTopContainer(
                                  chartData: ChartData(
                                    dataRows: [longestActivity.getTasks()],
                                    xUserLabels: con.getUserLabels(),
                                    dataRowsLegends: const ["Legend"],
                                    chartOptions: const ChartOptions(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Center(
                child: const Text(
              "Covid News",
              style: TextStyle(fontSize: 25),
            )),
          ),
          FutureBuilder<CovidModel>(
            future: con.recent(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                DateTime date = DateTime.parse(snapshot.data!.date.toString());
                return Text(
                    "On ${date.day}/${date.month} ${date.year}, there are a total of ${snapshot.data!.death} dead with ${snapshot.data!.hospitalized} inflicted left in hospitals around the United States. ");
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          (covidDeaths.isNotEmpty)
              ? Container(
                  color: Color.fromARGB(255, 0, 0, 0),
                  height: 300,
                  child: LineChart(
                    painter: LineChartPainter(
                      lineChartContainer: LineChartTopContainer(
                        chartData: ChartData(
                          dataRowsColors: const [Colors.red],
                          dataRows: [covidDeaths],
                          xUserLabels: con.getDeathLabels(),
                          dataRowsLegends: const ["Deaths"],
                          chartOptions: const ChartOptions(),
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: const Text(
                    "Tap 'Refresh' to see the number of deaths from last 30 days",
                    style: TextStyle(fontSize: 25),
                  ),
                ),
          TextButton(
              onPressed: (() {
                con.navigateBugScreen();
              }),
              child: const Text("Found Something Wrong With The App?"))
        ],
      ),
    );
  }

  Widget drawerView() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: Stack(
              children: [
                widget.userInfo.userPhotoURL != ''
                    ? CircleAvatar(
                        radius: 33.0,
                        backgroundImage:
                            NetworkImage(widget.userInfo.userPhotoURL!),
                        backgroundColor: Colors.transparent,
                      )
                    /*radius: 49.0,
                            child:*/ /*ClipRRect(
                              borderRadius: BorderRadius.circular(49.0),
                              child:*/ /*cachedNetworkImage(
                                  widget.userInfo.userPhotoURL),
                            )*/ //)
                    : const Icon(
                        Icons.person,
                        size: 60.0,
                      ),
                Positioned(
                  right: -15.0,
                  bottom: -15.0,
                  child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        // color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 15,
                        minHeight: 15,
                      ),
                      child: IconButton(
                          onPressed: con.navigateProfileScreen,
                          icon: const Icon(
                            Icons.published_with_changes_outlined,
                            color: Colors.white,
                          ))
                      // IconButton(
                      //   onPressed: null,
                      //   icon: Icon(Icons.published_with_changes),
                      // ),
                      ),
                ),
              ],
            ),
            accountName: widget.userInfo.username != ''
                ? Text(widget.userInfo.username!)
                : const Text('No Username'),
            accountEmail: Text(widget.user.email!),
          ),
          ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: con.navigateProfileScreen),
          ListTile(
            leading: const Icon(Icons.accessible_forward),
            title: const Text('Record'),
            onTap: con.navigateRecordScreen,
          ),
          ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Logs'),
              onTap: (() {
                con.navigateLogsScreen();
              })),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            onTap: con.navigateUserSearchScreen,
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_rounded),
            title: const Text('Friends'),
            onTap: con.navigateFriendScreen,
          ),
          // add settings portion
          ListTile(
            leading: const Icon(Icons.heart_broken),
            title: const Text("My Doctors"),
            onTap: con.navigateDoctorsScreen,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: con.signOut,
          ),
          widget.userInfo.adminFlag
              ? ListTile(
                  leading: const Icon(Icons.timer),
                  title: const Text("Usage Limits"),
                  onTap: con.navigateAdminScreen)
              : const ListTile(), // Leave this at the bottom
        ],
      ),
    );
  }
}

class _Controller {
  _HomeScreenState state;
  _Controller(this.state);
   String? location;
  int number =0;

  List<String> getUserLabels() {
    // Empty for now
    List<String> result = [];
    for (var a in state.longestActivity.getTasks()) {
      result.add("");
    }
    return result;
  }

  List<String> getDeathLabels() {
    // Empty for now
    List<String> result = [];
    for (var a in state.covidDeaths) {
      result.add("");
    }
    return result;
  }

  void getLongestActivity() {
    state.longestActivityDuration = state.activityList[0].endDate!
        .difference(state.activityList[0].startDate!);
    state.longestActivity = state.activityList[0];
    for (int i = 0; i < state.activityList.length; i++) {
      if (state.activityList[i].endDate!
              .difference(state.activityList[i].startDate!) >
          state.longestActivityDuration) {
        state.longestActivityDuration = state.activityList[i].endDate!
            .difference(state.activityList[i].startDate!);
        state.longestActivity = state.activityList[i];
      }
    }
  }

  void getActivityList() async {
    try {
      state.activityList = await FirestoreController.getActivityList(
          email: state.widget.user.email!);
      getLongestActivity();
      state.initialized = true;
      state.render(() => {});
    } catch (e) {
      state.activityList = [];
    }
  }

  Future<CovidModel> recent() async {
    List<CovidModel>? rec = await state.widget.covidData;
    return rec![0];
  }

  Future<void> signOut() async {
    try {
      await Auth.signOut();
    } catch (e) {
      if (Constant.devMode) {
        print('=========== sign out error: $e');
      }
      showSnackBar(context: state.context, message: 'Sign out error: $e');
    }
    Navigator.of(state.context).pop(); //close the drawer
    Navigator.of(state.context).pop(); //return to screen
  }

  void navigateDoctorsScreen() async {
    List<Doctor> doctorList = await FirestoreController.getDoctorList(
        email: state.widget.user.email!);

    await Navigator.pushNamed(state.context, DoctorScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.doctorList: doctorList
        });
  }

  void navigateProfileScreen() async {
    await Navigator.pushNamed(state.context, ProfileScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.userInfo: state.widget.userInfo
        });
    state.setState(() {});
  }

  void navigateRecordScreen() async {
    await Navigator.pushNamed(state.context, RecordScreen.routeName,
        arguments: {
          ArgKey.user: state.widget.user,
          ArgKey.userInfo: state.widget.userInfo,
          ArgKey.activityList: state.activityList,
        });
    state.setState(() {});
  }

  void navigateUserSearchScreen() async {
    try {
      var users = await FirestoreController.getAllUserInfo();
      var user = await FirestoreController.getUserInfo(
          email: state.widget.user.email!);
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(
        state.context,
        UserSearchScreen.routeName,
        arguments: {
          ArgKey.user: user,
          ArgKey.users: users,
        },
      );
    } catch (e) {
      showSnackBar(context: state.context, message: "Couldn't get users");
      return;
    }
  }

  void navigateAdminScreen() async {
    try {
      var users = await FirestoreController.getAllUserInfo();
      var user = await FirestoreController.getUserInfo(
          email: state.widget.user.email!);
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(
        state.context,
        AdminScreen.routeName,
        arguments: {
          ArgKey.user: user,
          ArgKey.users: users,
        },
      );
    } catch (e) {
      showSnackBar(context: state.context, message: "Couldn't get users");
      return;
    }
  }

  void populateDeaths() {
    state.widget.covidData.then((data) {
      for (int i = 0; i < 30; i++) {
        int deaths = data[i].death;

        state.covidDeaths.add(deaths.toDouble());
      }
      print(state.covidDeaths);
    });
  }

  void navigateFriendScreen() async {
    try {
      var user = await FirestoreController.getUserInfo(
          email: state.widget.user.email!);
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(
        state.context,
        FriendScreen.routeName,
        arguments: {
          ArgKey.user: user,
        },
      );
    } catch (e) {
      showSnackBar(context: state.context, message: "Couldn't get users");
      return;
    }
  }

  void navigateBugScreen() async {
    try {
      var user = await FirestoreController.getUserInfo(
          email: state.widget.user.email!);
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(
        state.context,
        BugScreen.routeName,
        arguments: {
          ArgKey.user: user,
        },
      );
    } catch (e) {
      showSnackBar(context: state.context, message: "Couldn't get users");
      return;
    }
  }

  void navigateLogsScreen() async {
    
  List<String> logsList = await FirestoreController.getLogsList(email: state.widget.user.email!);
  List<bool> completed = await FirestoreController.getCompleted(email: state.widget.user.email!);
    // ignore: use_build_context_synchronously
    await Navigator.pushNamed(state.context, LogsScreen.routeName,
    arguments: {
      ArgKey.user: state.widget.user,
      ArgKey.logsList: logsList,
      ArgKey.completed: completed,
    });
  }

  void navigateWeatherScreen() async {
    createForm();
    await Future.delayed(Duration(seconds: 15),(){
      if(number==1){
    Navigator.pushNamed(state.context, WeatherScreen.routeName,
    arguments: {
      ArgKey.city: location,//city variable
    });
    }
    });
  }

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
                              initialValue: "Oklahoma",
                              minLines: 1,
                              validator: state.screenModel.validateCity,
                              onSaved: state.screenModel.saveCity,
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

    location = state.screenModel.city!;
    // state.formKey.currentState!.reset(); //this is causing a problem, need to reset form field
    state.setState(() {});
    Navigator.of(state.context).pop();
    number = 1;
    print(number);
    print(location);
  }
}
