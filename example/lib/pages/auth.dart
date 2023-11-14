import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/courier_preference_status.dart';
import 'package:courier_flutter/courier_provider.dart';
import 'package:courier_flutter/ios_foreground_notification_presentation_options.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/courier_push_listener.dart';
import 'package:courier_flutter_sample/env.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:courier_flutter/courier_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late CourierPushListener _pushListener;

  bool _isLoading = true;
  String? _currentUserId;
  List<InboxMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    if (!mounted) {
      return;
    }

    _start();
  }

  Future _start() async {

    _pushListener = Courier.shared.addPushListener(

      // Listen to push notification events
      // You likely want these callbacks to be handled
      // at a similar "global" level
      onPushDelivered: (push) {
        _showAlert(context, 'Push Delivered', push.toString());
      },

      // This is a good point to check your users authentication
      // or do any other logic needed before your users take action
      // on the notification
      onPushClicked: (push) {
        _showAlert(context, 'Push Clicked', push.toString());
      }

    );

    try {
      setState(() {
        _isLoading = true;
      });

      Courier.shared.isDebugging = true;
      print(Courier.shared.isDebugging);

      Courier.shared.iOSForegroundNotificationPresentationOptions = [
        iOSNotificationPresentationOption.banner,
        iOSNotificationPresentationOption.sound,
        iOSNotificationPresentationOption.list,
        iOSNotificationPresentationOption.badge,
      ];
      print(Courier.shared.iOSForegroundNotificationPresentationOptions);

      // try {
      //   // Set the current FCM token
      //   // Android will automatically handle this, but iOS will not
      //   final fcmToken = await FirebaseMessaging.instance.getToken();
      //   if (fcmToken != null) {
      //     await Courier.shared.setTokenForProvider(provider: CourierPushProvider.firebaseFcm, token: fcmToken);
      //     final token = await Courier.shared.getTokenForProvider(provider: CourierPushProvider.firebaseFcm);
      //     print(token);
      //   }
      // } catch (e) {
      //   print(e);
      // }
      //
      // // Handle FCM token changes
      // FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      //   Courier.shared.setTokenForProvider(provider: CourierPushProvider.firebaseFcm, token: fcmToken);
      // }).onError((err) {
      //   throw err;
      // });

      final userId = await Courier.shared.userId;
      print(userId);

      final fetchStatus = await Courier.shared.getNotificationPermissionStatus();
      print(fetchStatus);

      final requestStatus = await Courier.shared.requestNotificationPermission();
      print(requestStatus);

      // Headless Inbox 👇

      int limit = await Courier.shared.setInboxPaginationLimit(limit: 100);
      print(limit);

      // _inboxListener = await Courier.shared.addInboxListener(
      //   onInitialLoad: () {
      //     print("Inbox loading");
      //   }, onError: (error) {
      //     print(error);
      //   },
      //   onMessagesChanged: (messages, totalMessageCount, unreadMessageCount, canPaginate) async {
      //     print(messages);
      //     print(totalMessageCount);
      //     print(unreadMessageCount);
      //     print(canPaginate);
      //
      //     setState(() {
      //       _messages = messages;
      //     });
      //
      //     // Pagination
      //     if (canPaginate) {
      //       Courier.shared.fetchNextPageOfMessages();
      //     }
      //
      //     // Reading / Unreading
      //     // String messageId = messages.first.messageId;
      //     // await Courier.shared.unreadMessage(id: messageId);
      //     // await Courier.shared.readMessage(id: messageId);
      //     // await Courier.shared.readAllInboxMessages();
      //  }
      // );

      // Preferences 👇

      final preferences = await Courier.shared.getUserPreferences();
      print(preferences);

      // final topic = await Courier.shared.getUserPreferencesTopic(topicId: '74RT1WNNQAM0SFJR59THWCDACCEV');
      // print(topic);
      //
      // await Courier.shared.putUserPreferencesTopic(
      //     topicId: '74RT1WNNQAM0SFJR59THWCDACCEV',
      //     status: CourierUserPreferencesStatus.optedIn,
      //     hasCustomRouting: true,
      //     customRouting: [CourierUserPreferencesChannel.push]
      // );

      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  _signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final courierUserId = await _showUserIdAlert();
      if (courierUserId.isEmpty) return;

      await Courier.shared.signIn(
        accessToken: Env.accessToken,
        clientKey: Env.clientKey,
        userId: courierUserId,
      );

      final userId = await Courier.shared.userId;
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  _signOut() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await Courier.shared.signOut();
      final userId = await Courier.shared.userId;
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_currentUserId != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current user id: ${_currentUserId!}'),
            TextButton(
              child: const Text('Sign Out'),
              onPressed: () => _signOut(),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('No user signed into Courier'),
        TextButton(
          child: const Text('Sign In'),
          onPressed: () => _signIn(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth'),
      ),
      body: _buildContent(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pushListener.remove();
  }
}
