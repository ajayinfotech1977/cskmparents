import 'dart:async';
import 'package:cskmparents/messaging/api_service.dart';
import 'package:cskmparents/mobile_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cskmparents/home_screen.dart';
import 'package:cskmparents/login_screen.dart';
import 'package:cskmparents/app_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cskmparents/firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cskmparents/web_app/web_screens.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cskmparents/photogallery_screen.dart';
import 'dart:io';
import 'package:upgrader/upgrader.dart';

// TODO: Add stream controller
import 'package:rxdart/rxdart.dart';

// used to pass messages from event handler to the UI
final _messageStreamController = BehaviorSubject<RemoteMessage>();
//const kDebugMode = true;

//Notification configuration
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// TODO: Define the background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  String title = message.notification?.title as String;
  String msg = message.notification?.body as String;
  showNotification(title, msg);

  // if (kDebugMode) {
  //   print("Handling a background message: ${message.messageId}");
  //   print('Message data: ${message.data}');
  //   print('Message notification: ${message.notification?.title}');
  //   print('Message notification: ${message.notification?.body}');
  // }
}

void main() {
  initializeFirebase();
  AppConfig.setGlobalVariables();
  runApp(MyApp());
}

void initializeFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // TODO: Request permission
  final messaging = FirebaseMessaging.instance;

  //final settings =
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  //print('Permission granted: ${settings.authorizationStatus}');

  // TODO: Register with FCM
  // It requests a registration token for sending messages to users from your App server or other trusted server environment.
  String? token = await messaging.getToken() as String;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('deviceToken', token);

  //print('Registration Token=$token');

  // TODO: Set up foreground message handler
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    String title = message.notification?.title as String;
    String msg = message.notification?.body as String;
    var data = message.data;
    if (data.isNotEmpty) {
      if (data.containsKey('notificationType')) {
        String dataValue = data['notificationType'];
        if (dataValue == 'Notification' &&
            AppConfig.isNotificationScreenActive) {
          AppConfig.isNewNotification = true;
        } else if (dataValue == 'Message' && AppConfig.isChatScreenActive) {
          AppConfig.isNewMessage = true;
        } else {
          showNotification(title, msg);
          if (dataValue == 'Message') {
            ApiService().syncMessages();
          }
        }
      }
    }

    /**********For Reading the data and using it uncomment below lines */
    // var data = message.data;
    // if (data.isNotEmpty) {
    //   print(data);
    //   if (data.containsKey('msgtype')) {
    //     String dataValue = message.data['msgtype'];
    //     // Process the data as needed
    //     print('Received data from PHP: $dataValue');
    //   }
    // }
    // print('isChatScreenActive=${AppConfig.isChatScreenActive}');
    // print('isNotificationScreenActive=${AppConfig.isNotificationScreenActive}');

    // if (kDebugMode) {
    //   print('Handling a foreground message: ${message.messageId}');
    //   print('Message data: ${message.data}');
    //   print('Message notification: ${message.notification?.title}');
    //   print('Message notification: ${message.notification?.body}');
    // }

    _messageStreamController.sink.add(message);
  });

  //TODO: Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize the FlutterLocalNotificationsPlugin
  await initializeNotifications();
}

//intialize notifications
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Replace with your app icon name

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
          onDidReceiveLocalNotification:
              (int id, String? title, String? body, String? payload) async {});

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {});
}

//show notification
Future<void> showNotification(String title, String message) async {
  String longdata = message;

  BigTextStyleInformation bigTextStyleInformation =
      BigTextStyleInformation(longdata); //multi-line show style

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'cskmparents', // Replace with your own channel ID
    'CSKM Parents APP', // Replace with your own channel name
    channelDescription:
        'Show all pending tasks to the user', // Replace with your own channel description
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    enableVibration: true,
    styleInformation: bigTextStyleInformation,
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
  );
  NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: DarwinNotificationDetails(),
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    message,
    platformChannelSpecifics,
    payload: '/home', // The route to navigate when notification is clicked
  );
}

