import 'dart:convert';
import 'package:cskmparents/messaging/model/message_model.dart';
import 'package:http/http.dart' as http;
import 'package:cskmparents/messaging/model/teachers_model.dart';
import 'package:cskmparents/app_config.dart';
import 'package:cskmparents/database/database_helper.dart';

class ApiService {
  static const String baseUrl = 'https://www.cskm.com/schoolexpert/cskmparents';

  Future<void> syncMessages() async {
    try {
      // call DatabaseHelper class to get data from table
      final dbHelper = DatabaseHelper();
      final _db = await dbHelper.initDatabase();
      await dbHelper.createTableMessages(_db, 1);
      // sync data from server
      await dbHelper.syncDataToMessages();

      dbHelper.close();
      print("syncMessages completed");
    } catch (Exception) {
      print("syncMessages Exception: $Exception");
    }
  }

  Future<List<TeacherModel>> getTeachers(String adm_no) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_teachers.php'),
      body: {
        'adm_no': adm_no,
        'secretKey': AppConfig.secreetKey,
        'st_class': AppConfig.globalst_class,
        'st_section': AppConfig.globalst_section,
        'fy': AppConfig.globalfy,
      },
    );

    syncMessages();

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      //print("response= $jsonData");
      // return List<TeacherModel>.from(
      //     //employees = List<Map<String, dynamic>>.from(data['employees']);
      //     jsonData['students'].map((json) => TeacherModel.fromJson(json)));
      var teachersList = List<TeacherModel>.from(
          jsonData['teachers'].map((json) => TeacherModel.fromJson(json)));

      teachersList.sort((a, b) {
        // Sort by noOfUnreadMessages in descending order
        var result = b.noOfUnreadMessages.compareTo(a.noOfUnreadMessages);
        if (result != 0) {
          return result;
        }

        // // sort by isAppInstalled in descending order
        // var result2 = b.isAppInstalled ? 1 : 0 - (a.isAppInstalled ? 1 : 0);
        // if (result2 != 0) {
        //   return result2;
        // }

        // // sort by designation in ascending order
        // return a.designation.compareTo(b.designation);
        return result;
      });
      return teachersList;
    } else {
      throw Exception('Failed to load teachers');
    }
  }

  Future<void> sendMessage(String fromNo, String toNo, String message) async {
    final response = await http.post(
      Uri.parse(
          'https://www.cskm.com/schoolexpert/cskmemp/send_message_to_teacher.php'),
      body: {
        'secretKey': AppConfig.secreetKey,
        'adm_no': fromNo.toString(),
        'userNo': toNo.toString(),
        'message': message,
        'st_name': AppConfig.globalst_name,
      },
    );
    //print("response= ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to send message');
    }
  }

  Future<List<MessageModel>> getMessages(String fromNo, String toNo) async {
    final dbHelper = DatabaseHelper();
    // initialize database
    await dbHelper.initDatabase();
    // fetch data from database
    final data = await dbHelper.getDataFromMessages(fromNo, toNo);
    // print("fromNo= $fromNo, toNo= $toNo");
    // print(data);
    // convert data to List<MessageModel>
    List<MessageModel> messages = List.generate(data.length, (i) {
      return MessageModel.fromMap(data[i]);
    });
    // close database connection
    dbHelper.close();

    //print(messages);
    return messages;
  }

  // function to update the status of message to read for the userno and adm_no
  Future<void> updateMessageStatus(String adm_no, String userno) async {
    final dbHelper = DatabaseHelper();
    // initialize database
    await dbHelper.initDatabase();
    // update the status of message to read for the userno and adm_no
    await dbHelper.updateMessageStatusToR(adm_no, userno);
    // close database connection
    dbHelper.close();
  }
}
