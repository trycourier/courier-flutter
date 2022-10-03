import 'package:courier_flutter/courier_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:courier_flutter/courier_flutter.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Must be called before you can use the Courier Flutter SDK
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String _message = 'Unknown';

  @override
  void initState() {
    super.initState();

    if (!mounted) {
      return;
    }

    _initCourier();

  }

  Future<void> _initCourier() async {

    try {

      final id = await Courier.shared.userId;
      print(id);

      await Courier.shared.setIsDebugging(false);
      print(Courier.shared.isDebugging);

      final status = await Courier.shared.getNotificationPermissionStatus();
      print(status);

      final test = await Courier.shared.requestNotificationPermission();
      print(test);

      // Listen to push notification events
      Courier.shared.onPushNotificationDelivered = (message) {
        print(message);
        setState(() {
          _message = 'Delivered \n ${message.toString()}';
        });
      };

      Courier.shared.onPushNotificationClicked = (message) {
        print(message);
        setState(() {
          _message = 'Clicked \n ${message.toString()}';
        });
      };

      await Courier.shared.signIn(
          accessToken: myApiKey,
          userId: myUserId
      );

      final fcmToken = await Courier.shared.fcmToken;
      final userId = await Courier.shared.userId;
      print('$fcmToken :: $userId');

      final requestId = await Courier.shared.sendPush(
          authKey: myApiKey,
          userId: userId ?? '',
          title: 'Sent from flutter',
          body: 'To you! <3',
          isProduction: false,
          // providers: [CourierProvider.apns, CourierProvider.fcm],
          providers: [CourierProvider.apns],
      );
      print(requestId);

      // await Courier.shared.signOut();

    } catch (e) {

      print(e);

    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Courier example app'),
        ),
        body: Center(
          child: Text(_message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
