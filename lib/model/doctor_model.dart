class Doctor {
  String? name;
  String? docId;
  String? docEmail;
  late List<dynamic>? userEmails;
  String? docImg;

  static const NAME = 'name';
  static const DOC_EMAIL = 'docEmail';
  static const USER_EMAILS = 'userEmails';
  static const DOC_IMG = 'docImg';

  Doctor({
    this.name,
    this.docEmail,
    this.userEmails,
    this.docImg,
    this.docId,
  }) {}

  Map<String, dynamic> serialize() {
    return {
      NAME: name,
      DOC_EMAIL: docEmail,
      USER_EMAILS: userEmails,
      DOC_IMG: docImg,
    };
  }

  static Doctor deserialize(
    Map<String, dynamic> doc,
    String docId,
  ) {
    return Doctor(
      name: doc[NAME],
      docEmail: doc[DOC_EMAIL],
      userEmails: doc[USER_EMAILS],
      docImg: doc[DOC_IMG],
      docId: docId,
    );
  }
}
