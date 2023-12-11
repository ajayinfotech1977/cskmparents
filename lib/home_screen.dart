import 'dart:async';
import 'package:cskmparents/app_config.dart';
import 'package:cskmparents/home_screen_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';
import 'package:cskmparents/notifications_sreen.dart';
import 'package:cskmparents/custom_data_stream.dart';

StreamController<CustomData> streamController =
    StreamController<CustomData>.broadcast();

enum MenuItem {
  logout,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _globalst_name = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateGlobalst_name();

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

  // Future<void> _loadGlobalSt_Name() async {
  //   setState(() {
  //     _globalst_name = AppConfig.globalst_name;
  //     print('Global student name is $_globalst_name');
  //   });
  // }

  void updateGlobalst_name() {
    setState(() {
      _globalst_name = AppConfig.globalst_name;
    });
  }

  //execute the _loadGlobalSt_Name() function whenevver there is a change in
  // AppConfig.globalst_name

  // Future<String> fetchEmpName() async {
  @override
  Widget build(BuildContext context) {
    // return StreamBuilder(
    //     stream: Stream.fromFuture(fetchEmpName()),
    //     builder: (ctx, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const SpalshScreen();
    //       } else {
    //         ename = snapshot.data!;
    //       }
    return Scaffold(
      appBar: AppBar(
        title: Text(_globalst_name),
        actions: <Widget>[
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (AppConfig.globalnotificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 7,
                      child: Text(
                        AppConfig.globalnotificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(
                    stream: streamController,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<MenuItem>(
              onSelected: (logout) async {
                AppConfig.logout();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              },
              itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: MenuItem.logout,
                      child: Text('Logout'),
                    )
                  ])
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 125,
            margin: EdgeInsets.all(8), // Add margin for spacing
            child: StudentsList(
              globalstNameNotifier: updateGlobalst_name,
            ),
          ),
          Expanded(child: HomeScreenButtons()),
        ],
      ),
    );
    //});
  }
}

class StudentsList extends StatefulWidget {
  final Function globalstNameNotifier;
  StudentsList({
    Key? key,
    required this.globalstNameNotifier,
  }) : super(key: key);

  @override
  _StudentsListState createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  List<Student> students = <Student>[];
  late SharedPreferences _prefs;
  PageController _pageController =
      PageController(initialPage: AppConfig.globalsno - 1);
  int currentPage = AppConfig.globalsno - 1;
  bool hasCodeExecuted = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();

    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
      });
    });
    AppConfig().initDeviceInfo();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      students = Student.decode(_prefs.getString('students')!);
      //print(students.length.toString() + ' students found');
    });
  }

  Future<void> _updateGlobalAdmNo(String adm_no) async {
    await AppConfig.changeActiveStudent(adm_no);
    setState(() {
      EasyLoading.showInfo(
          'Now the active child is ${AppConfig.globalst_name}');
      widget.globalstNameNotifier();
      // call the function _loadGlobalst_name() to update the _globalst_name
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!hasCodeExecuted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        // scroll to the current student
        _pageController.animateToPage(
          AppConfig.globalsno - 1,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          hasCodeExecuted = true;
        });
      });
    }
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: students.length,
            onPageChanged: (index) {
              _updateGlobalAdmNo(students[index].adm_no);
            },
            itemBuilder: (context, index) {
              final student = students[index];
              final isSelected = student.adm_no == AppConfig.globaladm_no;

              return Card(
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: Colors.grey,
                            width: 2,
                          ),
                    // box shadow for the card
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              Colors.pink,
                              Colors.purple,
                              Colors.deepPurple
                            ], // Customize the colors
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null, // No gradient for unselected items
                  ),
                  // add a border to the card

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://www.cskm.com/schoolexpert/attached/${student.stImageName}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      SizedBox(
                          width: 10), // Add spacing between leading and text
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.st_name,
                              style: isSelected
                                  ? TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )
                                  : TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                            ),
                            Text(
                              'School No: ${student.adm_no}',
                              style: isSelected
                                  ? TextStyle(color: Colors.white)
                                  : null,
                            ),
                            Text(
                              'Class: ${student.st_class} - ${student.st_section}',
                              style: isSelected
                                  ? TextStyle(color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      Spacer(), // Expands to fill available space
                      IconButton(
                        icon: Icon(
                          isSelected
                              ? Icons.check_circle_outline
                              : Icons.circle_outlined,
                        ),
                        color: isSelected ? Colors.white : null,
                        onPressed: () {
                          _updateGlobalAdmNo(student.adm_no);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (students.length > 1) SizedBox(height: 10),
        if (students.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              students.length,
              (index) {
                return Container(
                  width: 10,
                  height: 10,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == currentPage ? Colors.blue : Colors.grey,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
