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
  final coreChannel = const MethodChannel('courier_flutter_core');
  final inboxChannel = const MethodChannel('courier_flutter_inbox');

  final Map<String, CourierInboxListener> _inboxListeners = {};

  CoreChannelCourierFlutter() {

    // Initialize the inbox method callback
    inboxChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'onInitialLoad':
          {
            _inboxListeners.forEach((key, value) {
              value.onInitialLoad?.call();
            });
            break;
          }
        case 'onError':
          {
            _inboxListeners.forEach((key, value) {
              value.onError?.call(call.arguments);
            });
            break;
          }
        case 'onMessagesChanged':
          {

            // Map the messages
            List<dynamic>? messages = call.arguments['messages'];
            List<InboxMessage>? inboxMessages = messages?.map((message) => InboxMessage.fromJson(message)).toList();

            // Call the callback
            _inboxListeners.forEach((key, value) {
              value.onMessagesChanged?.call(
                inboxMessages ??= [],
                call.arguments['unreadMessageCount'],
                call.arguments['totalMessageCount'],
                call.arguments['canPaginate'],
              );
            });

            break;
          }
      }
      return Future.value();
    });

  }

  @override
  Future<bool> isDebugging(bool isDebugging) async {
    return await coreChannel.invokeMethod('isDebugging', {
      'isDebugging': isDebugging,
    });
  }

  @override
  Future<String?> userId() async {
    return await coreChannel.invokeMethod('userId');
  }

  @override
  Future<String?> getToken({ required String provider }) async {
    return await coreChannel.invokeMethod('getToken', {
      'provider': provider,
    });
  }

  @override
  Future setToken({ required String provider, required String token }) async {
    return await coreChannel.invokeMethod('setToken', {
      'provider': provider,
      'token': token,
    });
  }

  @override
  Future signIn(String accessToken, String userId, [String? clientKey]) async {
    return await coreChannel.invokeMethod('signIn', {
      'accessToken': accessToken,
      'clientKey': clientKey,
      'userId': userId,
    });
  }

  @override
  Future signOut() async {
    return await coreChannel.invokeMethod('signOut');
  }

  @override
  Future<CourierInboxListener> addInboxListener([Function? onInitialLoad, Function(dynamic error)? onError, Function(List<InboxMessage> messages, int unreadMessageCount, int totalMessageCount, bool canPaginate)? onMessagesChanged]) async {

    // Call the method
    String id = await coreChannel.invokeMethod('addInboxListener');

    // Create the listener
    final listener = CourierInboxListener(listenerId: id);
    listener.onInitialLoad = onInitialLoad;
    listener.onError = onError;
    listener.onMessagesChanged = onMessagesChanged;

    // Add listener to manager
    _inboxListeners[listener.listenerId] = listener;

    return listener;
  }

  @override
  Future<String> removeInboxListener({ required String id }) async {

    final listenerId = await coreChannel.invokeMethod('removeInboxListener', {
      'id': id,
    });

    // Remove listener
    _inboxListeners.remove(listenerId) ;

    return listenerId;

  }

  @override
  Future<int> setInboxPaginationLimit({ required int limit }) async {
    return await coreChannel.invokeMethod('setInboxPaginationLimit', {
      'limit': limit,
    });
  }

  @override
  Future refreshInbox() async {
    return await coreChannel.invokeMethod('refreshInbox');
  }

  @override
  Future<List<InboxMessage>> fetchNextPageOfMessages() async {
    List<dynamic> messages = await coreChannel.invokeMethod('fetchNextPageOfMessages');
    List<InboxMessage>? inboxMessages = messages.map((message) => InboxMessage.fromJson(message)).toList();
    return inboxMessages;
  }

  @override
  Future readMessage({ required String id }) async {
    return await coreChannel.invokeMethod('readMessage', {
      'id': id,
    });
  }

  @override
  Future unreadMessage({ required String id }) async {
    return await coreChannel.invokeMethod('unreadMessage', {
      'id': id,
    });
  }

  @override
  Future readAllInboxMessages() async {
    return await coreChannel.invokeMethod('readAllInboxMessages');
  }

  @override
  Future<CourierUserPreferences> getUserPreferences({ String? paginationCursor }) async {
    final data = await coreChannel.invokeMethod('getUserPreferences', {
      'paginationCursor': paginationCursor,
    });
    return CourierUserPreferences.fromJson(data);
  }

  @override
  Future<CourierUserPreferencesTopic> getUserPreferencesTopic({ required String topicId }) async {
    final data = await coreChannel.invokeMethod('getUserPreferencesTopic', {
      'topicId': topicId,
    });
    return CourierUserPreferencesTopic.fromJson(data);
  }

  @override
  Future<dynamic> putUserPreferencesTopic({ required String topicId, required String status, required bool hasCustomRouting, required List<String> customRouting }) async {
    return await coreChannel.invokeMethod('putUserPreferencesTopic', {
      'topicId': topicId,
      'status': status,
      'hasCustomRouting': hasCustomRouting,
      'customRouting': customRouting,
    });
  }
}
