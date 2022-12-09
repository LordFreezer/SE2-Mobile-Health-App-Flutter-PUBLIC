enum DocKeyLogs{
  email,
  logs,
  completed,
}

class Logs{
  String? email;
  String? logs;
  //maybe add a time or int the counts until it needs to be reset or updated such as daily
  bool? completed;

  Logs({
    this.email = '',
    this.logs = '',
    this.completed = false,
  });

  Map<String, dynamic> toFirestoreDocLogs() {
    return {
      DocKeyLogs.email.name: email,
      DocKeyLogs.logs.name: logs,
      DocKeyLogs.completed.name: completed,
      // DocKeyUserInfo.docID.name: docID,
    };
  }

  static String? fromFirestoreDocLogsList({
    required Map<String, dynamic> doc,
    required String docIDs,
  }){
      return doc[DocKeyLogs.logs.name] ??= 'N/A';
  }

  static bool? fromFirestoreDocCompleted({
    required Map<String, dynamic> doc,
    required String docIDs,
  }){
      return doc[DocKeyLogs.completed.name] ??= false;
  }

  void saveLogs(String? value){
    logs = value;
  }

  static String fromFirestoreDocUpdateCompleted({
    required Map<String, dynamic> doc,
    required String docID,
  }){
        return docID;
  }

}