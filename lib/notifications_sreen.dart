import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cskmparents/database/database_helper.dart';

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

  factory Notification.fromMap(Map<String, dynamic> map) {
    final notificationDate =
        DateFormat("dd-MMM-yyyy hh:mm a").parse(map['notificationDate']);

    // Extract date and time from notificationDate
    final date = DateFormat("dd-MMM-yyyy").format(notificationDate);
    final time = DateFormat("hh:mm a").format(notificationDate);

    return Notification(
      date: date,
      time: time,
      message: map['notification'],
      status: map['notificationStatus'],
    );
  }
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
    // call DatabaseHelper class to get data from table
    final dbHelper = DatabaseHelper();
    // initialize database

    final _db = await dbHelper.initDatabase();
    await dbHelper.createTableParentsNotifications(_db, 1);
    //delete all data from table
    //await dbHelper.deleteAllDataFromParentsNotifications();
    // sync data from server
    await dbHelper.syncDataToParentsNotifications();
    final data = await dbHelper.getDataFromParentsNotifications();

    // convert data to List<Notification>
    _notifications = List.generate(data.length, (i) {
      return Notification.fromMap(data[i]);
    });
    fetched = true;
    // close the database connection
    setState(() {});
    // call updateNotificationStatusToR() method to update notification status to R
    await dbHelper.updateNotificationStatusToR();
    dbHelper.close();
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _notifications.isEmpty && !fetched
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _notifications.isEmpty
                ? Center(
                    child: Text(
                      'You have not received any notifications yet.',
                      // font colour white
                      style: TextStyle(
                        color: Colors.white,
                        // size 20
                        fontSize: 20,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Column(
                        children: [
                          Card(
                            // rounded corners
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                            margin: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
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
