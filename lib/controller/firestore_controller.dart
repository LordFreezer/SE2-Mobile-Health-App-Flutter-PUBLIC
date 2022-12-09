import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project1/model/constants.dart';
import 'package:project1/model/doctor_model.dart';
import 'package:project1/model/user_info.dart';
import 'package:project1/model/logs_model.dart';


import '../model/activity_model.dart';

class FirestoreController {
  static Future<String> addActivity({
    required Activity activity,
  }) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Constant.activityCollection)
        .add(activity.serialize());
    return ref.id;
  }

  static Future<void> deleteActivity(Activity activity) async {
    await FirebaseFirestore.instance
        .collection(Constant.activityCollection)
        .doc(activity.docId)
        .delete();
  }

  static Future<List<Activity>> getActivityList({required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.activityCollection)
        .where(Activity.EMAIL, isEqualTo: email)
        .orderBy(Activity.START_DATE, descending: true)
        .get();

    var result = <Activity>[];
    for (var doc in querySnapshot.docs) {
      var document = doc.data() as Map<String, dynamic>;

      var a = Activity.deserialize(document, doc.id);
      result.add(a);
    }
    return result;
  }

  static Future<List<Doctor>> getDoctorList({required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.doctorCollection)
        .where(Doctor.USER_EMAILS, arrayContains: email)
        .orderBy(Doctor.NAME, descending: true)
        .get();

    var result = <Doctor>[];
    for (var doc in querySnapshot.docs) {
      var document = doc.data() as Map<String, dynamic>;

      var a = Doctor.deserialize(document, doc.id);
      result.add(a);
    }
    return result;
  }

  //allows for access to the same document in firebase for later access to update
  static Future<void> replaceDocIDActivity({
    required String docID,
    required String documentID,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.activityCollection)
        .doc(docID)
        .update({'docID': documentID});
  }

  static Future<String> addUserInfo({
    required UserInformation userInfo,
  }) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Constant.userInfoCollection)
        .add(userInfo.toFirestoreDocUserInfo());
    return ref.id;
  }

  static Future<String> getUserDocID(String email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Constant.userInfoCollection)
          .where(DocKeyUserInfo.user.name, isEqualTo: email)
          .get();
      return querySnapshot.docs[0].id;
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserInformation> getUserInfo({
    required String email,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.userInfoCollection)
        .where(DocKeyUserInfo.user.name, isEqualTo: email)
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var p = UserInformation.fromFirestoreDocUserInfo(
            doc: document, docIDs: doc.id);
        if (p != null) {
          return p;
        }
      }
    }
    return UserInformation();
  }

  //This Stephen's class
  static Future<List<UserInformation>> getAllUserInfo() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.userInfoCollection)
        .get();

    var result = <UserInformation>[];
    for (var doc in querySnapshot.docs) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var p = UserInformation.fromFirestoreDocUserInfo(
            doc: document, docIDs: doc.id);
        if (p != null) {
          result.add(p);
        }
      }
    }
    return result;
  }
  //

  //allows for access to the same document in firebase for later access to update
  static Future<void> replaceDocID({
    required String docID,
    required String documentID,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.userInfoCollection)
        .doc(docID)
        .update({'docID': documentID});
  }

  //updates information in userInfo
  static Future<void> updateUserInfo({
    required String docID,
    required Map<String, dynamic> update,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constant.userInfoCollection)
        .doc(docID)
        .update(update);
  }

  static Future<String> addLogs({
    required Logs logs,
  }) async {
    DocumentReference ref = await FirebaseFirestore.instance
        .collection(Constant.logsCollection)
        .add(logs.toFirestoreDocLogs());
    return ref.id;
  }

  static Future<List<bool>> getCompleted({
    required String email,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.logsCollection)
        .where(DocKeyLogs.email.name, isEqualTo: email)
        //add an orderBy part when time is added
        .get();

    var result = <bool>[];
        for(var doc in querySnapshot.docs){
          if(doc.data() != null){
            var document = doc.data() as Map<String, dynamic>;
            bool? p = Logs.fromFirestoreDocCompleted(doc: document, docIDs: doc.id);
            if(p!=null){
              result.add(p);
            }
          }
        }
    return result;
  }

  static Future<List<String>> getLogsList({
    required String email,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.logsCollection)
        .where(DocKeyLogs.email.name, isEqualTo: email)
        //add an orderBy part when time is added
        .get();

    var result = <String>[];
        for(var doc in querySnapshot.docs){
          if(doc.data() != null){
            var document = doc.data() as Map<String, dynamic>;
            String? p = Logs.fromFirestoreDocLogsList(doc: document, docIDs: doc.id);
            if(p!=null){
              result.add(p);
            }
          }
        }
    return result;
  }

  static Future<String> getLogs({
    required String comment,
  }) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.logsCollection)
        .where(DocKeyLogs.logs.name, isEqualTo: comment)
        .get();

        for(var doc in querySnapshot.docs){
          if(doc.data() != null){
            var document = doc.data() as Map<String, dynamic>;
            String p = Logs.fromFirestoreDocUpdateCompleted(doc: document, docID: doc.id);
          return p;
          }
        }
        return '';
  }

  static Future<void> replaceLogCompleted({
    required String docID,
    required bool completed,
  }) async {
    await FirebaseFirestore.instance.collection(Constant.logsCollection)
          .doc(docID).update({'completed':completed});
  }

  static Future<void> deleteLogs(String docID) async {
    await FirebaseFirestore.instance
        .collection(Constant.logsCollection)
        .doc(docID)
        .delete();
  }


}
