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

import '../example_server.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  CourierPushListener? _pushListener;

  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future _start() async {


    try {
      setState(() {
        _isLoading = true;
      });

      final userId = await Courier.shared.userId;
      print(userId);

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

      final token = await ExampleServer.generateJwt(
          authKey: Env.authKey,
          userId: courierUserId
      );

      await Courier.shared.signIn(
        accessToken: token,
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_currentUserId != null ? 'Current user id: ${_currentUserId!}' : 'No user found'),
          Container(height: 16.0),
          ElevatedButton(
            child: _currentUserId != null ? const Text('Sign Out') : const Text('Sign In'),
            onPressed: () => _currentUserId != null ? _signOut() : _signIn(),
          ),
        ],
      ),
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
    _pushListener?.remove();
  }
}
