import 'package:intl/intl.dart';

class MessageModel {
  final String fromNo;
  final String toNo;
  final String message;
  final DateTime dateTime;

  MessageModel({
    required this.fromNo,
    required this.toNo,
    required this.message,
    required this.dateTime,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    final msgDate = DateFormat("dd-MMM-yyyy hh:mm a").parse(map['msgDate']);
    String fromNo = '';
    String toNo = '';
    if (map['msgType'] == 'S') {
      fromNo = map['userno'];
      toNo = map['adm_no'];
    } else if (map['msgType'] == 'P') {
      fromNo = map['adm_no'];
      toNo = map['userno'];
    }
    return MessageModel(
      fromNo: fromNo,
      toNo: toNo,
      message: map['msg'],
      dateTime: msgDate,
    );
  }
}
