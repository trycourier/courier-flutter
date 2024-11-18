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

    // Attach events listeners
    CourierFlutterChannels.events.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'auth.state_changed': {
          String? userId = call.arguments['userId'];
          _authenticationListeners.forEach((key, listener) {
            listener.onUserStateChanged(userId);
          });
          break;
        }
        case 'push.clicked': {
          _pushListeners.forEach((key, listener) {
            listener.onPushClicked?.call(call.arguments);
          });
          break;
        }
        case 'push.delivered': {
          _pushListeners.forEach((key, listener) {
            listener.onPushDelivered?.call(call.arguments);
          });
          break;
        }
        case 'inbox.listener_loading': {
          _inboxListeners.forEach((key, listener) {
            listener.onLoading?.call();
          });
          break;
        }
        case 'inbox.listener_error': {
          _inboxListeners.forEach((key, listener) {
            listener.onError?.call(call.arguments['error']);
          });
          break;
        }
        case 'inbox.listener_unread_count_changed': {
          final count = call.arguments['count'];
          _inboxListeners.forEach((key, listener) {
            listener.onUnreadCountChanged?.call(count);
          });
          break;
        }
        case 'inbox.listener_feed_changed': {
          final json = jsonDecode(call.arguments['messageSet']);
          final messageSet = InboxMessageSet.fromJson(json);
          _inboxListeners.forEach((key, listener) {
            listener.onFeedChanged?.call(messageSet);
          });
          break;
        }
        case 'inbox.listener_archive_changed': {
          final json = jsonDecode(call.arguments['messageSet']);
          final messageSet = InboxMessageSet.fromJson(json);
          _inboxListeners.forEach((key, listener) {
            listener.onArchiveChanged?.call(messageSet);
          });
          break;
        }
        case 'inbox.listener_page_added': {
          final feed = InboxFeed.fromValue(call.arguments['feed']);
          final json = jsonDecode(call.arguments['page']);
          final page = InboxMessageSet.fromJson(json);
          _inboxListeners.forEach((key, listener) {
            listener.onPageAdded?.call(feed, page);
          });
          break;
        }
        case 'inbox.listener_message_changed': {
          final feed = InboxFeed.fromValue(call.arguments['feed']);
          final index = call.arguments['index'];
          final json = jsonDecode(call.arguments['message']);
          final message = InboxMessage.fromJson(json);
          _inboxListeners.forEach((key, listener) {
            listener.onMessageChanged?.call(feed, index, message);
          });
          break;
        }
        case 'inbox.listener_message_added': {
          final feed = InboxFeed.fromValue(call.arguments['feed']);
          final index = call.arguments['index'];
          final json = jsonDecode(call.arguments['message']);
          final message = InboxMessage.fromJson(json);
          _inboxListeners.forEach((key, listener) {
            listener.onMessageAdded?.call(feed, index, message);
          });
          break;
        }
        case 'inbox.listener_message_removed': {
          final feed = InboxFeed.fromValue(call.arguments['feed']);
          final index = call.arguments['index'];
          final json = jsonDecode(call.arguments['message']);
          final message = InboxMessage.fromJson(json);
          _inboxListeners.forEach((key, listener) {
            listener.onMessageRemoved?.call(feed, index, message);
          });
          break;
        }
      }
    });

  }

  // Debugging

  /// Allows you to show or hide Courier Native SDK debugging logs
  /// You likely want this to match your development environment debugging mode
  bool _isDebugging = kDebugMode;

  // Show a log to the console
  static void log(String message) {
    if (Courier.shared._isDebugging) {
      print(message);
    }
  }

  // System (static)

  /// Allows you to set how you would like the iOS SDK to handle
  /// showing a push notification when it is received while the app is in the foreground.
  /// This will not have an affect on any other platform
  /// If you do not not want a system push to appear, pass []
  static List<iOSNotificationPresentationOption> _iOSForegroundNotificationPresentationOptions = iOSNotificationPresentationOption.values;
  static List<iOSNotificationPresentationOption> get iOSForegroundNotificationPresentationOptions => _iOSForegroundNotificationPresentationOptions;

  static Future<List<iOSNotificationPresentationOption>> setIOSForegroundPresentationOptions({required List<iOSNotificationPresentationOption> options}) async {

    // Skip other platforms. Do not show error
    if (!Platform.isIOS) return [];

    try {
      List<dynamic> newOptions = await CourierFlutterChannels.system.invokeMethod('ios.set_foreground_presentation_options', {
        'options': options.map((option) => option.value).toList(),
      });
      _iOSForegroundNotificationPresentationOptions = newOptions.map((option) => iOSNotificationPresentationOption.fromString(option)).toList();
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
    return options == null ? null : CourierClient(
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
  Future signIn({required String userId, required String accessToken, String? clientKey, String? tenantId, bool? showLogs}) async {
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
  Future<CourierAuthenticationListener> addAuthenticationListener(Function(String? userId) onUserStateChanged) async {
    final listenerId = const Uuid().v4();
    final listener = CourierAuthenticationListener(listenerId: listenerId, onUserStateChanged: onUserStateChanged);
    _authenticationListeners[listenerId] = listener;
    await CourierFlutterChannels.shared.invokeMethod('auth.add_authentication_listener', {
      'listenerId': listenerId
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
    if (!Platform.isIOS) { // TODO: Add macOS support in the future
      return null;
    }
    return await CourierFlutterChannels.shared.invokeMethod('tokens.get_apns_token');
  }

  @override
  Future<String?> get fcmToken async {
    if (!Platform.isAndroid) {
      return null;
    }
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
    await setToken(token: token, provider: provider.value);
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
  Future<CourierPushListener> addPushListener({required Function(dynamic message)? onPushDelivered, Function(dynamic message)? onPushClicked}) async {
    final listenerId = const Uuid().v4();
    final listener = CourierPushListener(listenerId: listenerId, onPushDelivered: onPushDelivered, onPushClicked: onPushClicked);
    _pushListeners[listener.listenerId] = listener;
    await Courier.getClickedNotification();
    return listener;
  }

  @override
  void removePushListener({required String listenerId}) {
    _pushListeners.remove(listenerId);
  }

  @override
  void removeAllPushListeners() {
    _authenticationListeners.clear();
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

  @override
  Future<List<InboxMessage>> get inboxMessages async {
    List<dynamic> messages = await CourierFlutterChannels.shared.invokeMethod('inbox.get_messages');
    List<InboxMessage>? inboxMessages = messages.map((message) => InboxMessage.fromJson(message)).toList();
    return inboxMessages;
  }

  @override
  Future refreshInbox() async {
    await CourierFlutterChannels.shared.invokeMethod('inbox.refresh');
  }

  @override
  Future<List<InboxMessage>> fetchNextInboxPage({required InboxFeed feed}) async {
    List<dynamic> messages = await CourierFlutterChannels.shared.invokeMethod('inbox.fetch_next_page', {
      'feed': feed.value,
    });
    return messages.map((message) {
      final Map<String, dynamic> map = json.decode(message);
      return InboxMessage.fromJson(map);
    }).toList();
  }

  @override
  Future<CourierInboxListener> addInboxListener({
    Function? onLoading,
    Function(String error)? onError,
    Function(int unreadCount)? onUnreadCountChanged, 
    Function(InboxMessageSet messageSet)? onFeedChanged,
    Function(InboxMessageSet messageSet)? onArchiveChanged,
    Function(InboxFeed feed, InboxMessageSet page)? onPageAdded,
    Function(InboxFeed feed, int index, InboxMessage message)? onMessageChanged,
    Function(InboxFeed feed, int index, InboxMessage message)? onMessageAdded,
    Function(InboxFeed feed, int index, InboxMessage message)? onMessageRemoved,
  }) async {

    final listenerId = const Uuid().v4();

    // Create flutter listener
    final listener = CourierInboxListener(
        listenerId: listenerId,
        onLoading: onLoading,
        onError: onError,
        onUnreadCountChanged: onUnreadCountChanged,
        onFeedChanged: onFeedChanged,
        onArchiveChanged: onArchiveChanged,
        onPageAdded: onPageAdded,
        onMessageChanged: onMessageChanged,
        onMessageAdded: onMessageAdded,
        onMessageRemoved: onMessageRemoved,
    );

    // Hold reference
    _inboxListeners[listenerId] = listener;

    // Register native listener
    await CourierFlutterChannels.shared.invokeMethod('inbox.add_listener', {
      'listenerId': listenerId
    });

    return listener;

  }

  @override
  Future removeInboxListener({required String listenerId}) async {
    await CourierFlutterChannels.shared.invokeMethod('inbox.remove_listener', {
      'listenerId': listenerId
    });
    _authenticationListeners.remove(listenerId);
  }

  @override
  Future removeAllInboxListeners() async {
    await CourierFlutterChannels.shared.invokeMethod('inbox.remove_all_inbox_listeners');
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

  Future<List<InboxMessage>> get inboxMessages => throw UnimplementedError('inboxMessages has not been implemented.');

  Future refreshInbox() async {
    throw UnimplementedError('refreshInbox() has not been implemented.');
  }

  Future<List<InboxMessage>> fetchNextInboxPage({required InboxFeed feed}) async {
    throw UnimplementedError('fetchNextInboxPage() has not been implemented.');
  }

  Future<CourierInboxListener> addInboxListener({
    Function? onLoading,
    Function(String error)? onError,
    Function(int unreadCount)? onUnreadCountChanged, 
    Function(InboxMessageSet messageSet)? onFeedChanged,
    Function(InboxMessageSet messageSet)? onArchiveChanged,
    Function(InboxFeed feed, InboxMessageSet page)? onPageAdded,
    Function(InboxFeed feed, int index, InboxMessage message)? onMessageChanged,
    Function(InboxFeed feed, int index, InboxMessage message)? onMessageAdded,
    Function(InboxFeed feed, int index, InboxMessage message)? onMessageRemoved,
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