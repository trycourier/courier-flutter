import 'dart:convert';

import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/courier_provider.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/courier_push_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class PushPage extends StatefulWidget {
  const PushPage({super.key});

  @override
  State<PushPage> createState() => _PushPageState();
}

class _PushPageState extends State<PushPage> {
  late CourierPushListener _pushListener;

  String? _apnsToken;
  String? _fcmToken;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _pushListener = Courier.shared.addPushListener(
      onPushClicked: (push) {
        print(push);
      },
      onPushDelivered: (push) {
        print(push);
      },
    );

    _getTokens();
  }

  Future _getTokens() async {
    setState(() {
      _isLoading = true;
    });

    final fcm = await Courier.shared.getTokenForProvider(provider: CourierPushProvider.firebaseFcm);
    final apns = await Courier.shared.getTokenForProvider(provider: CourierPushProvider.apn);

    setState(() {
      _isLoading = false;
      _fcmToken = fcm;
      _apnsToken = apns;
    });
  }

  Future _requestPermissions() async {
    final status = await Courier.shared.requestNotificationPermission();
    print(status);
  }

  Widget _buildToken(String title, BuildContext context) {
    return InkWell(
      onTap: () async {
        print(title);
        await Clipboard.setData(ClipboardData(text: title));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Copied: $title"),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          title,
          style: GoogleFonts.robotoMono(fontSize: 16.0),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToken(_apnsToken ?? 'No APNS Token', context),
            Container(height: 16.0),
            _buildToken(_fcmToken ?? 'No FCM Token', context),
            Container(height: 16.0),
            ElevatedButton(
              onPressed: () => _getTokens(),
              child: const Text('Refresh Tokens'),
            ),
            Container(height: 16.0),
            ElevatedButton(
              onPressed: () => _requestPermissions(),
              child: const Text('Request Permissions'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
      ),
      body: _buildContent(context),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pushListener.remove();
  }
}
