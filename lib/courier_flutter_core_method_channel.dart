import 'dart:io';

import 'package:courier_flutter/courier_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'courier_flutter_core_platform_interface.dart';

/// An implementation of [CourierFlutterCorePlatform] that uses method channels.
class CoreChannelCourierFlutter extends CourierFlutterCorePlatform {
  @visibleForTesting
  final channel = const MethodChannel('courier_flutter_core');

  @override
  Future<bool> isDebugging(bool isDebugging) async {
    return await channel.invokeMethod('isDebugging', {
      'isDebugging': isDebugging,
    });
  }

  @override
  Future<String?> userId() async {
    return await channel.invokeMethod('userId');
  }

  @override
  Future<String?> apnsToken() async {
    // Skip other platforms. Do not show error
    if (!Platform.isIOS) return null;

    return await channel.invokeMethod('apnsToken');
  }

  @override
  Future<String?> fcmToken() async {
    return await channel.invokeMethod('fcmToken');
  }

  @override
  Future setFcmToken(String token) async {
    return await channel.invokeMethod('setFcmToken', {
      'token': token,
    });
  }

  @override
  Future signIn(String accessToken, String userId) async {
    return await channel.invokeMethod('signIn', {
      'accessToken': accessToken,
      'userId': userId,
    });
  }

  @override
  Future signOut() async {
    return await channel.invokeMethod('signOut');
  }

  @override
  Future<String> sendPush(String authKey, String userId, String title,
      String body, List<CourierProvider> providers) async {
    return await channel.invokeMethod('sendPush', {
      'authKey': authKey,
      'userId': userId,
      'title': title,
      'body': body,
      'providers': providers.map((provider) => provider.value).toList(),
    });
  }
}
