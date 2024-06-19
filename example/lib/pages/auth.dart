import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/courier_preference_status.dart';
import 'package:courier_flutter/courier_provider.dart';
import 'package:courier_flutter/ios_foreground_notification_presentation_options.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/courier_push_listener.dart';
import 'package:courier_flutter_sample/env.dart';
import 'package:courier_flutter_sample/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:courier_flutter/courier_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
  String? _currentTenantId;

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

      final tenantId = await Courier.shared.tenantId;
      print(tenantId);

      setState(() {
        _currentUserId = userId;
        _currentTenantId = tenantId;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, String>> _showUserAlert() async {
    final userTextController = TextEditingController();
    final tenantTextController = TextEditingController();

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Enter User Details",
          style: AppTheme.title,
        ),
        content: Column(
          children: [
            TextField(
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              style: AppTheme.body,
              decoration: InputDecoration(
                labelText: "Courier User Id",
                labelStyle: AppTheme.title,
              ),
              controller: userTextController,
            ),
            TextField(
              autofocus: false,
              autocorrect: false,
              enableSuggestions: false,
              style: AppTheme.body,
              decoration: InputDecoration(
                labelText: "Courier Tenant Id",
                labelStyle: AppTheme.title,
              ),
              controller: tenantTextController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: AppTheme.body,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Sign In",
              style: AppTheme.body,
            ),
          ),
        ],
      ),
    );

    return Future.value({
      'userId': userTextController.text,
      'tenantId': tenantTextController.text,
    });
  }

  _signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final values = await _showUserAlert();
      final newUserId = values['userId'];
      final newTenantId = values['tenantId'];

      if (newUserId == null || newUserId.isEmpty == true) return;

      final token = await ExampleServer.generateJwt(authKey: Env.authKey, userId: newUserId);

      await Courier.shared.signIn(
        accessToken: token,
        userId: newUserId,
        tenantId: newTenantId?.isEmpty == true ? null : newTenantId,
      );

      final userId = await Courier.shared.userId;
      final tenantId = await Courier.shared.tenantId;
      setState(() {
        _currentUserId = userId;
        _currentTenantId = tenantId;
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
      final tenantId = await Courier.shared.tenantId;
      setState(() {
        _currentUserId = userId;
        _currentTenantId = tenantId;
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'User ID:',
                  textAlign: TextAlign.end,
                  style: AppTheme.body,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _currentUserId ?? 'None',
                  textAlign: TextAlign.start,
                  style: AppTheme.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tenant ID:',
                  textAlign: TextAlign.end,
                  style: AppTheme.body,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  _currentTenantId ?? 'None',
                  textAlign: TextAlign.start,
                  style: AppTheme.title,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            child: Text(
              _currentUserId != null ? 'Sign Out' : 'Sign In',
              style: AppTheme.body,
            ),
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
