import 'dart:convert';
import 'package:cskmparents/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtpScreen extends StatefulWidget {
  final String deviceToken;

  OtpScreen({required this.deviceToken});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otp = "";
  // Define a TextEditingController
  TextEditingController otpController = TextEditingController();
  bool isButtonDisabled = false;
  @override
  void initState() {
    super.initState();
    sendOtp();
  }

  Future<void> sendLogoutCommand() async {
    // Get the OTP entered in the TextField
    String otpEntered = otpController.text;
    // Verify that the OTP is not blank
    if (otpEntered.isNotEmpty) {
      // OTP is not blank, proceed with verification
      // Implement your logic to verify the OTP
      if (otpEntered == otp) {
        setState(() {
          isButtonDisabled = true;
        });
        // correct otp entered, proceed with logout
        String deviceToken = widget.deviceToken;
        // send a post request to the https://www.cskm.com/schoolexpert/cskmparents/send_logout_command.php
        // with the following parameters:
        // deviceToken
        var url = Uri.parse(
            'https://www.cskm.com/schoolexpert/cskmparents/send_logout_command.php');
        var data = {
          'deviceToken': deviceToken,
        };
        await http.post(url, body: data).then((response) {
          //print('Response status: ${response.statusCode}');
          //print('Response body: ${response.body}');
          if (response.statusCode == 200) {
            String responseBody = response.body;
            // Decode the response body as a JSON object
            Map<String, dynamic> responseJson = jsonDecode(responseBody);

            // Read the status value from the JSON object
            String status = responseJson['status'];
            // Print the status value
            //print('status: $status');
            if (status == 'success') {
              // show a dialog box with the message "Logout command sent successfully"
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout command sent successfully'),
                  content: Text(
                      'The parents app will be automatically logged out from the selected device on next app launch'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Navigate to the MobileListScreen
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            } else {
              setState(() {
                isButtonDisabled = false;
              });
              // show a dialog box with the message "Failed to send logout command"
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Failed to send logout command'),
                  content: Text('Please try again later'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            }
          } else {
            setState(() {
              isButtonDisabled = false;
            });
            // show a dialog box with the message "Failed to send logout command"
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Failed to send logout command'),
                content: Text('Please try again later'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        });
      } else {
        // show a dialog box with the message "Invalid OTP"
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Invalid OTP'),
            content: Text('Please enter the correct OTP'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // OTP is blank, show an error message or perform appropriate action
      // For example, show a snackbar or display an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the OTP'),
        ),
      );
    }
  }

  Future<void> sendOtp() async {
    String deviceToken = widget.deviceToken;
    //print('deviceToken: $deviceToken');
    String pmn = AppConfig.globalpmn;
    String pemail = AppConfig.globalpemail;
    //print('pmn: $pmn');
    //print('pemail: $pemail');

    // send a post request to the https://www.cskm.com/schoolexpert/cskmparents/senddeviveotp.php
    // with the following parameters:
    // deviceToken, pmn, pemail
    var url = Uri.parse(
        'https://www.cskm.com/schoolexpert/cskmparents/send_logout_otp.php');
    var data = {
      'deviceToken': deviceToken,
      'pmn': pmn,
      'pemail': pemail,
    };
    await http.post(url, body: data).then((response) {
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        String responseBody = response.body;
        // Decode the response body as a JSON object
        Map<String, dynamic> responseJson = jsonDecode(responseBody);

        // Read the OTP value from the JSON object
        otp = responseJson['otp'].toString();
        String otpstatus = responseJson['otpstatus'];
        // Print the OTP value
        //print('OTP: $otp');
        if (otpstatus == 'sent') {
          // show a dialog box with the message "OTP sent successfully"
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('OTP sent successfully'),
              content: Text(
                  'Please check your registered mobile number and email for the OTP'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // show a dialog box with the message "Failed to send OTP"
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Failed to send OTP'),
              content: Text('Please try again later'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        // show a dialog box with the message "Failed to send OTP"
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Failed to send OTP'),
            content: Text('Please try again later'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout from device'),
      ),
      body: Container(
        decoration: AppConfig.boxDecoration(),
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter OTP sent to your registered mobile number and email address to logout from selected device',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Replace with your desired text color
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter OTP',
                border: OutlineInputBorder(),
                fillColor:
                    Colors.white, // Replace with your desired text field color
                filled: true,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement your logic to verify the OTP
                isButtonDisabled ? null : sendLogoutCommand();
              },
              child: isButtonDisabled
                  ? Text('Sending Logout Command...')
                  : Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
