import 'dart:async';
import 'package:cskmparents/app_config.dart';
import 'package:cskmparents/messaging/message_tabbed_screen.dart';
import 'package:cskmparents/notifications_sreen.dart';
import 'package:flutter/material.dart';
import 'package:cskmparents/custom_data_stream.dart';

StreamController<CustomData> streamController =
    StreamController<CustomData>.broadcast();

class HomeScreenButtons extends StatefulWidget {
  const HomeScreenButtons({super.key});

  @override
  State<HomeScreenButtons> createState() => _HomeScreenButtonsState();
}

class _HomeScreenButtonsState extends State<HomeScreenButtons> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    streamController.stream.listen((customData) {
      if (mounted) {
        // print('customData.form: ${customData.form}');
        // print('customData.count: ${customData.count}');
        setState(() {
          if (customData.form == 'message') {
            AppConfig.globalmessageCount =
                AppConfig.globalmessageCount - customData.count;
          } else if (customData.form == 'notification') {
            AppConfig.globalnotificationCount = customData.count;
          }
        });
      }
    });
  }

  // void openMessages(context) {
  //   Navigator.pushNamed(context, '/messagetabbedscreen');
  // }

  void openMessages(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageTabbedScreen(
          stream: streamController,
        ),
      ),
    );
  }

  void openSchoolExpert(context) {
    Navigator.pushNamed(context, '/parentlogin');
  }

  // void openNotifications(context) {

  //   Navigator.pushNamed(context, '/notifications');
  // }

  void openNotifications(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationScreen(
          stream: streamController,
        ),
      ),
    );
  }

  void openProfile(context) {
    Navigator.pushNamed(context, '/profile');
  }

  void openReportCard(context) {
    Navigator.pushNamed(context, '/reportcard');
  }

  void openMarks(context) {
    Navigator.pushNamed(context, '/marks');
  }

  void openResultAnalysis(context) {
    Navigator.pushNamed(context, '/resultanalysis');
  }

  void openAttendance(context) {
    Navigator.pushNamed(context, '/attendance');
  }

  void openTimeTable(context) {
    Navigator.pushNamed(context, '/timetable');
  }

  void openAcademicCalendar(context) {
    Navigator.pushNamed(context, '/academiccalendar');
  }

  void openFeeSummary(context) {
    Navigator.pushNamed(context, '/feesummary');
  }

  void openFeeSlips(context) {
    Navigator.pushNamed(context, '/feeslips');
  }

  void openPhotoGallery(context) {
    Navigator.pushNamed(context, '/photogallery');
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.0, // Set childAspectRatio to 1.0
      children: [
        ButtonWidget(
          buttonText: 'Notifications',
          icon: Icons.notifications,
          onTap: openNotifications,
          count: AppConfig.globalnotificationCount,
        ),
        ButtonWidget(
          buttonText: 'Messaging',
          icon: Icons.message,
          onTap: openMessages,
          count: AppConfig.globalmessageCount,
        ),
        ButtonWidget(
          buttonText: 'Profile',
          icon: Icons.person,
          onTap: openProfile,
        ),
        ButtonWidget(
          buttonText: 'Report Card',
          icon: Icons.book,
          onTap: openReportCard,
        ),
        ButtonWidget(
          buttonText: 'Marks',
          icon: Icons.edit,
          onTap: openMarks,
        ),
        ButtonWidget(
          buttonText: 'Result Analysis',
          icon: Icons.analytics,
          onTap: openResultAnalysis,
        ),
        ButtonWidget(
          buttonText: 'Attendance',
          icon: Icons.calendar_today,
          onTap: openAttendance,
        ),
        ButtonWidget(
          buttonText: 'Time Table',
          icon: Icons.table_chart,
          onTap: openTimeTable,
        ),
        ButtonWidget(
          buttonText: 'Academic Calendar',
          icon: Icons.calendar_month,
          onTap: openAcademicCalendar,
        ),
        ButtonWidget(
          buttonText: 'Fee Summary',
          icon: Icons.currency_rupee,
          onTap: openFeeSummary,
        ),
        ButtonWidget(
          buttonText: 'Fee Slips',
          icon: Icons.receipt,
          onTap: openFeeSlips,
        ),
        ButtonWidget(
          buttonText: 'Photo Gallery',
          icon: Icons.photo_library,
          onTap: openPhotoGallery,
        ),

        // show schoolexpert page to all
      ],
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final String buttonText;
  final IconData icon;
  final Function onTap;
  final int count;
  const ButtonWidget({
    super.key,
    required this.buttonText,
    required this.icon,
    required this.onTap,
    this.count = 0,
  });

  @override
  Widget build(context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        height: 60.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple,
                Colors.blue, // Dodger Blue
              ],
              stops: [0.0, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              tileMode: TileMode.clamp,
            ),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          //decoration: AppConfig.boxDecoration(),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
            ),
            onPressed: () => onTap(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Colors.white, Colors.amber, Colors.white70],
                      stops: [0.0, 0.5, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.clamp,
                    ).createShader(bounds);
                  },
                  child: Stack(
                    children: [
                      Icon(
                        icon,
                        size: 45,
                        //color: Color.fromARGB(255, 103, 98, 98),
                      ),
                      if (count > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 10,
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                Flexible(
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.yellow,
                          ],
                          stops: [0.0, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          tileMode: TileMode.clamp,
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
