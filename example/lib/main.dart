import 'package:flutter/material.dart';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/services.dart';
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
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    _initCourier();
  }

  Future<void> _initCourier() async {

    try {

      final test1 = await Courier.shared.userId;
      print(test1);

      await Courier.shared.signIn(
          accessToken: 'asdasd',
          userId: 'mike_user'
      );

      final test2 = await Courier.shared.userId;
      print(test2);

    } catch (e) {

      print(e);

    }

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
