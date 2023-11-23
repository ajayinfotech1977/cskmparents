import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cskmparents/messaging/chat_screen.dart';
import 'package:cskmparents/custom_data_stream.dart';
//import 'package:cskmparents/messaging/broadcastscreen.dart';

class MessageTabbedScreen extends StatefulWidget {
  final StreamController<CustomData> stream;
  MessageTabbedScreen({required this.stream});
  @override
  _MessageTabbedScreenState createState() => _MessageTabbedScreenState();
}

class _MessageTabbedScreenState extends State<MessageTabbedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CSKM Smart Messaging'),
        // bottom: TabBar(
        //   controller: _tabController,
        //   tabs: [
        //     Tab(text: 'Teachers and Staff'),
        //   ],
        // ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return MessageForm(
      //             //onSave: (Message) {
      //             //Messages.add(Message);
      //             //},
      //             );
      //       },
      //     );
      //   },
      //   child: Icon(Icons.add),
      // ),
      body: Center(
        child: Container(
          height: double.infinity,
          child: Center(
            child: TeachersListScreen(streamReadMessages: widget.stream),
          ),
        ),
      ),
    );
  }
}
