class Activity {
  DateTime? startDate;
  DateTime? endDate;
  String? activity;
  String? docId;
  List<dynamic>? tasks;
  String? email;

  static const START_DATE = 'startDate';
  static const END_DATE = 'endDate';
  static const ACTIVITY = 'activity';
  static const TASKS = 'tasks';
  static const EMAIL = 'email';

  Activity({
    this.startDate,
    this.endDate,
    this.activity,
    this.tasks,
    this.email,
    this.docId,
  }) {}

  Map<String, dynamic> serialize() {
    return {
      START_DATE: startDate,
      END_DATE: endDate,
      ACTIVITY: activity,
      TASKS: tasks,
      EMAIL: email,
    };
  }

  static Activity deserialize(
    Map<String, dynamic> doc,
    String docId,
  ) {
    return Activity(
      startDate: doc[START_DATE] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[START_DATE].millisecondsSinceEpoch),
      endDate: doc[END_DATE] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[END_DATE].millisecondsSinceEpoch),
      activity: doc[ACTIVITY],
      tasks: doc[TASKS],
      email: doc[EMAIL],
      docId: docId,
    );
  }

  List<double> getTasks() {
    try {
      List<double> result = [];
      for (var t in tasks!) {
        result.add(double.parse(t.toString()));
      }
      return result;
    } catch (e) {
      return [];
    }
  }
}
