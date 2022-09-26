

import 'package:flutter/services.dart';

import 'courier_flutter_platform_interface.dart';

class Courier {

  Courier._() {
    _registerPushNotificationListeners();
  }

  static Courier? _instance;
  static Courier get shared => _instance ??= Courier._();

  Future<String?> get userId => CourierFlutterPlatform.instance.userId();

  Future signIn({ required String accessToken, required String userId }) {
    return CourierFlutterPlatform.instance.signIn(accessToken, userId);
  }

  Future signOut() {
    return CourierFlutterPlatform.instance.signOut();
  }

  Function(dynamic message)? onPushNotificationDelivered;

  // When registering the push notification click listener
  // The Flutter SDK will check to see if the native platform has a notification waiting for it
  Function(dynamic message)? _onPushNotificationClicked;
  set onPushNotificationClicked(Function(dynamic message)? listener) {
    _onPushNotificationClicked = listener;
    CourierFlutterPlatform.instance.getClickedNotification();
  }

  _registerPushNotificationListeners() {

    const eventsChannel = MethodChannel('courier_flutter_events');
    eventsChannel.setMethodCallHandler((call) {

      switch (call.method) {
        case 'pushNotificationDelivered': {
          onPushNotificationDelivered?.call(call.arguments);
          break;
        }
        case 'pushNotificationClicked': {
          _onPushNotificationClicked?.call(call.arguments);
          break;
        }
      }

      return Future.value();

    });

  }

}
