import 'package:flutter/foundation.dart';
import 'courier_flutter_core_platform_interface.dart';
import 'courier_flutter_events_platform_interface.dart';

class Courier {

  Function(dynamic message)? _onPushNotificationDelivered;
  set onPushNotificationDelivered(Function(dynamic message)? listener) {
    _onPushNotificationDelivered = listener;
  }

  // When registering the push notification click listener
  // The Flutter SDK will check to see if the native platform has a notification waiting for it
  Function(dynamic message)? _onPushNotificationClicked;
  set onPushNotificationClicked(Function(dynamic message)? listener) {
    _onPushNotificationClicked = listener;
    CourierFlutterEventsPlatform.instance.getClickedNotification();
  }

  Courier._() {

    // Set debugging mode to default if app is debugging
    setIsDebugging(kDebugMode);

    // Register listeners for when the native system receives messages
    CourierFlutterEventsPlatform.instance.registerMessagingListeners(
        onPushNotificationDelivered: (message) => _onPushNotificationDelivered?.call(message),
        onPushNotificationClicked: (message) => _onPushNotificationClicked?.call(message),
        onLogPosted: (log) => { /* Empty for now. Does support receiving logs */ },
    );

  }

  static Courier? _instance;
  static Courier get shared => _instance ??= Courier._();

  bool _isDebugging = false;
  bool get isDebugging => _isDebugging;
  Future setIsDebugging(bool isDebugging) async {
    _isDebugging = await CourierFlutterCorePlatform.instance.isDebugging(isDebugging);
  }

  Future<String?> get userId => CourierFlutterCorePlatform.instance.userId();

  Future<String?> get fcmToken => CourierFlutterCorePlatform.instance.fcmToken();

  Future setFcmToken({ required String token }) {
    return CourierFlutterCorePlatform.instance.setFcmToken(token);
  }

  Future signIn({ required String accessToken, required String userId }) {
    return CourierFlutterCorePlatform.instance.signIn(accessToken, userId);
  }

  Future signOut() {
    return CourierFlutterCorePlatform.instance.signOut();
  }

  Future<String> requestNotificationPermission() {
    return CourierFlutterEventsPlatform.instance.requestNotificationPermission();
  }

  Future<String> sendPush({ required String authKey, required String userId, required String title, required String body }) {
    return CourierFlutterCorePlatform.instance.sendPush(authKey, userId, title, body);
  }

}
