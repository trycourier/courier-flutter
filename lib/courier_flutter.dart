import 'dart:convert';
import 'dart:io';

import 'package:courier_flutter/courier_flutter_channels.dart';
import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/courier_provider.dart';
import 'package:courier_flutter/ios_foreground_notification_presentation_options.dart';
import 'package:courier_flutter/models/courier_authentication_listener.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/courier_push_listener.dart';
import 'package:courier_flutter/models/inbox_feed.dart';
import 'package:courier_flutter/models/inbox_message.dart';
import 'package:courier_flutter/models/inbox_message_set.dart';
import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:uuid/uuid.dart';

export 'models/inbox_message.dart';
export 'models/inbox_action.dart';
export 'ios_foreground_notification_presentation_options.dart';

class Courier extends CourierChannelManager {

  // Instance Creation
  static final Object _token = Object();
  static Courier? _instance;
  static Courier get shared => _instance ??= Courier._();

  // Local Values
  final Map<String, CourierAuthenticationListener> _authenticationListeners = {};
  final Map<String, CourierPushListener> _pushListeners = {};
  final Map<String, CourierInboxListener> _inboxListeners = {};

  Courier._() : super(token: _token) {

    // Attach event listeners
    CourierFlutterChannels.events.setMethodCallHandler((call) async {
      switch (call.method) {

        // --- AUTH ---
        case 'auth.state_changed': {
          String? userId = call.arguments['userId'];
          String? listenerId = call.arguments['id'];
          _authenticationListeners[listenerId]?.onUserStateChanged(userId);
          break;
        }

        // --- PUSH ---
        case 'push.clicked': {
          for (final listener in _pushListeners.values) {
            listener.onPushClicked?.call(call.arguments);
          }
          break;
        }
        case 'push.delivered': {
          for (final listener in _pushListeners.values) {
            listener.onPushDelivered?.call(call.arguments);
          }
          break;
        }

        // --- INBOX ---
        case 'inbox.listener_loading': {
          String? listenerId = call.arguments['id'];
          bool isRefresh = call.arguments['isRefresh'];
          _inboxListeners[listenerId]?.onLoading?.call(isRefresh);
          break;
        }
        case 'inbox.listener_error': {
          String? listenerId = call.arguments['id'];
          _inboxListeners[listenerId]?.onError?.call(call.arguments['error']);
          break;
        }
        case 'inbox.listener_unread_count_changed': {
          int count = call.arguments['count'];
          String? listenerId = call.arguments['id'];
          _inboxListeners[listenerId]?.onUnreadCountChanged?.call(count);
          break;
        }
        case 'inbox.listener_total_count_changed': {
          String? listenerId = call.arguments['id'];
          final feedValue = call.arguments['feed'];
          final feed = InboxFeed.fromValue(feedValue);
          int totalCount = call.arguments['totalCount'];
          _inboxListeners[listenerId]?.onTotalCountChanged?.call(feed, totalCount);
          break;
        }
        case 'inbox.listener_messages_changed': {
          String? listenerId = call.arguments['id'];
          final feedValue = call.arguments['feed'];
          final feed = InboxFeed.fromValue(feedValue);
          bool canPaginate = call.arguments['canPaginate'];
          final rawMessages = call.arguments['messages'] as List<dynamic>;
          final messages = rawMessages.map((m) => InboxMessage.fromJson(jsonDecode(m))).toList();

          _inboxListeners[listenerId]?.onMessagesChanged?.call(messages, canPaginate, feed);
          break;
        }
        case 'inbox.listener_page_added': {
          String? listenerId = call.arguments['id'];
          final feedValue = call.arguments['feed'];
          final feed = InboxFeed.fromValue(feedValue);
          bool canPaginate = call.arguments['canPaginate'];
          bool isFirstPage = call.arguments['isFirstPage'];
          final rawMessages = call.arguments['messages'] as List<dynamic>;
          final messages = rawMessages.map((m) => InboxMessage.fromJson(jsonDecode(m))).toList();

          _inboxListeners[listenerId]?.onPageAdded?.call(messages, canPaginate, isFirstPage, feed);
          break;
        }
        case 'inbox.listener_message_event': {
          String? listenerId = call.arguments['id'];
          final feedValue = call.arguments['feed'];
          final feed = InboxFeed.fromValue(feedValue);
          final event = call.arguments['event']; // e.g. "added", "changed", "removed"
          final index = call.arguments['index'];
          final rawMessage = call.arguments['message'];
          final message = InboxMessage.fromJson(jsonDecode(rawMessage));
          _inboxListeners[listenerId]?.onMessageEvent?.call(message, index, feed, InboxMessageEvent.fromString(event));
          break;
        }
      }
    });

  }

