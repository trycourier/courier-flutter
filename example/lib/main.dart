import 'firebase_options.dart';
import 'package:courier_flutter/courier_provider.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/courier_push_listener.dart';
import 'package:courier_flutter_sample/pages/auth.dart';
import 'package:courier_flutter_sample/pages/inbox.dart';
import 'package:courier_flutter_sample/pages/prefs.dart';
import 'package:courier_flutter_sample/pages/push.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:courier_flutter/courier_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This is needed to handle FCM tokens
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.pink,
        // TODO: Add more theme colors here if you would like Inbox to automatically inherit styles
      ),
      home: const MyApp(),
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
  late CourierPushListener _pushListener;

  int _unreadMessageCount = 0;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future _start() async {
    _inboxListener = await Courier.shared.addInboxListener(onMessagesChanged: (messages, unreadMessageCount, totalMessageCount, canPaginate) {
      setState(() {
        _unreadMessageCount = unreadMessageCount;
      });
    });

    _pushListener = Courier.shared.addPushListener(
      onPushClicked: (push) {
        showAlert(context, 'Push Clicked', push.toString());
      },
      onPushDelivered: (push) {
        showAlert(context, 'Push Delivered', push.toString());
      },
    );

    try {
      final token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        Courier.shared.setTokenForProvider(provider: CourierPushProvider.firebaseFcm, token: token);
      }
    } catch (e) {
      print(e);
    }

    // Listener to firebase token change
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      Courier.shared.setTokenForProvider(provider: CourierPushProvider.firebaseFcm, token: fcmToken);
    }).onError((error) {
      print(error);
    });
  }

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
        page: const PushPage(),
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
        page: const PrefsPage(),
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
    _pushListener.remove();
    _inboxListener.remove();
  }
}

showAlert(BuildContext context, String title, String body) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Text(body),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Ok'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    ),
  );
}
