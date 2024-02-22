import 'dart:ffi';

import 'package:courier_flutter/channels/core_method_channel.dart';
import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/courier_preference_topic.dart';
import 'package:courier_flutter/models/courier_user_preferences.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

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

  Future<String?> getToken({ required String provider }) {
    throw UnimplementedError('getToken() has not been implemented.');
  }

  Future setToken({ required String provider, required String token }) {
    throw UnimplementedError('setToken() has not been implemented.');
  }

  Future signIn(String accessToken, String userId, [String? clientKey]) {
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

  Future setBrandId({ required String id }) {
    throw UnimplementedError('setBrandId() has not been implemented.');
  }

  Future getBrand() {
    throw UnimplementedError('getBrand() has not been implemented.');
  }

  Future<CourierUserPreferences> getUserPreferences({ String? paginationCursor }) {
    throw UnimplementedError('getUserPreferences() has not been implemented.');
  }

  Future<CourierUserPreferencesTopic> getUserPreferencesTopic({ required String topicId }) {
    throw UnimplementedError('getUserPreferencesTopic() has not been implemented.');
  }

  Future<dynamic> putUserPreferencesTopic({ required String topicId, required String status, required bool hasCustomRouting, required List<String> customRouting }) {
    throw UnimplementedError('putUserPreferencesTopic() has not been implemented.');
  }

}
