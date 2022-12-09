enum DocKeyUserInfo {
  docID,
  user,
  username,
  adminFlag,
  photoURL,
  photoFilename,
  phone,
  biography,
  maxRecord,
  friends,
}

enum PhotoSource { camera, gallery }

class UserInformation {
  late String? docID;
  late String? user;
  late String? username;
  late bool adminFlag;
  late String? userPhotoURL;
  late String? photoFilename;
  late String? phone;
  late String? biography;
  late int? maxRecord;
  late List<dynamic> friends;
  UserInformation({
    this.docID = '',
    this.username = '',
    this.user = '',
    this.adminFlag = false,
    this.userPhotoURL = '',
    this.photoFilename = '',
    this.phone = '',
    this.biography = '',
    this.maxRecord,
    List<dynamic>? friends,
  }) {
    this.friends = friends == null ? [] : [...friends];
  }

  UserInformation.clone(UserInformation p) {
    docID = p.docID;
    userPhotoURL = p.userPhotoURL;
    username = p.username;
    user = p.user;
    adminFlag = p.adminFlag;
    photoFilename = p.photoFilename;
    phone = p.phone;
    biography = p.biography;
    maxRecord = p.maxRecord;
    friends = [...p.friends];
  }

  void copyFrom(UserInformation p) {
    userPhotoURL = p.userPhotoURL;
    username = p.username;
    user = p.user;
    adminFlag = p.adminFlag;
    photoFilename = p.photoFilename;
    phone = p.phone;
    biography = p.biography;
    maxRecord = p.maxRecord;
    friends = [...p.friends];
  }

  Map<String, dynamic> toFirestoreDocUserInfo() {
    return {
      DocKeyUserInfo.docID.name: docID,
      DocKeyUserInfo.user.name: user,
      DocKeyUserInfo.username.name: username,
      DocKeyUserInfo.adminFlag.name: adminFlag,
      DocKeyUserInfo.photoURL.name: userPhotoURL,
      DocKeyUserInfo.photoFilename.name: photoFilename,
      DocKeyUserInfo.phone.name: phone,
      DocKeyUserInfo.biography.name: biography,
      DocKeyUserInfo.maxRecord.name: maxRecord,
      DocKeyUserInfo.friends.name: friends,
    };
  }

  static UserInformation? fromFirestoreDocUserInfo({
    required Map<String, dynamic> doc,
    required String docIDs,
  }) {
    return UserInformation(
      docID: doc[DocKeyUserInfo.docID.name] ??= '',
      username: doc[DocKeyUserInfo.username.name] ??= '',
      user: doc[DocKeyUserInfo.user.name] ??= '',
      adminFlag: doc[DocKeyUserInfo.adminFlag.name] ??= false,
      userPhotoURL: doc[DocKeyUserInfo.photoURL.name] ??= '',
      photoFilename: doc[DocKeyUserInfo.photoFilename.name] ??= '',
      phone: doc[DocKeyUserInfo.phone.name] ??= '',
      biography: doc[DocKeyUserInfo.biography.name] ??= '',
      maxRecord: doc[DocKeyUserInfo.maxRecord.name],
      friends: doc[DocKeyUserInfo.friends.name] ??= [],
    );
  }

  static String getFriendName(String value) {
    try {
      return value.split('|')[0];
    } catch (e) {
      return '';
    }
  }

  static String getFriendEmail(String value) {
    try {
      return value.split('|')[1];
    } catch (e) {
      return '';
    }
  }
}