  // Debugging

  bool _isDebugging = kDebugMode;

  static void log(String message) {
    if (Courier.shared._isDebugging) {
      // ignore: avoid_print
      print(message);
    }
  }

  // iOS Foreground Notification

  static List<iOSNotificationPresentationOption> _iOSForegroundNotificationPresentationOptions =
      iOSNotificationPresentationOption.values;

  static List<iOSNotificationPresentationOption> get iOSForegroundNotificationPresentationOptions =>
      _iOSForegroundNotificationPresentationOptions;

  static Future<List<iOSNotificationPresentationOption>> setIOSForegroundPresentationOptions({
    required List<iOSNotificationPresentationOption> options
  }) async {
    if (!Platform.isIOS) return [];

    try {
      List<dynamic> newOptions = await CourierFlutterChannels.system.invokeMethod(
        'ios.set_foreground_presentation_options',
        { 'options': options.map((option) => option.value).toList() },
      );
      _iOSForegroundNotificationPresentationOptions = newOptions
          .map((option) => iOSNotificationPresentationOption.fromString(option))
          .toList();
      return _iOSForegroundNotificationPresentationOptions;
    } catch (error) {
      Courier.log(error.toString());
      _iOSForegroundNotificationPresentationOptions = [];
      return _iOSForegroundNotificationPresentationOptions;
    }
  }

  static Future<String> requestNotificationPermission() async {
    try {
      return await CourierFlutterChannels.system.invokeMethod('notifications.request_permission');
    } catch (error) {
      return 'unknown';
    }
  }

  static Future<String> getNotificationPermissionStatus() async {
    try {
      return await CourierFlutterChannels.system.invokeMethod('notifications.get_permission_status');
    } catch (error) {
      return 'unknown';
    }
  }

  static Future openSettingsApp() async {
    await CourierFlutterChannels.system.invokeMethod('app.open_settings');
  }

  static Future getClickedNotification() async {
    try {
      return await CourierFlutterChannels.system.invokeMethod('notifications.get_clicked_notification');
    } catch (error) {
      return;
    }
  }

  // Client

  @override
  Future<CourierClient?> get client async {
    final options = await CourierFlutterChannels.shared.invokeMethod('client.get_options');
    if (options == null) return null;
    return CourierClient(
      jwt: options['jwt'],
      clientKey: options['clientKey'],
      userId: options['userId'],
      tenantId: options['tenantId'],
      connectionId: options['connectionId'],
      showLogs: options['showLogs'],
    );
  }

  // Authentication

  @override
  Future<String?> get userId => CourierFlutterChannels.shared.invokeMethod('auth.user_id');

  @override
  Future<String?> get tenantId => CourierFlutterChannels.shared.invokeMethod('auth.tenant_id');

  @override
  Future<bool> get isUserSignedIn async {
    return await CourierFlutterChannels.shared.invokeMethod('auth.is_user_signed_in') ?? false;
  }

  @override
  Future signOut() async {
    await CourierFlutterChannels.shared.invokeMethod('auth.sign_out');
  }

  @override
  Future signIn({
    required String userId,
    required String accessToken,
    String? clientKey,
    String? tenantId,
    bool? showLogs
  }) async {
    _isDebugging = showLogs ?? kDebugMode;
    await CourierFlutterChannels.shared.invokeMethod('auth.sign_in', {
      'userId': userId,
      'tenantId': tenantId,
      'accessToken': accessToken,
      'clientKey': clientKey,
      'showLogs': _isDebugging,
    });
  }

  @override
  Future<CourierAuthenticationListener> addAuthenticationListener(
    Function(String? userId) onUserStateChanged
  ) async {
    final listenerId = const Uuid().v4();
    final listener = CourierAuthenticationListener(
      listenerId: listenerId,
      onUserStateChanged: onUserStateChanged,
    );
    _authenticationListeners[listenerId] = listener;

    await CourierFlutterChannels.shared.invokeMethod('auth.add_authentication_listener', {
      'listenerId': listenerId,
    });

    return listener;
  }

