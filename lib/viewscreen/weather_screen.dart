import 'package:flutter/material.dart';
import 'package:project1/controller/weather_api_client.dart';
import 'package:project1/model/changeCity_model.dart';
import 'package:project1/model/constants.dart';
import 'package:project1/model/weather_model.dart';
import 'package:project1/viewscreen/view/view_util.dart';

TextStyle infoStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0);

class WeatherScreen extends StatefulWidget {
  static const routeName = '/weatherScreen';

  const WeatherScreen({Key? key, required this.location}) : super(key: key);

  final String location;

  @override
  State<StatefulWidget> createState() {
    return _WeatherScreenState();
  }
}

class _WeatherScreenState extends State<WeatherScreen> {
  late _Controller con;
  WeatherApiClient client = WeatherApiClient();
  Weather? data;
  String? location ;//"Oklahoma";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    print(location);
    location = widget.location;
    print(location);
  }

  Future<void> getData() async {
    data = await client.getCurrentWeather(widget.location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50.0,
        title: Text(
          "Weather", //will replace with cities name
          style: TextStyle(color: Colors.black, fontSize: 25.0),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                con.currentWeather(Icons.wb_sunny_rounded, "${data!.temp}",
                    "${data!.cityName}"),
                SizedBox(
                  height: 60.0,
                ),
                Text(
                  "Other Information",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Divider(),
                SizedBox(
                  height: 20.0,
                ),
                con.AdditionalInformation(
                    "${data!.wind}",
                    "${data!.humidity}",
                    "${data!.pressure}",
                    "${data!.feels_like}",
                    "${data!.min_temp}",
                    "${data!.max_temp}"),

          //       Divider(),
          //       SingleChildScrollView(
          //         child: Padding(
          //           padding: const EdgeInsets.all(16.0),
          //           child: Form(
          //           key: formKey,
          //   child: Column(
          //     children: [
          //           TextFormField(
          //             decoration: const InputDecoration(
          //               hintText: 'Enter City',
          //             ),
          //             autocorrect: false,
          //             validator: screenModel.validateCity,
          //             onSaved: screenModel.saveEmail,
          //           ),
          //           ElevatedButton(
          //             onPressed: con.changeCity,
          //             child: Text(
          //               'Change City',
          //               style: Theme.of(context).textTheme.button,
          //             ),
          //           ),
          //     ]
          //   ),
          // ),
          //         ),
          //       ),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Container();
        },
      ),
    );
  }
}

class _Controller {
  _WeatherScreenState state;
  _Controller(this.state);

  Widget currentWeather(IconData icon, String temp, String location) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.orange,
            size: 64.0,
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "$temp",
            style: TextStyle(
              fontSize: 46.0,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "$location",
            style: TextStyle(
              fontSize: 18.0,
              color: Color(0xFF5a5a5a),
            ),
          ),
        ],
      ),
    );
  }

  Widget AdditionalInformation(String wind, String humidity, String pressure,
      String feels_like, String min_temp, String max_temp) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Min Temp",
                    style: infoStyle,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Wind",
                    style: infoStyle,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Pressure",
                    style: infoStyle,
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$min_temp",
                    style: infoStyle,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "$wind",
                    style: infoStyle,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "$pressure",
                    style: infoStyle,
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Max Temp",
                    style: infoStyle,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Humidity",
                    style: infoStyle,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Feels Like",
                    style: infoStyle,
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$max_temp",
                    style: infoStyle,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "$humidity",
                    style: infoStyle,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "$feels_like",
                    style: infoStyle,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Future<void> changeCity() async {
  //   FormState? currentState = state.formKey.currentState;
  //   if (currentState == null || !currentState.validate()) return;
  //   currentState.save();

  //   try {
  //     // state.location=state.screenModel.city!;
  //     state.location = state.screenModel.city!;
  //     print(state.location);
  //     state.setState(() {
        
  //     });
  //   } catch (e) {
  //     if(Constant.devMode) print('======== Failed to create: $e');
  //     showSnackBar(context: state.context, message: 'Failed to Create: $e', seconds: 5);
  //   }
  // }
}
