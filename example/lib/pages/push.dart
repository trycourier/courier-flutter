import 'dart:convert';

import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/courier_provider.dart';
import 'package:courier_flutter/models/courier_push_listener.dart';
import 'package:courier_flutter_sample/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class PushPage extends StatefulWidget {
  const PushPage({super.key});

  @override
  State<PushPage> createState() => _PushPageState();
}

class _PushPageState extends State<PushPage> {
  late CourierPushListener? _pushListener;

  String? _apnsToken;
  String? _fcmToken;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    _pushListener = await Courier.shared.addPushListener(
      onPushDelivered: (push) {
        print(push);
      },
      onPushClicked: (push) {
        print(push);
      },
    );

    final options = await Courier.setIOSForegroundPresentationOptions(options: [
      iOSNotificationPresentationOption.banner,
      iOSNotificationPresentationOption.sound,
      iOSNotificationPresentationOption.list,
      iOSNotificationPresentationOption.badge,
    ]);
    print(options);
    print(Courier.iOSForegroundNotificationPresentationOptions);

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
    final status = await Courier.requestNotificationPermission();
    print(status);
  }

  Widget _buildToken(BuildContext context, String title, String value) {
    return InkWell(
      onTap: () async {
        print(value);
        await Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Copied $title:\n$value", style: AppTheme.body),
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
                style: AppTheme.title,
              ),
            ),
            Flexible(
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: AppTheme.body,
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

    return Scrollbar(
      child: SingleChildScrollView(
        child: Padding(
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
                  child: Text(
                    'Refresh Tokens',
                    style: AppTheme.body,
                  ),
                ),
                Container(height: 16.0),
                ElevatedButton(
                  onPressed: () => _requestPermissions(),
                  child: Text(
                    'Request Permissions',
                    style: AppTheme.body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push'),
      ),
      body: _buildContent(context),
    );
  }

  @override
  void dispose() {
    _pushListener?.remove();
    super.dispose();
  }
}