  @override
  Future removeAuthenticationListener({ required String listenerId }) async {
    await CourierFlutterChannels.shared.invokeMethod('auth.remove_authentication_listener', {
      'listenerId': listenerId,
    });
    _authenticationListeners.remove(listenerId);
  }

  @override
  Future removeAllAuthenticationListeners() async {
    await CourierFlutterChannels.shared.invokeMethod('auth.remove_all_authentication_listeners');
    _authenticationListeners.clear();
  }

  // Push & Tokens

  @override
  Future<String?> get apnsToken async {
    if (!Platform.isIOS) return null;
    return await CourierFlutterChannels.shared.invokeMethod('tokens.get_apns_token');
  }

  @override
  Future<String?> get fcmToken async {
    if (!Platform.isAndroid) return null;
    return await CourierFlutterChannels.shared.invokeMethod('tokens.get_fcm_token');
  }

  @override
  Future<Map<String, String>> get tokens async {
    final result = await CourierFlutterChannels.shared.invokeMethod('tokens.get_all_tokens');
    return result?.cast<String, String>() ?? {};
  }

  @override
  Future setToken({required String token, required String provider}) async {
    await CourierFlutterChannels.shared.invokeMethod('tokens.set_token', {
      'token': token,
      'provider': provider,
    });
  }

  @override
  Future setTokenForProvider({required String token, required CourierPushProvider provider}) async {
    return setToken(token: token, provider: provider.value);
  }

  @override
  Future<String?> getToken({required String provider}) async {
    return await CourierFlutterChannels.shared.invokeMethod('tokens.get_token', {
      'provider': provider,
    });
  }

  @override
  Future<String?> getTokenForProvider({required CourierPushProvider provider}) async {
    return await CourierFlutterChannels.shared.invokeMethod('tokens.get_token', {
      'provider': provider.value,
    });
  }

  @override
  Future<CourierPushListener> addPushListener({
    required Function(dynamic message)? onPushDelivered,
    Function(dynamic message)? onPushClicked,
  }) async {
    final listenerId = const Uuid().v4();
    final listener = CourierPushListener(
      listenerId: listenerId,
      onPushDelivered: onPushDelivered,
      onPushClicked: onPushClicked,
    );
    _pushListeners[listener.listenerId] = listener;

    // iOS or Android: check if there's a "clicked" push
    await Courier.getClickedNotification();
    return listener;
  }

  @override
  void removePushListener({required String listenerId}) {
    _pushListeners.remove(listenerId);
  }

  @override
  void removeAllPushListeners() {
    _pushListeners.clear();
  }

  // Inbox

  @override
  Future<int> get inboxPaginationLimit async {
    final result = await CourierFlutterChannels.shared.invokeMethod('inbox.get_pagination_limit');
    return result ?? 32;
  }

  @override
  Future setInboxPaginationLimit({required int limit}) async {
    await CourierFlutterChannels.shared.invokeMethod('inbox.set_pagination_limit', {
      'limit': limit,
    });
  }

  /// Because the native code no longer provides "inbox.get_feed_messages" or
  /// "inbox.get_archived_messages", we remove those calls. The user is
  /// expected to rely on the "inbox.listener_messages_changed" callback
  /// and/or the incremental fetch "fetchNextInboxPage()" below.

  @override
  Future refreshInbox() async {
    await CourierFlutterChannels.shared.invokeMethod('inbox.refresh');
  }

  @override
  Future<InboxMessageSet?> fetchNextInboxPage({required InboxFeed feed}) async {
    final dynamic response = await CourierFlutterChannels.shared.invokeMethod('inbox.fetch_next_page', {
      'feed': feed.value,
    });

    if (response == null) return null;

    try {
      final Map<String, dynamic> responseMap = Map<String, dynamic>.from(response);
      
      final List<dynamic> rawMessages = responseMap['messages'] as List<dynamic>;
      final messages = rawMessages.map((m) => InboxMessage.fromJson(jsonDecode(m))).toList();
      
      final int totalCount = responseMap['totalCount'] as int;
      final bool canPaginate = responseMap['canPaginate'] as bool;
      final String? paginationCursor = responseMap['paginationCursor'] as String?;

      return InboxMessageSet(
        messages: messages,
        canPaginate: canPaginate,
        totalCount: totalCount,
        paginationCursor: paginationCursor,
      );

    } catch (e) {
      Courier.log('Error decoding fetchNextInboxPage: $e');
      return null;
    }
  }
  
