import 'dart:async';
import 'package:cskmparents/app_config.dart';
import 'package:flutter/material.dart';
import 'package:cskmparents/messaging/api_service.dart';
import 'package:cskmparents/messaging/model/teachers_model.dart';
import 'package:cskmparents/messaging/model/message_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

String adm_no = AppConfig.globaladm_no;
StreamController<bool> streamController = StreamController<bool>.broadcast();

class ChatScreen extends StatefulWidget {
  final TeacherModel teacher;

  ChatScreen({required this.teacher, required this.stream});
  final StreamController<bool> stream;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _textEditingController = TextEditingController();
  final List<MessageModel> _messages = [];
  // Define a ScrollController
  final ScrollController _scrollController = ScrollController();
  bool sendMessageClicked = false;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  @override
  void dispose() {
    if (!mounted) {
      widget.stream.close();
    }
    super.dispose();
  }

  void messagePolling() async {
    // Delay execution for 30 seconds
    await Future.delayed(Duration(seconds: 30));

    while (true) {
      await apiService.syncMessages();
      final messagesNew =
          await apiService.getMessages(adm_no, widget.teacher.userno);

      // Compare _messages with messagesNew and add new messages
      final List<MessageModel> newMessages = messagesNew
          .where((newMessage) => !_messages.any((existingMessage) =>
              newMessage.dateTime == existingMessage.dateTime &&
              newMessage.message == existingMessage.message))
          .toList();
      //print("newMessages= $newMessages");
      // Add new messages to the stream
      if (newMessages.isNotEmpty) {
        if (mounted) {
          setState(() {
            // Update the messages list with new messages
            _messages.addAll(newMessages);
          });
        }
      }
      // Delay execution for the next 30 seconds
      await Future.delayed(Duration(seconds: 30));
    }
  }

  Future<void> fetchMessages() async {
    try {
      EasyLoading.show(status: 'Loading...');
      final messages =
          await apiService.getMessages(adm_no, widget.teacher.userno);
      EasyLoading.dismiss();
      if (mounted) {
        setState(() {
          _messages.addAll(messages);
          widget.teacher.noOfUnreadMessages = 0;
          //update the TeachersListScreen widget
          widget.stream.add(true);
        });
        messagePolling();
      }
    } catch (e) {
      print(e.toString());
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to load messages. Please try again.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> sendMessage() async {
    // when user clicks on send button
    setState(() {
      sendMessageClicked = true;
    });
    //close the keypad
    FocusScope.of(context).unfocus();
    final String message = _textEditingController.text.trim();
    if (message.isNotEmpty) {
      try {
        await apiService.sendMessage(adm_no, widget.teacher.userno, message);
        _textEditingController.clear();
        // Update the messages list with the new message
        setState(() {
          _messages.add(MessageModel(
            fromNo: adm_no,
            toNo: widget.teacher.userno,
            message: message,
            dateTime: DateTime.now(),
          ));
        });
      } catch (e) {
        if (this.mounted) {
          setState(() {
            _textEditingController.text = message;
            sendMessageClicked = false;
          });
        }
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to send message. Please try again.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
    //again show the send button
    setState(() {
      sendMessageClicked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // After the ListView.builder is built, scroll to the bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teacher.ename),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image4.jpg', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller:
                        _scrollController, // Assign the ScrollController
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final previousMessage =
                          index > 0 ? _messages[index - 1] : null;
                      final bool isSameDay = previousMessage != null &&
                          message.dateTime.year ==
                              previousMessage.dateTime.year &&
                          message.dateTime.month ==
                              previousMessage.dateTime.month &&
                          message.dateTime.day == previousMessage.dateTime.day;
                      return Column(
                        children: [
                          if (!isSameDay) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(message.dateTime),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 86, 86, 86),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                          ],
                          Row(
                            mainAxisAlignment: message.fromNo == adm_no
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: message.fromNo == adm_no
                                      ? Colors.blue
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.0),
                                    topRight: Radius.circular(12.0),
                                    bottomLeft: Radius.circular(
                                        message.fromNo == adm_no ? 12.0 : 0.0),
                                    bottomRight: Radius.circular(
                                        message.fromNo == adm_no ? 0.0 : 12.0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.message,
                                      softWrap: true,
                                      maxLines: null,
                                      style: TextStyle(
                                        color: message.fromNo == adm_no
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      DateFormat('HH:mm')
                                          .format(message.dateTime),
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: message.fromNo == adm_no
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.black.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                        ],
                      );
                    },
                  ),
                ),
                //create a gap of 8 pixels
                SizedBox(height: 15.0),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  //padding: EdgeInsets.symmetric(horizontal: 3.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5.0,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            hintText: 'Message...',
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 8.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        child: sendMessageClicked
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 169, 0, 0)),
                              )
                            : IconButton(
                                icon: Icon(Icons.send),
                                color: Colors.white,
                                onPressed: sendMessage,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TeachersListScreen extends StatefulWidget {
  @override
  _TeachersListScreenState createState() => _TeachersListScreenState();
}

class _TeachersListScreenState extends State<TeachersListScreen> {
  late Future<List<TeacherModel>> _teachersFuture;
  final ApiService apiService = ApiService();
  TextEditingController _searchController = TextEditingController();
  List<TeacherModel> filteredTeachers = [];
  AsyncSnapshot<List<TeacherModel>>? snapshotData;

  @override
  void initState() {
    super.initState();

    _teachersFuture = apiService.getTeachers(adm_no);
    //updateSearchResults('');

    streamController.stream.listen((shouldUpdate) {
      if (mounted) {
        if (shouldUpdate) {
          setState(() {
            // Update the necessary data or re-fetch the updated data
            _teachersFuture = apiService.getTeachers(adm_no);
          });
        }
      }
    });

    // Initialize filteredStudents with snapshot data
    _teachersFuture.then((teachers) {
      setState(() {
        filteredTeachers = teachers;
      });
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (!mounted) {
      streamController.close();
    }
    super.dispose();
  }

  void _openChatScreen(TeacherModel teacher) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          teacher: teacher,
          stream: streamController,
        ),
      ),
    );
  }

  void updateSearchResults(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTeachers = snapshotData?.data ?? [];
      } else {
        filteredTeachers = snapshotData?.data
                ?.where((teacher) =>
                    teacher.ename.toLowerCase().contains(query.toLowerCase()))
                .toList() ??
            [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close keypad when user taps outside of the search box
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                updateSearchResults(value);
              },
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                //create a circular border around search bar
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TeacherModel>>(
              future: _teachersFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  snapshotData = AsyncSnapshot<List<TeacherModel>>.withData(
                    ConnectionState.done,
                    snapshot.data!,
                  );
                  //filteredStudents = snapshot.data!;
                  return ListView.builder(
                    itemCount: filteredTeachers.length,
                    itemBuilder: (context, index) {
                      final teacher = filteredTeachers[index];
                      return ListTile(
                        title: Text(
                          teacher.ename,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: teacher.isAppInstalled
                                ? Colors.black
                                : Colors.red,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${teacher.designation}',
                            ),
                            Divider(),
                          ],
                        ),
                        trailing: teacher.noOfUnreadMessages > 0
                            ? CircleAvatar(
                                radius: 10.0,
                                backgroundColor: Colors.red,
                                child: Text(
                                  teacher.noOfUnreadMessages.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () => teacher.isAppInstalled
                            ? _openChatScreen(teacher)
                            : showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Error'),
                                  content: Text(
                                      '${teacher.ename} is not on the smart messaging app. Please ask the teacher to install the app.'),
                                  actions: [
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load students'));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
