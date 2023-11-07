import 'dart:io';

import 'package:courier_flutter/channels/core_platform_interface.dart';
import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/courier_preference_topic.dart';
import 'package:courier_flutter/models/courier_user_preferences.dart';
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
  Future<String?> getToken({ required String provider }) async {
    return await channel.invokeMethod('getToken');
  }

  @override
  Future setToken({ required String provider, required String token }) async {
    return await channel.invokeMethod('setToken', {
      'provider': provider,
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
  Future<CourierInboxListener> addInboxListener([Function? onInitialLoad, Function(dynamic error)? onError, Function(List<InboxMessage> messages, int unreadMessageCount, int totalMessageCount, bool canPaginate)? onMessagesChanged]) async {

    // Call the method
    String id = await channel.invokeMethod('addInboxListener');

    // Create the listener
    final listener = CourierInboxListener(listenerId: id);
    listener.onInitialLoad = onInitialLoad;
    listener.onError = onError;
    listener.onMessagesChanged = onMessagesChanged;

    const MethodChannel('courier_flutter_inbox').setMethodCallHandler((call) {
      switch (call.method) {
        case 'onInitialLoad':
          {
            listener.onInitialLoad?.call();
            break;
          }

        case 'onError':
          {
            listener.onError?.call(call.arguments);
            break;
          }

        case 'onMessagesChanged':
          {

            // Map the messages
            List<dynamic>? messages = call.arguments['messages'];
            List<InboxMessage>? inboxMessages = messages?.map((message) => InboxMessage.fromJson(message)).toList();

            // Call the callback
            listener.onMessagesChanged?.call(
              inboxMessages ??= [],
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
  Future<List<InboxMessage>> fetchNextPageOfMessages() async {
    List<dynamic> messages = await channel.invokeMethod('fetchNextPageOfMessages');
    List<InboxMessage>? inboxMessages = messages.map((message) => InboxMessage.fromJson(message)).toList();
    return inboxMessages;
  }

  @override
  Future readMessage({ required String id }) async {
    return await channel.invokeMethod('readMessage', {
      'id': id,
    });
  }

  @override
  Future unreadMessage({ required String id }) async {
    return await channel.invokeMethod('unreadMessage', {
      'id': id,
    });
  }

  @override
  Future readAllInboxMessages() async {
    return await channel.invokeMethod('readAllInboxMessages');
  }

  @override
  Future<CourierUserPreferences> getUserPreferences({ String? paginationCursor }) async {
    final data = await channel.invokeMethod('getUserPreferences', {
      'paginationCursor': paginationCursor,
    });
    return CourierUserPreferences.fromJson(data);
  }

  @override
  Future<CourierUserPreferencesTopic> getUserPreferencesTopic({ required String topicId }) async {
    final data = await channel.invokeMethod('getUserPreferencesTopic', {
      'topicId': topicId,
    });
    return CourierUserPreferencesTopic.fromJson(data);
  }

  @override
  Future<dynamic> putUserPreferencesTopic({ required String topicId, required String status, required bool hasCustomRouting, required List<String> customRouting }) async {
    return await channel.invokeMethod('putUserPreferencesTopic', {
      'topicId': topicId,
      'status': status,
      'hasCustomRouting': hasCustomRouting,
      'customRouting': customRouting,
    });
  }
}
