import 'dart:convert';
import 'package:cskmparents/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class Notification {
  final String date;
  final String time;
  final String message;
  final String status;

  Notification({
    required this.date,
    required this.time,
    required this.message,
    required this.status,
  });
}

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Notification> _notifications = [];
  bool fetched = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final response = await http.post(
      Uri.parse(
          'https://www.cskm.com/schoolexpert/cskmparents/show_notifications.php'),
      body: {
        'adm_no': AppConfig.globaladm_no,
        'secretKey': AppConfig.secreetKey,
      },
    );
    //print("response is ${response.body}");
    if (response.statusCode == 200) {
      // show response.body in console
      fetched = true;
      //print(response.body);
      final data = json.decode(response.body);

      _notifications = List<Notification>.from(
          data['notifications'].map((notification) => Notification(
                date: notification['date'],
                time: notification['time'],
                message: notification['message'],
                status: notification['status'],
              )));
      setState(() {});
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  List<InlineSpan> parseText(String text) {
    final RegExp urlRegExp =
        RegExp(r"(?:(?:https?|ftp):\/\/)[\w/\-?=%.]+\.[\w/\-?=%.]+");
    final List<InlineSpan> spans = [];
    final List<String> substrings = text.split(urlRegExp);
    final Iterable<Match> matches = urlRegExp.allMatches(text);

    for (int i = 0; i < substrings.length; i++) {
      spans.add(TextSpan(text: substrings[i]));
      if (i < matches.length) {
        final String url = matches.elementAt(i).group(0)!;
        // create Uri object from url
        final Uri uri = Uri.parse(url);
        spans.add(TextSpan(
          text: url,
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (!await launchUrl(uri)) {
                throw Exception('Could not launch $uri');
              }
            },
        ));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
                            colors: [
                              Colors.pink,
                              Colors.purple,
                              Colors.deepPurple
                            ], // Customize the colors
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
        ),
        child: _notifications.isEmpty && !fetched
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _notifications.isEmpty
                ? Center(
                    child: Text('No Notification is yet sent to you'),
                  )
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Column(
                        children: [
                          Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: notification.status == 'U'
                                  ? Text.rich(
                                      TextSpan(
                                        children:
                                            parseText(notification.message),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    )
                                  : Text.rich(
                                      TextSpan(
                                        children:
                                            parseText(notification.message),
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                              subtitle: Text(
                                '${notification.date} ${notification.time}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }
}