  @override
  Future<CourierInboxListener> addInboxListener({
    Function(bool isRefresh)? onLoading,
    Function(String error)? onError,
    Function(int unreadCount)? onUnreadCountChanged,
    Function(InboxFeed feed, int totalCount)? onTotalCountChanged,
    Function(List<InboxMessage> messages, bool canPaginate, InboxFeed feed)? onMessagesChanged,
    Function(List<InboxMessage> messages, bool canPaginate, bool isFirstPage, InboxFeed feed)? onPageAdded,
    Function(InboxMessage message, int index, InboxFeed feed, InboxMessageEvent event)? onMessageEvent,
  }) async {
    final listenerId = const Uuid().v4();

    // Create flutter listener
    final listener = CourierInboxListener(
      listenerId: listenerId,
      onLoading: onLoading,
      onError: onError,
      onUnreadCountChanged: onUnreadCountChanged,
      onTotalCountChanged: onTotalCountChanged,
      onMessagesChanged: onMessagesChanged,
      onPageAdded: onPageAdded,
      onMessageEvent: onMessageEvent,
    );

    // Hold reference
    _inboxListeners[listenerId] = listener;

    // Register native listener
    await CourierFlutterChannels.shared.invokeMethod('inbox.add_listener', {
      'listenerId': listenerId,
    });

    return listener;
  }

  @override
  Future removeInboxListener({required String listenerId}) async {
    await CourierFlutterChannels.shared.invokeMethod('inbox.remove_listener', {
      'listenerId': listenerId,
    });
    _inboxListeners.remove(listenerId);
  }

  @override
  Future removeAllInboxListeners() async {
    // Note: The native method is "inbox.remove_all_listeners",
    // so ensure your Swift matches that name.
    await CourierFlutterChannels.shared.invokeMethod('inbox.remove_all_listeners');
    _inboxListeners.clear();
  }

  @override
  Future openMessage({required String messageId}) async {
    await CourierFlutterChannels.shared.invokeMethod('inbox.open_message', {
      'messageId': messageId,
    });
  }

  @override
  Future readMessage({required String messageId}) async {
    await CourierFlutterChannels.shared.invokeMethod('inbox.read_message', {
      'messageId': messageId,
    });
  }

  @override
  Future unreadMessage({required String messageId}) async {
    await CourierFlutterChannels.shared.invokeMethod('inbox.unread_message', {
      'messageId': messageId,
    });
  }

  @override
  Future clickMessage({required String messageId}) async {
    await CourierFlutterChannels.shared.invokeMethod('inbox.click_message', {
      'messageId': messageId,
    });
  }

  @override
  Future archiveMessage({required String messageId}) async {
    await CourierFlutterChannels.shared.invokeMethod('inbox.archive_message', {
      'messageId': messageId,
    });
  }

  @override
  Future readAllInboxMessages() async {
    await CourierFlutterChannels.shared.invokeMethod('inbox.read_all_messages');
  }
}

// --------------------------
// CourierChannelManager
// --------------------------

abstract class CourierChannelManager extends PlatformInterface {
  
  CourierChannelManager({required super.token});

  // Client

  Future<CourierClient?> get client => throw UnimplementedError('client has not been implemented.');

  // Authentication

  Future<String?> get userId => throw UnimplementedError('userId has not been implemented.');
  Future<String?> get tenantId => throw UnimplementedError('tenantId has not been implemented.');
  Future<bool> get isUserSignedIn => throw UnimplementedError('isUserSignedIn has not been implemented.');

  Future signOut() async {
    throw UnimplementedError('signOut() has not been implemented.');
  }

  Future signIn({ required String userId, required String accessToken, String? clientKey, String? tenantId, bool? showLogs }) async {
    throw UnimplementedError('signIn() has not been implemented.');
  }

