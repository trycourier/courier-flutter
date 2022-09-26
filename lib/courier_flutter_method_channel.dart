import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'courier_flutter_platform_interface.dart';

/// An implementation of [CourierFlutterPlatform] that uses method channels.
class MethodChannelCourierFlutter extends CourierFlutterPlatform {

  @visibleForTesting
  final methodChannel = const MethodChannel('courier_flutter');
  final eventsChannel = const MethodChannel('courier_flutter_events');

  @override
  Future<String?> userId() async {
    return await methodChannel.invokeMethod('userId');
  }

  @override
  Future signIn(String accessToken, String userId) async {
    return await methodChannel.invokeMethod('signIn', {
      'accessToken': accessToken,
      'userId': userId,
    });
  }

  @override
  Future signOut() async {
    return await methodChannel.invokeMethod('signOut');
  }

  @override
  Future getClickedNotification() async {
    return await eventsChannel.invokeMethod('getClickedNotification');
  }

}
