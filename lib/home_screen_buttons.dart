import 'package:cskmparents/app_config.dart';
import 'package:flutter/material.dart';

class HomeScreenButtons extends StatefulWidget {
  const HomeScreenButtons({super.key});

  @override
  State<HomeScreenButtons> createState() => _HomeScreenButtonsState();
}

class _HomeScreenButtonsState extends State<HomeScreenButtons> {
  bool classTeacher = false;
  //code to store classTeacher in SharedPreferences to the global variable classTeacher

  //code to fetch classTeacher from SharedPreferences

  void openMessages(context) {
    Navigator.pushNamed(context, '/messagetabbedscreen');
  }

  void openSchoolExpert(context) {
    Navigator.pushNamed(context, '/parentlogin');
  }

  void openNotifications(context) {
    Navigator.pushNamed(context, '/notifications');
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
        height: 20.0,
        child: DecoratedBox(
          decoration: AppConfig.boxDecoration(),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(0, 0, 0, 0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Colors.grey[400]!, Colors.amber],
                      stops: [0.0, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.clamp,
                    ).createShader(bounds);
                  },
                  child: Stack(
                    children: [
                      Icon(
                        icon,
                        size: 20,
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
                SizedBox(height: 8.0),
                Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          Color.fromARGB(255, 249, 249, 249),
                          Colors.amber
                        ],
                        stops: [0.0, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        tileMode: TileMode.clamp,
                      ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Text(
            //   buttonText,
            //   style: AppConfig.normalWhite15(),
            // ),
            //icon: Icon(icon, size: 40),
            onPressed: () => onTap(context),
          ),
        ),
      ),
    );
  }
}
