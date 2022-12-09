import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:project1/model/constants.dart';
import 'package:project1/viewscreen/activity_screen.dart';
import 'package:project1/viewscreen/bugreport_screen.dart';
import 'package:project1/viewscreen/createaccount_screen.dart';
import 'package:project1/viewscreen/doctor_screen.dart';
import 'package:project1/viewscreen/email_screen.dart';
import 'package:project1/viewscreen/error_screen.dart';
import 'package:project1/viewscreen/friend_screen.dart';
import 'package:project1/viewscreen/home_screen.dart';
import 'package:project1/viewscreen/logs_screen.dart';
import 'package:project1/viewscreen/passwordreset_screen.dart';
import 'package:project1/viewscreen/profile_screen.dart';
import 'package:project1/viewscreen/signin_screen.dart';
import 'package:project1/viewscreen/startdispatcher.dart';
import 'package:project1/viewscreen/user_search_screen.dart';
import 'package:project1/viewscreen/weather_screen.dart';
import 'firebase_options.dart';
import 'model/CovidModel.dart';
import 'viewscreen/admin_screen.dart';
import 'viewscreen/friend_compare_screen.dart';
import 'viewscreen/limit_screen.dart';
import 'viewscreen/record_screen.dart';

void main() async {
  //runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HealthApp());
}

class HealthApp extends StatelessWidget {
  const HealthApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName: (context) => const SignInScreen(),
        CreateAccountScreen.routeName: (context) => const CreateAccountScreen(),
        PasswordResetScreen.routeName: (context) => const PasswordResetScreen(),
        HomeScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;

          if (args == null) {
            return const ErrorScreen('args is null for HomeScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var userInfo = argument[ArgKey.userInfo];
            var activityList = argument[ArgKey.activityList];
            var covidData =
                argument[ArgKey.covidData] as Future<List<CovidModel>>;
            return HomeScreen(
              user: user,
              userInfo: userInfo,
              activityList: activityList,
              covidData: covidData,
            );
          }
        },
        ProfileScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for ProfileScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var userInfo = argument[ArgKey.userInfo];
            return ProfileScreen(
              user: user,
              info: userInfo,
            );
          }
        },
        RecordScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for RecordScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var userInfo = argument[ArgKey.userInfo];
            var activityList = argument[ArgKey.activityList];

            return RecordScreen(
              user: user,
              userInfo: userInfo,
              activityList: activityList,
            );
          }
        },
        ActivityScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for Activity screen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var activity = argument[ArgKey.activity];
            var activityList = argument[ArgKey.activityList];

            return ActivityScreen(
              user: user,
              activity: activity,
              activityList: activityList,
            );
          }
        },
        UserSearchScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for UserSearchScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var users = argument[ArgKey.users];
            return UserSearchScreen(user: user, users: users);
          }
        },
        FriendScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for FriendScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            return FriendScreen(user: user);
          }
        },
        FriendCompareScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for FriendScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var friend = argument[ArgKey.friend];
            var userActivities = argument[ArgKey.activityList];
            var friendActivities = argument[ArgKey.friendActivityList];
            return FriendCompareScreen(
              user: user,
              friend: friend,
              userActivities: userActivities,
              friendActivities: friendActivities,
            );
          }
        },
        DoctorScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for Activity screen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var doctorList = argument[ArgKey.doctorList];

            return DoctorScreen(
              user: user,
              doctorList: doctorList,
            );
          }
        },
        EmailScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for Activity screen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var doctor = argument[ArgKey.doctor];

            return EmailScreen(
              user: user,
              doctor: doctor,
            );
          }
        },
        BugScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for Activity screen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];

            return BugScreen(
              user: user,
            );
          }
        },
        AdminScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for AdminScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var users = argument[ArgKey.users];
            return AdminScreen(user: user, users: users);
          }
        },
        LimitScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for LimitScreen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            return LimitScreen(user: user);
          }
        },
        LogsScreen.routeName: (context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for Activity screen');
          } else {
            var argument = args as Map;
            var user = argument[ArgKey.user];
            var logsList = argument[ArgKey.logsList];
            var completed = argument[ArgKey.completed];
            return LogsScreen(
              user: user,
              logsList: logsList,
              completed: completed,
            );
          }
        },
        WeatherScreen.routeName:(context) {
          Object? args = ModalRoute.of(context)?.settings.arguments;
          if (args == null) {
            return const ErrorScreen('args is null for Activity screen');
          } else {
            var argument = args as Map;
            var city = argument[ArgKey.city];
            return WeatherScreen(
              location: city,
            );
          }
        },
      },
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
