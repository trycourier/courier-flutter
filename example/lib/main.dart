import 'package:courier_flutter/courier_provider.dart';
import 'package:courier_flutter/ios_foreground_notification_presentation_options.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter_sample/env.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:courier_flutter/courier_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Listen to push notification events
  // You likely want these callbacks to be handled
  // at a similar "global" level
  Courier.shared.onPushNotificationDelivered = (push) {
    print(push);
    pushDelivered.add(push);
  };

  // This is a good point to check your users authentication
  // or do any other logic needed before your users take action
  // on the notification
  Courier.shared.onPushNotificationClicked = (push) {
    print(push);
    pushClicked.add(push);
  };

  // This is needed to handle FCM tokens
  await Firebase.initializeApp();

  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// These streams are used to simply pass the data to the current UI
// Your implementation will likely be different
StreamController<dynamic> pushDelivered = StreamController<dynamic>();
StreamController<dynamic> pushClicked = StreamController<dynamic>();

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  String? _currentUserId;
  final List<CourierProvider> _providers = [CourierProvider.apns, CourierProvider.fcm];

  @override
  void initState() {
    super.initState();

    if (!mounted) {
      return;
    }

    _registerAlertStreams();
    _start();
  }

  _registerAlertStreams() {
    // These exist to simply show the message
    // Your implementation will be different
    pushDelivered.stream.listen((push) {
      _showAlert(context, 'Push Delivered', push.toString());
    });

    pushClicked.stream.listen((push) {
      _showAlert(context, 'Push Clicked', push.toString());
    });
  }

  Future _start() async {
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

      final userId = await Courier.shared.userId;
      print(userId);

      final fetchStatus = await Courier.shared.getNotificationPermissionStatus();
      print(fetchStatus);

      final requestStatus = await Courier.shared.requestNotificationPermission();
      print(requestStatus);

      int limit = await Courier.shared.setInboxPaginationLimit(limit: 100);
      print(limit);

      CourierInboxListener listener = await Courier.shared.addInboxListener(
        () {
          print("Inbox loading");
        },
        (error) {
          print(error);
        },
        (messages, totalMessageCount, unreadMessageCount, canPaginate) {

          print(messages.length);
          print(totalMessageCount);
          print(unreadMessageCount);
          print(canPaginate);

          if (canPaginate) {
            Courier.shared.fetchNextPageOfMessages();
          }

        }
      );

      print(listener);

      setState(() {
        _currentUserId = userId;
      });

      // // Set the current FCM token
      // // Android will automatically handle this, but iOS will not
      // final fcmToken = await FirebaseMessaging.instance.getToken();
      // if (fcmToken != null) {
      //   await Courier.shared.setFcmToken(token: fcmToken);
      // }
      //
      // // Handle FCM token changes
      // FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      //   Courier.shared.setFcmToken(token: fcmToken);
      // }).onError((err) {
      //   throw err;
      // });
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

  _getFcmToken(BuildContext context) async {
    final token = await Courier.shared.fcmToken;
    print(token);
    _showAlert(context, 'FCM Token', token ?? 'No token set');
  }

  _getApnsToken(BuildContext context) async {
    final token = await Courier.shared.apnsToken;
    print(token);
    _showAlert(context, 'APNS Token', token ?? 'No token set');
  }

  _handleProviderSwitch(CourierProvider selectedProvider) {
    if (_providers.contains(selectedProvider)) {
      setState(() {
        _providers.removeWhere((provider) => provider == selectedProvider);
      });
    } else {
      setState(() {
        _providers.add(selectedProvider);
      });
    }
  }

  // Future _sendPush() async {
  //   if (_providers.isEmpty) {
  //     return;
  //   }
  //
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     final userId = await Courier.shared.userId ?? '';
  //
  //     final requestId = await Courier.shared.sendPush(
  //       authKey: Env.authKey,
  //       userId: userId,
  //       title: 'Hey $userId',
  //       body: 'Push sent from: ${_providers.map((e) => e.name).join(' & ')}',
  //       providers: _providers,
  //     );
  //
  //     print(requestId);
  //   } catch (e) {
  //     print(e);
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_currentUserId != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Current user id: ${_currentUserId!}'),
          TextButton(
            child: const Text('Sign Out'),
            onPressed: () => _signOut(),
          ),
          const Divider(),
          SwitchListTile(
            value: _providers.contains(CourierProvider.apns),
            onChanged: (bool value) {
              _handleProviderSwitch(CourierProvider.apns);
            },
            title: Text(
              CourierProvider.apns.name.toUpperCase(),
            ),
          ),
          SwitchListTile(
            value: _providers.contains(CourierProvider.fcm),
            onChanged: (bool value) {
              _handleProviderSwitch(CourierProvider.fcm);
            },
            title: Text(
              CourierProvider.fcm.name.toUpperCase(),
            ),
          ),
          // TextButton(
          //   onPressed: () => _sendPush(),
          //   child: const Text('Send Push'),
          // ),
          const Divider(),
          TextButton(
            child: const Text('See FCM Token'),
            onPressed: () => _getFcmToken(context),
          ),
          TextButton(
            child: const Text('See APNS Token'),
            onPressed: () => _getApnsToken(context),
          ),
        ],
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
        const Divider(),
        TextButton(
          child: const Text('See FCM Token'),
          onPressed: () => _getFcmToken(context),
        ),
        TextButton(
          child: const Text('See APNS Token'),
          onPressed: () => _getApnsToken(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courier example app'),
      ),
      body: _buildContent(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    pushDelivered.close();
    pushClicked.close();
  }
}
