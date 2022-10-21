import 'dart:math';

import 'package:courier_flutter/courier_flutter_events_platform_interface.dart';
import 'package:courier_flutter/courier_provider.dart';
import 'package:courier_flutter/ios_foreground_notification_presentation_options.dart';
import 'package:courier_flutter/notification_permission_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/courier_flutter_core_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCourierFlutterCorePlatform with MockPlatformInterfaceMixin implements CourierFlutterCorePlatform {

  String? _userId;
  String? _accessToken;
  String? _apnsToken;
  String? _fcmToken;
  bool _isDebugging = false;

  @override
  Future<bool> isDebugging(bool isDebugging) {
    return Future.value(_isDebugging);
  }

  @override
  Future<String?> userId() {
    return Future.value(_userId);
  }

  @override
  Future signIn(String accessToken, String userId) {
    _userId = userId;
    _accessToken = accessToken;
    return Future.value();
  }

  @override
  Future signOut() {
    _userId = null;
    _accessToken = null;
    return Future.value();
  }

  @override
  Future<String?> apnsToken() {
    return Future.value(_apnsToken);
  }

  @override
  Future<String?> fcmToken() {
    return Future.value(_fcmToken);
  }

  @override
  Future setFcmToken(String token) {

    if (_userId == null) {
      print('No user set');
      return Future.value();
    }

    _fcmToken = token;
    return Future.value();

  }

  @override
  Future<String> sendPush(String authKey, String userId, String title, String body, bool isProduction, List<CourierProvider> providers) {
    throw Future.value('asdf');
  }
}

class MockCourierFlutterEventsPlatform with MockPlatformInterfaceMixin implements CourierFlutterEventsPlatform {
  @override
  Future iOSForegroundPresentationOptions(List<iOSNotificationPresentationOption> options) {
    return Future.value();
  }

  @override
  registerMessagingListeners({required Function(dynamic message) onPushNotificationDelivered, required Function(dynamic message) onPushNotificationClicked, required Function(dynamic log) onLogPosted}) {
    return;
  }

  @override
  Future<String> getNotificationPermissionStatus() {
    const permissions = NotificationPermissionStatus.values;
    final randomPermission = permissions.elementAt(Random().nextInt(permissions.length));
    return Future.value(randomPermission.value);
  }

  @override
  Future<String> requestNotificationPermission() {
    const permissions = NotificationPermissionStatus.values;
    final randomPermission = permissions.elementAt(Random().nextInt(permissions.length));
    return Future.value(randomPermission.value);
  }

  @override
  Future getClickedNotification() {
    return Future.value();
  }
}

void main() {

  const exampleUserId = 'example_user_id';
  const exampleAccessToken = 'example_access_token';
  const exampleFcmToken = 'asdfasdf';

  setUpAll(() {
    CourierFlutterCorePlatform.instance = MockCourierFlutterCorePlatform();
    CourierFlutterEventsPlatform.instance = MockCourierFlutterEventsPlatform();
  });

  test('setFcmToken Failure', () async {
    await Courier.shared.setFcmToken(token: exampleFcmToken);
    final token = await Courier.shared.fcmToken;
    expect(token, null);
  });

  test('signIn', () async {
    await Courier.shared.signIn(
      accessToken: exampleAccessToken,
      userId: exampleUserId,
    );
    final userId = await Courier.shared.userId;
    expect(userId, userId);
  });

  test('setFcmToken Success', () async {
    await Courier.shared.setFcmToken(token: exampleFcmToken);
    final storedToken = await Courier.shared.fcmToken;
    expect(exampleFcmToken, storedToken);
  });

  test('getApnsToken', () async {
    final token = await Courier.shared.apnsToken;
    expect(token, null);
  });

  test('getFcmToken', () async {
    final token = await Courier.shared.fcmToken;
    expect(token, exampleFcmToken);
  });

  test('signOut', () async {
    await Courier.shared.signOut();
    final userId = await Courier.shared.userId;
    final fcmToken = await Courier.shared.fcmToken;
    final apnsToken = await Courier.shared.apnsToken;
    expect(userId, null);
    expect(fcmToken, fcmToken);
    expect(apnsToken, null);
  });

}
