import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'courier_flutter_core_platform_interface.dart';

/// An implementation of [CourierFlutterPlatform] that uses method channels.
class MethodChannelCourierFlutter extends CourierFlutterPlatform {

  @visibleForTesting
  final coreChannel = const MethodChannel('courier_flutter_core');
  final eventsChannel = const MethodChannel('courier_flutter_events');

  @override
  Future<String?> userId() async {
    return await coreChannel.invokeMethod('userId');
  }

  @override
  Future<String?> fcmToken() async {
    return await coreChannel.invokeMethod('fcmToken');
  }

  @override
  Future setFcmToken(String token) async {
    return await coreChannel.invokeMethod('setFcmToken', {
      'token': token,
    });
  }

  @override
  Future signIn(String accessToken, String userId) async {
    return await coreChannel.invokeMethod('signIn', {
      'accessToken': accessToken,
      'userId': userId,
    });
  }

  @override
  Future signOut() async {
    return await coreChannel.invokeMethod('signOut');
  }

  @override
  Future<String> sendPush(String authKey, String userId, String title, String body) async {
    return await coreChannel.invokeMethod('sendPush', {
      'authKey': authKey,
      'userId': userId,
      'title': title,
      'body': body,
    });
  }

  @override
  Future getClickedNotification() async {
    return await eventsChannel.invokeMethod('getClickedNotification');
  }

}
