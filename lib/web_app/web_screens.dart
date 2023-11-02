//import all the required packages
import 'package:flutter/material.dart';
import 'package:cskmparents/web_app/web_view_app.dart';

// create a new marks entry screen with scaffold and appbar with title Marks
// Entry and a body with a widget MarksEntryForm

class ViewParentLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Web Login',
      url: 'https://www.cskm.com/schoolexpert/parentlogin/login-v2.asp',
      backButton: false,
    );
  }
}

class ViewProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Profile',
      url:
          'https://www.cskm.com/schoolexpert/parentlogin/login-v2.asp?pg=profile&f=app',
      backButton: false,
    );
  }
}

// view marks class
class ViewMarks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Marks',
      url:
          'https://www.cskm.com/schoolexpert/parentlogin/login-v2.asp?pg=viewmarks&f=app',
      backButton: false,
    );
  }
}

// view report card
class ViewReportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Report Card',
      url: 'https://www.cskm.com/schoolexpert/myRC.asp',
      backButton: true,
    );
  }
}

// view attendance
class ViewAttendance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Attendance',
      url:
          'https://www.cskm.com/schoolexpert/parentlogin/login-v2.asp?pg=attendance&f=app',
      backButton: false,
    );
  }
}

// view result analysis
class ViewResultAnalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Result Analysis',
      url:
          'https://www.cskm.com/schoolexpert/parentlogin/login-v2.asp?pg=resultanalysis&f=app',
      backButton: false,
    );
  }
}

// view time table
class ViewTimeTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Time Table',
      url:
          'https://www.cskm.com/schoolexpert/parentlogin/login-v2.asp?pg=timetable&f=app',
      backButton: false,
    );
  }
}

// view academic calendar
class ViewAcademicCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Academic Calendar',
      url:
          'https://www.cskm.com/schoolexpert/parentlogin/login-v2.asp?pg=academiccalendar&f=app',
      backButton: false,
    );
  }
}

// view fee summary
class ViewFeeSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Fee Summary',
      url:
          'https://www.cskm.com/schoolexpert/parentlogin/login-v2.asp?pg=feesummary&f=app',
      backButton: true,
    );
  }
}

// view fee slips
class ViewFeeSlips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Fee Slips',
      url:
          'https://www.cskm.com/schoolexpert/parentlogin/login-v2.asp?pg=feeslips&f=app',
      backButton: true,
    );
  }
}

// view photo gallery
// class ViewPhotoGallery extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return WebViewApp(
//       title: 'Photo Gallery',
//       url:
//           'https://www.cskm.com/schoolexpert/parentlogin/login-v2.asp?pg=photogallery&f=app',
//       backButton: false,
//     );
//   }
// }

class ViewPhotoGallery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebViewApp(
      title: 'Photo Gallery',
      url:
          'https://www.cskm.com/schoolexpert/parentlogin/login-v2.asp?pg=photogallery&f=app',
      backButton: false,
    );
  }
}
