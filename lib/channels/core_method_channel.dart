import 'dart:io';

import 'package:courier_flutter/channels/core_platform_interface.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
  Future signIn(String accessToken, String userId, [String? clientKey]) async {
    return await channel.invokeMethod('signIn', {
      'accessToken': accessToken,
      'clientKey': clientKey,
      'userId': userId,
    });
  }

  @override
  Future signOut() async {
    return await channel.invokeMethod('signOut');
  }

  @override
  Future<CourierInboxListener> addInboxListener([Function? onInitialLoad, Function(dynamic error)? onError, Function(List<dynamic> messages, int unreadMessageCount, int totalMessageCount, bool canPaginate)? onMessagesChanged]) async {

    // Call the method
    String id = await channel.invokeMethod('addInboxListener');

    // Create the listener
    final listener = CourierInboxListener(listenerId: id);
    listener.onInitialLoad = onInitialLoad;
    listener.onError = onError;
    listener.onMessagesChanged = onMessagesChanged;

    const MethodChannel('courier_flutter_inbox').setMethodCallHandler((call) {

      switch (call.method) {

        case 'onInitialLoad': {
          listener.onInitialLoad?.call();
          break;
        }

        case 'onError': {
          listener.onError?.call(call.arguments);
          break;
        }

        case 'onMessagesChanged': {
          listener.onMessagesChanged?.call(
              call.arguments['messages'],
              call.arguments['totalMessageCount'],
              call.arguments['unreadMessageCount'],
              call.arguments['canPaginate'],
          );
          break;
        }

      }

      return Future.value();

    });

    return listener;

  }

  @override
  Future<String> removeInboxListener({ required String id }) async {
    return await channel.invokeMethod('removeInboxListener', {
      'id': id,
    });
  }

  @override
  Future<int> setInboxPaginationLimit({ required int limit }) async {
    return await channel.invokeMethod('setInboxPaginationLimit', {
      'limit': limit,
    });
  }

  @override
  Future<List> fetchNextPageOfMessages() async {
    return await channel.invokeMethod('fetchNextPageOfMessages');
  }

}