  Future<CourierAuthenticationListener> addAuthenticationListener(Function(String? userId) onUserStateChanged) async {
    throw UnimplementedError('addAuthenticationListener() has not been implemented.');
  }

  Future removeAuthenticationListener({ required String listenerId }) async {
    throw UnimplementedError('removeAuthenticationListener() has not been implemented.');
  }

  Future removeAllAuthenticationListeners() async {
    throw UnimplementedError('removeAllAuthenticationListeners() has not been implemented.');
  }

  // Push & Tokens

  Future<String?> get apnsToken => throw UnimplementedError('apnsToken has not been implemented.');
  Future<String?> get fcmToken => throw UnimplementedError('fcmToken has not been implemented.');
  Future<Map<String, String>> get tokens => throw UnimplementedError('tokens has not been implemented.');

  Future setToken({required String token, required String provider}) async {
    throw UnimplementedError('setToken() has not been implemented.');
  }

  Future setTokenForProvider({required String token, required CourierPushProvider provider}) async {
    throw UnimplementedError('setTokenForProvider() has not been implemented.');
  }

  Future<String?> getToken({required String provider}) async {
    throw UnimplementedError('getToken() has not been implemented.');
  }

  Future<String?> getTokenForProvider({required CourierPushProvider provider}) async {
    throw UnimplementedError('getTokenForProvider() has not been implemented.');
  }

  Future<CourierPushListener> addPushListener({required Function(dynamic message)? onPushDelivered, Function(dynamic message)? onPushClicked}) async {
    throw UnimplementedError('addPushListener() has not been implemented.');
  }

  void removePushListener({required String listenerId}) {
    throw UnimplementedError('removePushListener() has not been implemented.');
  }

  void removeAllPushListeners() async {
    throw UnimplementedError('removeAllPushListeners() has not been implemented.');
  }

  // Inbox

  Future<int> get inboxPaginationLimit => throw UnimplementedError('inboxPaginationLimit has not been implemented.');

  Future setInboxPaginationLimit({required int limit}) async {
    throw UnimplementedError('setInboxPaginationLimit() has not been implemented.');
  }

  Future<List<InboxMessage>> get feedMessages => throw UnimplementedError('feedMessages has not been implemented.');
  Future<List<InboxMessage>> get archivedMessages => throw UnimplementedError('archivedMessages has not been implemented.');

  Future refreshInbox() async {
    throw UnimplementedError('refreshInbox() has not been implemented.');
  }

  Future<InboxMessageSet?> fetchNextInboxPage({required InboxFeed feed}) async {
    throw UnimplementedError('fetchNextInboxPage() has not been implemented.');
  }

  Future<CourierInboxListener> addInboxListener({
    Function(bool isRefresh)? onLoading,
    Function(String error)? onError,
    Function(int unreadCount)? onUnreadCountChanged,
    Function(InboxFeed feed, int totalCount)? onTotalCountChanged,
    Function(List<InboxMessage> messages, bool canPaginate, InboxFeed feed)? onMessagesChanged,
    Function(List<InboxMessage> messages, bool canPaginate, bool isFirstPage, InboxFeed feed)? onPageAdded,
    Function(InboxMessage message, int index, InboxFeed feed, InboxMessageEvent event)? onMessageEvent,
  }) async {
    throw UnimplementedError('addInboxListener() has not been implemented.');
  }

  Future removeInboxListener({required String listenerId}) async {
    throw UnimplementedError('removeInboxListener() has not been implemented.');
  }

  Future removeAllInboxListeners() async {
    throw UnimplementedError('removeAllInboxListeners() has not been implemented.');
  }

  Future openMessage({required String messageId}) async {
    throw UnimplementedError('openMessage() has not been implemented.');
  }

  Future readMessage({required String messageId}) async {
    throw UnimplementedError('readMessage() has not been implemented.');
  }

  Future unreadMessage({required String messageId}) async {
    throw UnimplementedError('unreadMessage() has not been implemented.');
  }

  Future clickMessage({required String messageId}) async {
    throw UnimplementedError('clickMessage() has not been implemented.');
  }

  Future archiveMessage({required String messageId}) async {
    throw UnimplementedError('archiveMessage() has not been implemented.');
  }

  Future readAllInboxMessages() async {
    throw UnimplementedError('readAllMessages() has not been implemented.');
  }

}