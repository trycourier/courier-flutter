import 'dart:convert';

import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/courier_provider.dart';
import 'package:courier_flutter/ios_foreground_notification_presentation_options.dart';
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

    Courier.shared.iOSForegroundNotificationPresentationOptions = [
      iOSNotificationPresentationOption.banner,
      iOSNotificationPresentationOption.sound,
      iOSNotificationPresentationOption.list,
      iOSNotificationPresentationOption.badge,
    ];
    print(Courier.shared.iOSForegroundNotificationPresentationOptions);

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

  Widget _buildToken(BuildContext context, String title, String value) {
    return InkWell(
      onTap: () async {
        print(value);
        await Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Copied: $value"),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: GoogleFonts.robotoMono(fontSize: 16.0).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.robotoMono(fontSize: 16.0),
                ),
              ),
            ),
          ],
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
            _buildToken(context, 'APNS Token', _apnsToken ?? 'No APNS Token'),
            Container(height: 16.0),
            _buildToken(context, 'FCM Token', _fcmToken ?? 'No FCM Token'),
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
