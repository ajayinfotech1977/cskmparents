import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cskmparents/database/database_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  /*below is a secretkey encrypted key which will go with each post 
  request so that nobody else can view the php file response except 
  of this app. Please dont tamper ot change this value. Its equivalent 
  decrypted text should be "ILove@Flutter_dart" which will be checked by php
  file before fetching any kind of data.
  */
  static String secreetKey = "WhzWoMoZQO2pgmw6h6So0j0b";
  static String globaladm_no = "";
  static String globalst_name = "";
  static String globalst_class = "";
  static String globalst_section = "";
  static String globalstImageName = "";
  static String globalpemail = "";
  static String globalpmn = "";
  static String globaladmNoP = "";
  static String globalfyP = "";
  static String globalloginByP = "";
  static int globalnotificationCount = 0;
  static int globalmessageCount = 0;
  static String globalfy = "";
  static String globaladmNo = "";
  static String globalloginBy = "";
  static int globalsno = 1;
  static String globalLastSelected_adm_no = "";
  static bool isNewMessage = false;
  static bool isChatScreenActive = false;
  static bool isNotificationScreenActive = false;
  static bool isNewNotification = false;

  static BoxDecoration boxDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.purple,
          Colors.blue,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  static TextStyle boldWhite30() {
    return const TextStyle(
      fontSize: 30,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle normalWhite15() {
    return const TextStyle(
      fontSize: 15,
      color: Colors.white,
    );
  }

  static TextStyle normalWhite20() {
    return const TextStyle(
      fontSize: 20,
      color: Colors.white,
    );
  }

  static TextStyle normalWhite() {
    return const TextStyle(
      color: Colors.white,
    );
  }

  static TextStyle normaYellow20() {
    return const TextStyle(
      fontSize: 20,
      color: Color.fromARGB(255, 248, 227, 5),
    );
  }

  static TextStyle normaYellow() {
    return const TextStyle(
      color: Color.fromARGB(255, 248, 227, 5),
    );
  }

  Future<String> checkLogin({
    @required username,
  }) async {
    //print("sending post request to server");
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // get device details
      String? deviceToken = await prefs.getString('deviceToken');
      String? make = await prefs.getString('make');
      String? model = await prefs.getString('model');
      String? appversion = await prefs.getString('appversion');
      String? appbuildNumber = await prefs.getString('appbuildNumber');
      //print("make = $make");
      //print("model = $model");
      //print("appversion = $appversion");
      //print("appbuildNumber = $appbuildNumber");
      var response = await http.post(
        Uri.parse(
            'https://www.cskm.com/schoolexpert/cskmparents/checkLogin.php'),
        body: {
          'username': username,
          'otp': 'yaja.heNs~hTraHdDis',
          'encrypted': 'No',
          'make': make,
          'model': model,
          'appversion': appversion,
          'appbuildNumber': appbuildNumber,
          'loginType': 'auto',
          'deviceToken': deviceToken,
        },
      );
      //print("response = ${response.body}");
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        int countData = data.length;
        //print("countData is $countData");
        // store the countData in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('totalStudents', countData);
        List<Student> students = [];
        // loop through 1 to countData
        for (int i = 0; i < countData; i++) {
          var dataI = data[i];
          var loginStatus = dataI['status'];
          if (loginStatus == 'valid') {
            // Login successful
            // store the data in variable array
            var adm_no = dataI['adm_no'];
            var st_name = dataI['st_name'];
            var st_class = dataI['st_class'];
            var st_section = dataI['st_section'];
            var stImageName = dataI['stImageName'];
            var pemail = dataI['pemail'];
            var pmn = dataI['pmn'];
            var admNoP = dataI['admNoP'];
            var fyP = dataI['fyP'].toString();
            var loginByP = dataI['loginByP'];
            var notificationCount = dataI['notificationCount'];
            var messagesCount = dataI['messagesCount'];
            var fy = dataI['fy'].toString();
            var admNo = dataI['admNo'].toString();
            var loginBy = dataI['loginBy'];

            Student st = Student(
                sno: i + 1,
                adm_no: adm_no,
                st_name: st_name,
                st_class: st_class,
                st_section: st_section,
                stImageName: stImageName,
                pemail: pemail,
                pmn: pmn,
                admNoP: admNoP,
                fyP: fyP,
                loginByP: loginByP,
                notificationCount: notificationCount,
                messagesCount: messagesCount,
                fy: fy,
                admNo: admNo,
                loginBy: loginBy);
            students.add(st);
          } else if (loginStatus == 'invalid') {
            // Login failed
            return Future.value("invalid");
          }
        }

        String key = 'students';
        // Encode and store data in SharedPreferences
        final String encodedData = Student.encode(students);
        // store the json in shared preferences
        await prefs.setString(key, encodedData);

        await AppConfig.setGlobalVariables();

        // Navigate to the home screen
        return Future.value("valid");
      }
      //if server is not reachable
      else if (response.statusCode == 500 || response.statusCode == 404) {
        //EasyLoading.showError("Server is not reachable");
        return Future.value("serverNotReachable");
      } else {
        // The login was unsuccessful
        //EasyLoading.showError(
        //"Server Problem! Please inform admin at 9312375581");
        return Future.value("serverDown");
      }
    } catch (Exception) {
      return Future.value("serverNotReachable");
    }
  }

  static Future<void> logout() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();

    if (await prefs.containsKey('username')) {
      await http.post(
        Uri.parse('https://www.cskm.com/schoolexpert/cskmparents/logout.php'),
        body: {
          'username': prefs.getString('username'),
          'otp': 'yaja.heNs~hTraHdDis',
          'deviceToken': prefs.getString('deviceToken'),
          'secretKey': secreetKey,
          'adm_no': globaladm_no,
        },
      );
    }
    //print(response.body);

    // get deviceToken from shared preferences
    String? deviceToken = await prefs.getString('deviceToken');
    String? make = await prefs.getString('make');
    String? model = await prefs.getString('model');
    String? appversion = await prefs.getString('appversion');
    String? appbuildNumber = await prefs.getString('appbuildNumber');

    // clear all prefs except deviceToken
    await prefs.clear();
    // set deviceToken back to shared preferences
    await prefs.setString('deviceToken', deviceToken!);
    // set device details back to shared preferences
    await prefs.setString('make', make!);
    await prefs.setString('model', model!);
    await prefs.setString('appversion', appversion!);
    await prefs.setString('appbuildNumber', appbuildNumber!);

    // delete database by calling removeDatabase() in database_helper.dart
    await DatabaseHelper().removeDatabase();
  }

  static void configLoading() {
    EasyLoading easyLoading = EasyLoading();
    easyLoading.loadingStyle = EasyLoadingStyle.dark;
    //easyLoading.indicatorType = EasyLoadingIndicatorType.threeBounce;
    //easyLoading.maskType = EasyLoadingMaskType.black;
    //easyLoading.backgroundColor = Color.fromARGB(10, 83, 83, 83);
  }

  //make globally available variables for the app fetched from shared preferences
  static Future<void> setGlobalVariables() async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('students')) {
      // fetch the globalLastSelected_adm_no from shared preferences
      globalLastSelected_adm_no =
          await prefs.getString('globalLastSelected_adm_no').toString();
      //print("globalLastSelected_adm_no = $globalLastSelected_adm_no");
      // Fetch and decode data
      final String studentString = await prefs.getString('students').toString();
      final List<Student> students = await Student.decode(studentString);
      if (!prefs.containsKey('globalLastSelected_adm_no')) {
        globaladm_no = students[0].adm_no;
        globalst_name = students[0].st_name;
        globalst_class = students[0].st_class;
        globalst_section = students[0].st_section;
        globalstImageName = students[0].stImageName;
        globalpemail = students[0].pemail;
        globalpmn = students[0].pmn;
        globaladmNoP = students[0].admNoP;
        globalfyP = students[0].fyP;
        globalloginByP = students[0].loginByP;
        globalnotificationCount = students[0].notificationCount;
        globalmessageCount = students[0].messagesCount;
        globalfy = students[0].fy;
        globaladmNo = students[0].admNo;
        globalloginBy = students[0].loginBy;
        globalsno = students[0].sno;

        // if globalLastSelected_adm_no is empty then set it to globaladm_no
        globalLastSelected_adm_no = globaladm_no;
        // set globalLastSelected_adm_no in shared preferences
        await prefs.setString(
            'globalLastSelected_adm_no', globalLastSelected_adm_no);
      } else {
        var studentFound = false;
        // loop through all students and find the student with adm_no = globalLastSelected_adm_no
        for (int i = 0; i < students.length; i++) {
          if (students[i].adm_no == globalLastSelected_adm_no) {
            studentFound = true;
            globaladm_no = students[i].adm_no;
            globalst_name = students[i].st_name;
            globalst_class = students[i].st_class;
            globalst_section = students[i].st_section;
            globalstImageName = students[i].stImageName;
            globalpemail = students[i].pemail;
            globalpmn = students[i].pmn;
            globaladmNoP = students[i].admNoP;
            globalfyP = students[i].fyP;
            globalloginByP = students[i].loginByP;
            globalnotificationCount = students[i].notificationCount;
            globalmessageCount = students[i].messagesCount;
            globalfy = students[i].fy;
            globaladmNo = students[i].admNo;
            globalloginBy = students[i].loginBy;
            globalsno = students[i].sno;
            break;
          }
        }
        // if student not found then set globalLastSelected_adm_no to globaladm_no
        if (!studentFound) {
          globaladm_no = students[0].adm_no;
          globalst_name = students[0].st_name;
          globalst_class = students[0].st_class;
          globalst_section = students[0].st_section;
          globalstImageName = students[0].stImageName;
          globalpemail = students[0].pemail;
          globalpmn = students[0].pmn;
          globaladmNoP = students[0].admNoP;
          globalfyP = students[0].fyP;
          globalloginByP = students[0].loginByP;
          globalnotificationCount = students[0].notificationCount;
          globalmessageCount = students[0].messagesCount;
          globalfy = students[0].fy;
          globaladmNo = students[0].admNo;
          globalloginBy = students[0].loginBy;
          globalsno = students[0].sno;

          // if globalLastSelected_adm_no is empty then set it to globaladm_no
          globalLastSelected_adm_no = globaladm_no;
          // set globalLastSelected_adm_no in shared preferences
          await prefs.setString(
              'globalLastSelected_adm_no', globalLastSelected_adm_no);
        }
      }
    }
  }

  static Future<void> changeActiveStudent(String adm_no) async {
    SharedPreferences? prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('students')) {
      // Fetch and decode data
      final String studentString = await prefs.getString('students').toString();
      final List<Student> students = await Student.decode(studentString);

      // search for adm_no in students list matching with adm_no
      for (int i = 0; i < students.length; i++) {
        if (students[i].adm_no == adm_no) {
          //print("found adm_no at index $i");
          //print("students[i].adm_no = ${students[i].adm_no}");
          //print("students[i].st_name = ${students[i].st_name}");
          //print("students[i].st_class = ${students[i].st_class}");
          //print("students[i].st_section = ${students[i].st_section}");
          //print("students[i].stImageName = ${students[i].stImageName}");
          //print("students[i].pemail = ${students[i].pemail}");
          //print("students[i].pmn = ${students[i].pmn}");
          //print("students[i].admNoP = ${students[i].admNoP}");
          //print("students[i].fyP = ${students[i].fyP}");
          //print("students[i].loginByP = ${students[i].loginByP}");
          //print("students[i].notificationCount = ${students[i].notificationCount}");
          //print("students[i].fy = ${students[i].fy}");
          //print("students[i].admNo = ${students[i].admNo}");
          //print("students[i].loginBy = ${students[i].loginBy}");
          //print("students[i].sno = ${students[i].sno}");
          globaladm_no = students[i].adm_no;
          globalst_name = students[i].st_name;
          globalst_class = students[i].st_class;
          globalst_section = students[i].st_section;
          globalstImageName = students[i].stImageName;
          globalpemail = students[i].pemail;
          globalpmn = students[i].pmn;
          globaladmNoP = students[i].admNoP;
          globalfyP = students[i].fyP;
          globalloginByP = students[i].loginByP;
          globalnotificationCount = students[i].notificationCount;
          globalmessageCount = students[i].messagesCount;
          globalfy = students[i].fy;
          globaladmNo = students[i].admNo;
          globalloginBy = students[i].loginBy;
          globalsno = students[i].sno;
          globalLastSelected_adm_no = adm_no;
          // set globalLastSelected_adm_no in shared preferences
          await prefs.setString(
              'globalLastSelected_adm_no', globalLastSelected_adm_no);
          break;
        }
      }
    }
  }

  Future<Map<String, String>> getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return {
        'make': androidInfo.manufacturer,
        'model': androidInfo.model,
        'appversion': appVersion,
        'appbuildNumber': buildNumber,
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return {
        'make': 'Apple',
        'model': iosInfo.model,
        'appversion': appVersion,
        'appbuildNumber': buildNumber,
      };
    }
    return {
      'make': 'Unknown',
      'model': 'Unknown',
      'appversion': appVersion,
      'appbuildNumber': buildNumber,
    };
  }

  Future<void> initDeviceInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> deviceDetails = await AppConfig().getDeviceDetails();
    if (!prefs.containsKey('make') || prefs.getString('make') == null) {
      // store device information also
      await prefs.setString('make', deviceDetails['make']!);
      await prefs.setString('model', deviceDetails['model']!);
    }
    await prefs.setString('appversion', deviceDetails['appversion']!);
    await prefs.setString('appbuildNumber', deviceDetails['appbuildNumber']!);
  }
}

