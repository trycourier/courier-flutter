import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/courier_preference_status.dart';
import 'package:courier_flutter/courier_provider.dart';
import 'package:courier_flutter/ios_foreground_notification_presentation_options.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/courier_push_listener.dart';
import 'package:courier_flutter_sample/env.dart';
import 'package:courier_flutter_sample/pages/auth.dart';
import 'package:courier_flutter_sample/pages/inbox.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:courier_flutter/courier_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This is needed to handle FCM tokens
  await Firebase.initializeApp();

  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class Tab {
  NavigationDestination tab;
  Widget page;

  Tab({
    required this.tab,
    required this.page,
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CourierInboxListener _inboxListener;
  int _unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();

    if (!mounted) {
      return;
    }

    _start();
  }

  Future _start() async {
    _inboxListener = await Courier.shared.addInboxListener(onMessagesChanged: (messages, unreadMessageCount, totalMessageCount, canPaginate) {
      setState(() {
        _unreadMessageCount = unreadMessageCount;
      });
    });
  }

  Future<String> _showUserIdAlert() async {
    final textController = TextEditingController();

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter User Id"),
        content: TextField(
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(hintText: "Courier User Id"),
          controller: textController,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Sign In"),
          ),
        ],
      ),
    );

    return Future.value(textController.text);
  }

  _showAlert(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            child: const Text('Ok'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  int _currentPageIndex = 0;

  List<Tab> _getTabs(int unreadCount) {
    return [
      Tab(
          tab: const NavigationDestination(
            selectedIcon: Icon(Icons.person_2_sharp),
            icon: Icon(Icons.person_2_outlined),
            label: 'Auth',
          ),
          page: const AuthPage()),
      Tab(
        tab: const NavigationDestination(
          selectedIcon: Icon(Icons.message_sharp),
          icon: Icon(Icons.message_outlined),
          label: 'Push',
        ),
        page: Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: const Text('Push'),
        ),
      ),
      Tab(
        tab: NavigationDestination(
          selectedIcon: unreadCount > 0 ? Badge(label: Text(unreadCount.toString()), child: const Icon(Icons.inbox_sharp)) : const Icon(Icons.inbox_sharp),
          icon: unreadCount > 0 ? Badge(label: Text(unreadCount.toString()), child: const Icon(Icons.inbox_outlined)) : const Icon(Icons.inbox_outlined),
          label: 'Inbox',
        ),
        page: const InboxPage(),
      ),
      Tab(
        tab: const NavigationDestination(
          selectedIcon: Icon(Icons.room_preferences_sharp),
          icon: Icon(Icons.room_preferences_outlined),
          label: 'Preferences',
        ),
        page: Container(
          color: Colors.yellow,
          alignment: Alignment.center,
          child: const Text('Preferences'),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getTabs(_unreadMessageCount).map((tab) => tab.page).toList()[_currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedIndex: _currentPageIndex,
        destinations: _getTabs(_unreadMessageCount).map((tab) => tab.tab).toList(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _inboxListener.remove();
  }
}
