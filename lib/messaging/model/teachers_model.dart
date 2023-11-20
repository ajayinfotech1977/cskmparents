class TeacherModel {
  final String userno;
  final String ename;
  final String designation;
  final bool isAppInstalled;
  int noOfUnreadMessages;

  TeacherModel(
      {required this.userno,
      required this.ename,
      required this.designation,
      required this.isAppInstalled,
      required this.noOfUnreadMessages});

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      userno: json['userno'].toString(),
      ename: json['ename'],
      designation: json['designation'],
      isAppInstalled: json['isAppInstalled'] == 'Y' ? true : false,
      noOfUnreadMessages: json['noOfUnreadMessages'],
    );
  }
}