class Student {
  int sno;
  String adm_no;
  String st_name;
  String st_class;
  String st_section;
  String stImageName;
  String pemail;
  String pmn;
  String admNoP;
  String fyP;
  String loginByP;
  int notificationCount;
  int messagesCount;
  String fy;
  String admNo;
  String loginBy;

  Student({
    required this.sno,
    required this.adm_no,
    required this.st_name,
    required this.st_class,
    required this.st_section,
    required this.stImageName,
    required this.pemail,
    required this.pmn,
    required this.admNoP,
    required this.fyP,
    required this.loginByP,
    required this.notificationCount,
    required this.messagesCount,
    required this.fy,
    required this.admNo,
    required this.loginBy,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        sno: json["sno"],
        adm_no: json["adm_no"],
        st_name: json["st_name"],
        st_class: json["st_class"],
        st_section: json["st_section"],
        stImageName: json["stImageName"],
        pemail: json["pemail"],
        pmn: json["pmn"],
        admNoP: json["admNoP"],
        fyP: json["fyP"],
        loginByP: json["loginByP"],
        notificationCount: json["notificationCount"],
        messagesCount: json["messagesCount"],
        fy: json["fy"],
        admNo: json["admNo"],
        loginBy: json["loginBy"],
      );

  static Map<String, dynamic> toMap(Student student) => {
        "sno": student.sno,
        "adm_no": student.adm_no,
        "st_name": student.st_name,
        "st_class": student.st_class,
        "st_section": student.st_section,
        "stImageName": student.stImageName,
        "pemail": student.pemail,
        "pmn": student.pmn,
        "admNoP": student.admNoP,
        "fyP": student.fyP,
        "loginByP": student.loginByP,
        "notificationCount": student.notificationCount,
        "messagesCount": student.messagesCount,
        "fy": student.fy,
        "admNo": student.admNo,
        "loginBy": student.loginBy,
      };

  static String encode(List<Student> students) => json.encode(
        students
            .map<Map<String, dynamic>>((student) => Student.toMap(student))
            .toList(),
      );

  static List<Student> decode(String students) =>
      (json.decode(students) as List<dynamic>)
          .map<Student>((item) => Student.fromJson(item))
          .toList();
}
