import 'dart:io';

import 'package:courier_flutter/channels/core_platform_interface.dart';
import 'package:courier_flutter/courier_flutter.dart';
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

            List<dynamic> messages = call.arguments['messages'];

            List<InboxMessage> inboxMessages = messages.map((message) {

              List<dynamic>? actions = call.arguments['actions'];

              return InboxMessage(
                messageId: message['messageId'],
                title: message['title'],
                body: message['body'],
                preview: message['preview'],
                created: message['created'],
                actions: actions?.map((action) => InboxAction(content: action['content'], href: action['href'], data: action['data'])).toList(),
                data: message['data'],
                archived: message['archived'],
                read: message['read'],
                opened: message['opened'],
              );

            }).toList();

            listener.onMessagesChanged?.call(
              inboxMessages,
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
  Future<String> removeInboxListener({required String id}) async {
    return await channel.invokeMethod('removeInboxListener', {
      'id': id,
    });
  }

  @override
  Future<int> setInboxPaginationLimit({required int limit}) async {
    return await channel.invokeMethod('setInboxPaginationLimit', {
      'limit': limit,
    });
  }

  @override
  Future<List> fetchNextPageOfMessages() async {
    return await channel.invokeMethod('fetchNextPageOfMessages');
  }

  @override
  Future readMessage({required String id}) async {
    return await channel.invokeMethod('readMessage', {
      'id': id,
    });
  }

  @override
  Future unreadMessage({required String id}) async {
    return await channel.invokeMethod('unreadMessage', {
      'id': id,
    });
  }

  @override
  Future readAllInboxMessages() async {
    return await channel.invokeMethod('readAllInboxMessages');
  }

  @override
  Future<dynamic> getUserPreferences({String? paginationCursor}) async {
    return await channel.invokeMethod('getUserPreferences', {
      'paginationCursor': paginationCursor,
    });
  }

  @override
  Future<dynamic> getUserPreferencesTopic({required String topicId}) async {
    return await channel.invokeMethod('getUserPreferencesTopic', {
      'topicId': topicId,
    });
  }

  @override
  Future<dynamic> putUserPreferencesTopic({required String topicId, required String status, required bool hasCustomRouting, required List<String> customRouting}) async {
    return await channel.invokeMethod('putUserPreferencesTopic', {
      'topicId': topicId,
      'status': status,
      'hasCustomRouting': hasCustomRouting,
      'customRouting': customRouting,
    });
  }
}
