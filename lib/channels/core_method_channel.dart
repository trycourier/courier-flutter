import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/courier_user_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class CoreChannelCourierFlutter extends CourierFlutterCorePlatform {

  @visibleForTesting
  final sharedChannel = const MethodChannel('courier_flutter_shared');
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
    return await sharedChannel.invokeMethod('isDebugging', {
      'isDebugging': isDebugging,
    });
  }

  @override
  Future<String?> userId() async {
    return await sharedChannel.invokeMethod('userId');
  }

  @override
  Future<String?> tenantId() async {
    return await sharedChannel.invokeMethod('tenantId');
  }

  @override
  Future<String?> getToken({ required String provider }) async {
    return await sharedChannel.invokeMethod('getToken', {
      'provider': provider,
    });
  }

  @override
  Future setToken({ required String provider, required String token }) async {
    return await sharedChannel.invokeMethod('setToken', {
      'provider': provider,
      'token': token,
    });
  }

  @override
  Future signIn({ required String userId, required String accessToken, String? clientKey, String? tenantId }) async {
    await sharedChannel.invokeMethod('shared.auth.sign_in', {
      'accessToken': accessToken,
      'clientKey': clientKey,
      'userId': userId,
      'tenantId': tenantId,
    });
  }

  @override
  Future signOut() async {
    return await sharedChannel.invokeMethod('shared.auth.sign_out');
  }

  @override
  Future<CourierInboxListener> addInboxListener([Function? onInitialLoad, Function(dynamic error)? onError, Function(List<InboxMessage> messages, int unreadMessageCount, int totalMessageCount, bool canPaginate)? onMessagesChanged]) async {

    // Call the method
    String id = await sharedChannel.invokeMethod('addInboxListener');

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

    final listenerId = await sharedChannel.invokeMethod('removeInboxListener', {
      'id': id,
    });

    // Remove listener
    _inboxListeners.remove(listenerId) ;

    return listenerId;

  }

  @override
  Future<int> setInboxPaginationLimit({ required int limit }) async {
    return await sharedChannel.invokeMethod('setInboxPaginationLimit', {
      'limit': limit,
    });
  }

  @override
  Future refreshInbox() async {
    return await sharedChannel.invokeMethod('refreshInbox');
  }

  @override
  Future<List<InboxMessage>> fetchNextPageOfMessages() async {
    List<dynamic> messages = await sharedChannel.invokeMethod('fetchNextPageOfMessages');
    List<InboxMessage>? inboxMessages = messages.map((message) => InboxMessage.fromJson(message)).toList();
    return inboxMessages;
  }

  @override
  Future clickMessage({ required String id }) async {
    return await sharedChannel.invokeMethod('clickMessage', {
      'id': id,
    });
  }

  @override
  Future readMessage({ required String id }) async {
    return await sharedChannel.invokeMethod('readMessage', {
      'id': id,
    });
  }

  @override
  Future unreadMessage({ required String id }) async {
    return await sharedChannel.invokeMethod('unreadMessage', {
      'id': id,
    });
  }

  @override
  Future readAllInboxMessages() async {
    return await sharedChannel.invokeMethod('readAllInboxMessages');
  }

  @override
  Future getBrand({ required String id }) async {
    return await sharedChannel.invokeMethod('getBrand', {
      'id': id,
    });
  }

  @override
  Future<CourierUserPreferences> getUserPreferences({ String? paginationCursor }) async {
    final data = await sharedChannel.invokeMethod('getUserPreferences', {
      'paginationCursor': paginationCursor,
    });
    return CourierUserPreferences.fromJson(data);
  }

  // @override
  // Future<CourierUserPreferencesTopic> getUserPreferencesTopic({ required String topicId }) async {
  //   final data = await coreChannel.invokeMethod('getUserPreferencesTopic', {
  //     'topicId': topicId,
  //   });
  //   return CourierUserPreferencesTopic.fromJson(data);
  // }

  @override
  Future<dynamic> putUserPreferencesTopic({ required String topicId, required String status, required bool hasCustomRouting, required List<String> customRouting }) async {
    return await sharedChannel.invokeMethod('putUserPreferencesTopic', {
      'topicId': topicId,
      'status': status,
      'hasCustomRouting': hasCustomRouting,
      'customRouting': customRouting,
    });
  }
}

abstract class CourierFlutterCorePlatform extends PlatformInterface {

  CourierFlutterCorePlatform() : super(token: _token);
  static final Object _token = Object();
  static CourierFlutterCorePlatform _instance = CoreChannelCourierFlutter();

  static CourierFlutterCorePlatform get instance => _instance;

  static set instance(CourierFlutterCorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> isDebugging(bool isDebugging) {
    throw UnimplementedError('isDebugging() has not been implemented.');
  }

  Future<String?> userId() {
    throw UnimplementedError('userId() has not been implemented.');
  }

  Future<String?> tenantId() {
    throw UnimplementedError('tenantId() has not been implemented.');
  }

  Future<String?> getToken({ required String provider }) {
    throw UnimplementedError('getToken() has not been implemented.');
  }

  Future setToken({ required String provider, required String token }) {
    throw UnimplementedError('setToken() has not been implemented.');
  }

  Future signIn({ required String userId, required String accessToken, String? clientKey, String? tenantId }) {
    throw UnimplementedError('signIn() has not been implemented.');
  }

  Future signOut() {
    throw UnimplementedError('signOut() has not been implemented.');
  }

  Future<CourierInboxListener> addInboxListener([Function? onInitialLoad, Function(dynamic error)? onError, Function(List<InboxMessage> messages, int unreadMessageCount, int totalMessageCount, bool canPaginate)? onMessagesChanged]) {
    throw UnimplementedError('addInboxListener() has not been implemented.');
  }

  Future<String> removeInboxListener({ required String id }) {
    throw UnimplementedError('removeInboxListener() has not been implemented.');
  }

  Future<int> setInboxPaginationLimit({ required int limit }) {
    throw UnimplementedError('setInboxPaginationLimit() has not been implemented.');
  }

  Future refreshInbox() {
    throw UnimplementedError('refreshInbox() has not been implemented.');
  }

  Future<List<InboxMessage>> fetchNextPageOfMessages() {
    throw UnimplementedError('fetchNextPageOfMessages() has not been implemented.');
  }

  Future clickMessage({ required String id }) {
    throw UnimplementedError('clickMessage() has not been implemented.');
  }

  Future readMessage({ required String id }) {
    throw UnimplementedError('readMessage() has not been implemented.');
  }

  Future unreadMessage({ required String id }) {
    throw UnimplementedError('unreadMessage() has not been implemented.');
  }

  Future readAllInboxMessages() {
    throw UnimplementedError('readAllInboxMessages() has not been implemented.');
  }

  Future getBrand({ required String id }) {
    throw UnimplementedError('getBrand() has not been implemented.');
  }

  Future<CourierUserPreferences> getUserPreferences({ String? paginationCursor }) {
    throw UnimplementedError('getUserPreferences() has not been implemented.');
  }

  // Future<CourierUserPreferencesTopic> getUserPreferencesTopic({ required String topicId }) {
  //   throw UnimplementedError('getUserPreferencesTopic() has not been implemented.');
  // }

  Future<dynamic> putUserPreferencesTopic({ required String topicId, required String status, required bool hasCustomRouting, required List<String> customRouting }) {
    throw UnimplementedError('putUserPreferencesTopic() has not been implemented.');
  }

}