/// *****************************************************************
/// Actual Code for displaying the first
/// screen of the app starts from here
/// *****************************************************************

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /*************************************************************
   * Code for autoupdate of android app
   * Done on 05-June-2023
   * ***********************************************************/
  AppUpdateInfo? _updateInfo;
  //bool _flexibleUpdateAvailable = false;

  //GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  //bool _flexibleUpdateAvailable = false;

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      //setState(() {
      _updateInfo = info;
      //print('Update Availability: ${_updateInfo?.updateAvailability}');
      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        InAppUpdate.performImmediateUpdate().catchError((e) {
          //showSnack(e.toString());
          return AppUpdateResult.inAppUpdateFailed;
        });
      }
      //});
    }).catchError((e) {
      //print('Error Checking for update: $e');
      //showSnack(e.toString());
    });
  }

  // void showSnack(String text) {
  //   if (_scaffoldKey.currentContext != null) {
  //     ScaffoldMessenger.of(_scaffoldKey.currentContext!)
  //         .showSnackBar(SnackBar(content: Text(text)));
  //   }
  // }
  /*************Auto Update Code Completed *****************************/

  Future<String> checkLoginState() async {
    if (Platform.isAndroid) {
      //print('Android');
      //print('Checking for update');
      //Call checkForUpdate() to check and return if an update is available uncomment below line to activate this feature
      checkForUpdate();

      //print('Update checked');
      //if an update is available, immediately update it. uncomment below code
    }

    /******Auto update calling complete***************/
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //print("is username there: " + prefs.containsKey('username').toString());
    if (!await prefs.containsKey('username')) {
      return "invalid";
    }
    if (await prefs.containsKey('students')) {
      final String studentString = await prefs.getString('students').toString();
      final List<Student> students = Student.decode(studentString);
      // count the number of students in the list students
      var studentCount = students.length;
      if (studentCount > 5) {
        //print("more than one student");
        return "invalid";
      }

      //print("get values from  shared preferences...");
      var username = await prefs.getString('username');
      //print("username=" + username);
      var appConfig = AppConfig();
      var logginStateValue = appConfig.checkLogin(username: username);
      return logginStateValue;
    } else {
      return "invalid";
    }
  }

  @override
  void initState() {
    super.initState();
    AppConfig().initDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
      ),
      title: 'CSKM Public School Parents App',
      home: StreamBuilder(
        stream: Connectivity().onConnectivityChanged,
        builder:
            (BuildContext context, AsyncSnapshot<ConnectivityResult> snapshot) {
          final hasConnection =
              snapshot.hasData && snapshot.data != ConnectivityResult.none;
          if (hasConnection) {
            return StreamBuilder(
              stream: Stream.fromFuture(checkLoginState()),
              initialData: checkLoginState,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SplashScreenWidget();
                }
                if (snapshot.data == "valid") {
                  return const HomeScreen();
                } else if (snapshot.data == "invalid") {
                  AppConfig.logout();
                  return const LoginScreen();
                } else if (snapshot.data == "serverNotReachable") {
                  return NoWebsiteWidget();
                } else if (snapshot.data == "serverDown") {
                  return NoWebsiteWidget();
                } else {
                  return const LoginScreen();
                }
              },
            );
          } else {
            return NoInternetWidget();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => ViewProfile(),
        '/marks': (context) => ViewMarks(),
        '/reportcard': (context) => ViewReportCard(),
        '/attendance': (context) => ViewAttendance(),
        '/resultanalysis': (context) => ViewResultAnalysis(),
        '/timetable': (context) => ViewTimeTable(),
        '/academiccalendar': (context) => ViewAcademicCalendar(),
        '/feesummary': (context) => ViewFeeSummary(),
        '/feeslips': (context) => ViewFeeSlips(),
        '/photogallery': (context) => PhotoGalleryPage(),
        '/mobilelistscreen': (context) => MobileListScreen(),
      },
      builder: EasyLoading.init(),
    );
  }
}

class SpalshScreen extends StatefulWidget {
  const SpalshScreen({super.key});

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return const SplashScreenWidget();
  }
}

class SplashScreenWidget extends StatelessWidget {
  const SplashScreenWidget({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      body: Platform.isIOS
          ? UpgradeAlert(
              upgrader: Upgrader(dialogStyle: UpgradeDialogStyle.cupertino),
              child: SplashScreenContainerWidget(),
            )
          : SplashScreenContainerWidget(),
    );
  }
}

class SplashScreenContainerWidget extends StatelessWidget {
  const SplashScreenContainerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppConfig.boxDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/cskm-logo.png',
              width: 200,
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              "CSKM Public School",
              style: AppConfig.boldWhite30(),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Parents Login",
              style: TextStyle(
                fontSize: 30,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SpinKitFadingCircle(
              color: const Color.fromARGB(255, 250, 251, 253),
              size: 50.0,
            ),
            SizedBox(height: 16.0),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

class NoInternetWidget extends StatelessWidget {
  const NoInternetWidget({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      body: Container(
        decoration: AppConfig.boxDecoration(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/cskm-logo.png',
                width: 200,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                "CSKM Public School",
                style: AppConfig.boldWhite30(),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Parents Login",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // show error icon
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              SizedBox(height: 16.0),
              Text(
                'No Internet Connection!',
                style: AppConfig.normaYellow20(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoWebsiteWidget extends StatelessWidget {
  const NoWebsiteWidget({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      body: Container(
        decoration: AppConfig.boxDecoration(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/cskm-logo.png',
                width: 200,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                "CSKM Public School",
                style: AppConfig.boldWhite30(),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Parents Login",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // show error icon
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Server not reachable!\n1. Check your internet connection.\n2. Server might be unreachable.\n3. After rectifying the issue, please restart the app.',
                  style: AppConfig.normaYellow20(),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
