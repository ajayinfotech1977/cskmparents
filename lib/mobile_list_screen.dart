import 'dart:convert';
import 'package:cskmparents/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cskmparents/otp_screen.dart';

class MobileListScreen extends StatefulWidget {
  @override
  _MobileListScreenState createState() => _MobileListScreenState();
}

class _MobileListScreenState extends State<MobileListScreen> {
  List<Mobile> mobiles = [];
  bool isLoading = false;
  String deviceToken = '';

  @override
  void initState() {
    super.initState();
    fetchMobiles();
    getDeviceTokenFromSharedPreferences();
  }

  Future<void> getDeviceTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      deviceToken = prefs.getString('deviceToken') ?? '';
    });
  }

  Future<void> fetchMobiles() async {
    setState(() {
      isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = await prefs.getString('username');
      final response = await http.post(
          Uri.parse(
              'https://www.cskm.com/schoolexpert/cskmparents/devicesLoggedIn.php'),
          body: {
            'username': username,
            'otp': 'yaja.heNs~hTraHdDis',
            'adm_no': AppConfig.globaladm_no,
          });
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          mobiles =
              List<Mobile>.from(jsonData.map((json) => Mobile.fromJson(json)));
        });
      } else {
        // Handle error response
        //print('Failed to fetch mobiles. Status code: ${response.statusCode}');
        // show error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text(
                'Failed to fetch mobiles. Status code: ${response.statusCode}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle network or other errors
      // print('Failed to fetch mobiles: $e');
      // show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch mobiles: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logoutFromDevice(String deviceToken) async {
    try {
      final response = await http.post(
          Uri.parse(
              'https://www.cskm.com/schoolexpert/cskmparents/logoutfromdevice.php'),
          body: {
            'deviceToken': deviceToken,
          });
      if (response.statusCode == 200) {
        // Display logout success message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Logout'),
            content: Text('Request for logout sent.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Handle error response
        // print('Failed to logout. Status code: ${response.statusCode}');
        // show error message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content:
                Text('Failed to logout. Status code: ${response.statusCode}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle network or other errors
      // print('Failed to logout: $e');
      // show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to logout: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logged In Devices'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink, Colors.purple, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: mobiles.length,
                itemBuilder: (context, index) {
                  final mobile = mobiles[index];
                  bool isThisDevice = mobile.deviceToken == deviceToken;
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${mobile.make} ${mobile.model}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isThisDevice)
                            Text(
                              '(This device)',
                              style: TextStyle(
                                //fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 29, 122, 32),
                              ),
                            ),
                        ],
                      ),
                      subtitle: mobile.logout == 'Y'
                          ? Text(
                              'Logout command sent',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            )
                          : null,
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: mobile.deviceToken,
                            enabled: mobile.logout != 'Y' && !isThisDevice,
                            child: Text('Logout'),
                          ),
                        ],
                        onSelected: (value) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OtpScreen(deviceToken: value),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class Mobile {
  final String make;
  final String model;
  final String deviceToken;
  final String logout;

  Mobile(
      {required this.make,
      required this.model,
      required this.deviceToken,
      required this.logout});

  factory Mobile.fromJson(Map<String, dynamic> json) {
    return Mobile(
      make: json['make'],
      model: json['model'],
      deviceToken: json['deviceToken'],
      logout: json['logout'],
    );
  }
}
