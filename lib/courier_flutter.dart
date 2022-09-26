

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
  Function(dynamic message)? onPushNotificationClicked;

  getClickedNotification() {
    return CourierFlutterPlatform.instance.getClickedNotification();
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
          onPushNotificationClicked?.call(call.arguments);
          break;
        }
      }

      return Future.value();

    });

  }

}
