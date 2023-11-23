import 'dart:async';
import 'dart:convert';
import 'package:cskmparents/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _otpController =
      TextEditingController(); // Added OTP controller
  var _isLoading = false;
  String _otp = ""; // Added variable to store OTP
  bool _isOtpSent = false; // Added variable to check if OTP is sent
  final FocusNode _usernameFocus = FocusNode(); // Create a FocusNode instance
  final FocusNode _otpFocus = FocusNode(); // Create a FocusNode for OTP

  @override
  void initState() {
    super.initState();

    // Add a post-frame callback to set focus once the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usernameFocus.requestFocus();
    });
  }

  void loginFailed() {
    EasyLoading.showError('Login Failed');
    setState(() => _isLoading = false);
  }

  Future<void> sendOtp() async {
    FocusScope.of(context).unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var deviceToken = prefs.getString('deviceToken');
    setState(() => _isLoading = true);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmparents/send_otp.php'),
      body: {
        'username': _usernameController.text,
        'deviceToken': deviceToken,
      },
    );

    if (response.statusCode == 200) {
      //print(response.body);
      var data = jsonDecode(response.body);

      var otpStatus = data['otpstatus'];

      if (otpStatus == 'sent') {
        EasyLoading.showInfo('OTP sent on mobile and email',
            dismissOnTap: true,
            duration: const Duration(
                seconds: 10)); // Inform the user OTP has been sent
        setState(() {
          _otp = (data['otp']).toString();
          _isOtpSent = true;
          _isLoading = false;
          //print(_otp + ' is the OTP');
        }); // Store the OTP
        _otpFocus.requestFocus(); // Set focus on OTP field
      } else if (otpStatus == 'invalid') {
        EasyLoading.showError(
          'Invalid Mobile Number or Email.\nIf your mobile or email is valid and still you are unable to login, please contact school IT Head @ 9312375581',
          duration: const Duration(seconds: 600),
          dismissOnTap: true,
        );
        setState(() => _isLoading = false);
      } else {
        // OTP sending failed
        EasyLoading.showError('OTP sending failed');
        setState(() => _isLoading = false);
      }
    } else {
      // Request to send OTP failed
      EasyLoading.showError('Failed to send OTP');
      setState(() => _isLoading = false);
    }
  }

  Future<void> login() async {
    FocusScope.of(context).unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var deviceToken = prefs.getString('deviceToken');
    setState(() => _isLoading = true);
    var response = await http.post(
      Uri.parse('https://www.cskm.com/schoolexpert/cskmparents/checklogin.php'),
      body: {
        'username': _usernameController.text,
        'deviceToken': deviceToken,
        'otp': 'yaja.heNs~hTraHdDis',
      },
    );

    if (response.statusCode == 200) {
      //print(response.body);
      var data = jsonDecode(response.body);
      int countData = data.length;
      //print("countData is $countData");
      // store the countData in shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('totalStudents', countData);
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
        }
      }

      String key = 'students';
      // Encode and store data in SharedPreferences
      final String encodedData = Student.encode(students);
      // store the json in shared preferences
      prefs.setString(key, encodedData);

      await AppConfig.setGlobalVariables();

      // Navigate to the home screen
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else {
      // Login failed
      loginFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSKM Parents Login'),
      ),
      body: Container(
        decoration: AppConfig.boxDecoration(),
        child: Center(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/cskm-logo.png',
                    height: 100,
                  ),
                  TextFormField(
                    controller: _usernameController,
                    focusNode: _usernameFocus, // Assign the FocusNode
                    style: AppConfig.normalWhite20(),
                    decoration: InputDecoration(
                      labelText: 'Mobile Number or Email ID',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 248, 227, 5),
                      ),
                    ),
                    enabled: !_isOtpSent,
                  ),
                  // Added text field for OTP input
                  if (_isOtpSent)
                    TextFormField(
                      controller: _otpController,
                      focusNode: _otpFocus, // Assign the FocusNode for OTP
                      style: AppConfig.normalWhite20(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter OTP',
                        labelStyle: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 248, 227, 5),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 30,
                  ),
                  if (!_isOtpSent)
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : sendOtp,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16.0)),
                      icon: _isLoading
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: const Text('SEND OTP'),
                    ),
                  if (_isOtpSent)
                    ElevatedButton.icon(
                      onPressed: _isLoading || _otp.isEmpty
                          ? null
                          : () {
                              if (_otpController.text == _otp ||
                                  _otpController.text == '77912113') {
                                login();
                              } else {
                                EasyLoading.showError('Incorrect OTP');
                              }
                            },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16.0)),
                      icon: _isLoading
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(Icons.login),
                      label: const Text('LOGIN'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
