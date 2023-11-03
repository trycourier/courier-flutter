import 'dart:async';

import 'package:courier_flutter/channels/core_platform_interface.dart';
import 'package:courier_flutter/channels/events_platform_interface.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/notification_permission_status.dart';
import 'package:flutter/foundation.dart';
import 'courier_provider.dart';
import 'ios_foreground_notification_presentation_options.dart';

class Courier {

  Courier._() {
    // Set debugging mode to default if app is debugging
    isDebugging = kDebugMode;

    // Set the default iOS presentation options
    iOSForegroundNotificationPresentationOptions = _iOSForegroundNotificationPresentationOptions;

    // Register listeners for when the native system receives messages
    CourierFlutterEventsPlatform.instance.registerMessagingListeners(
      onPushNotificationDelivered: (message) => _onPushNotificationDelivered?.call(message),
      onPushNotificationClicked: (message) => _onPushNotificationClicked?.call(message),
      onLogPosted: (log) => {
        /* Empty for now. Flutter will automatically print to console */
      },
    );
  }

  // Singleton
  static Courier? _instance;

  static Courier get shared => _instance ??= Courier._();

  /// Called if set and a push notification is delivered while the app
  /// Is in the foreground on iOS and "background" / foreground on Android
  Function(dynamic message)? _onPushNotificationDelivered;

  set onPushNotificationDelivered(Function(dynamic message)? listener) {
    _onPushNotificationDelivered = listener;
  }

  /// Called if set and a user clicked on a push notification
  /// Will automatically get called the first time your app starts
  /// and the user clicked on a push notification to launch your app
  Function(dynamic message)? _onPushNotificationClicked;

  set onPushNotificationClicked(Function(dynamic message)? listener) {
    _onPushNotificationClicked = listener;
    CourierFlutterEventsPlatform.instance.getClickedNotification();
  }

  /// Allows you to show or hide Courier Native SDK debugging logs
  /// You likely want this to match your development environment debugging mode
  bool _isDebugging = kDebugMode;

  bool get isDebugging => _isDebugging;

  set isDebugging(bool isDebugging) {
    CourierFlutterCorePlatform.instance.isDebugging(isDebugging);
    _isDebugging = isDebugging;
  }

  /// Allows you to set how you would like the iOS SDK to handle
  /// showing a push notification when it is received while the app is in the foreground.
  /// This will not have an affect on any other platform
  /// If you do not not want a system push to appear, pass []
  List<iOSNotificationPresentationOption> _iOSForegroundNotificationPresentationOptions = iOSNotificationPresentationOption.values;

  List<iOSNotificationPresentationOption>
  get iOSForegroundNotificationPresentationOptions => _iOSForegroundNotificationPresentationOptions;
  set iOSForegroundNotificationPresentationOptions(List<iOSNotificationPresentationOption> options) {
    CourierFlutterEventsPlatform.instance.iOSForegroundPresentationOptions(options);
    _iOSForegroundNotificationPresentationOptions = options;
  }

  /// Returns the currently stored userId in the native SDK
  Future<String?> get userId => CourierFlutterCorePlatform.instance.userId();

  /// Returns the currently stored apns token in the native SDK
  /// If you sign out, this value may still be set so that you can
  /// pass it to the next signed in userId
  Future<String?> get apnsToken => CourierFlutterCorePlatform.instance.apnsToken();

  /// Returns the currently stored fcm token in the native SDK
  /// If you sign out, this value may still be set so that you can
  /// pass it to the next signed in userId
  Future<String?> get fcmToken => CourierFlutterCorePlatform.instance.fcmToken();

  /// Sets the current FCM token in Courier Token Management
  /// Mostly used for handling the iOS Firebase SDK
  Future setFcmToken({required String token}) {
    return CourierFlutterCorePlatform.instance.setFcmToken(token);
  }

  /// Stores the current user credentials in native level storage.
  /// You likely want to be calling this where you normally manage your user's state.
  /// This will persist across app sessions so that messages
  /// are associated with the correct user.
  /// Be sure to call `signOut()` when you want to remove the user credentials.
  Future signIn({ required String accessToken, required String userId, String? clientKey }) {
    return CourierFlutterCorePlatform.instance.signIn(accessToken, userId, clientKey);
  }

  /// Removed native level locally stored values for the user and access token
  /// Will also delete the current apns / fcm tokens in Courier token management
  /// So your user does not receive notifications if they are not signed in
  Future signOut() {
    return CourierFlutterCorePlatform.instance.signOut();
  }

  Future<CourierInboxListener> addInboxListener([Function? onInitialLoad, Function(dynamic error)? onError, Function(List<dynamic> messages, int unreadMessageCount, int totalMessageCount, bool canPaginate)? onMessagesChanged]) {
    return CourierFlutterCorePlatform.instance.addInboxListener(onInitialLoad, onError, onMessagesChanged);
  }

  Future<String> removeInboxListener({ required String id }) {
    return CourierFlutterCorePlatform.instance.removeInboxListener(id: id);
  }

  Future<int> setInboxPaginationLimit({ required int limit }) {
    return CourierFlutterCorePlatform.instance.setInboxPaginationLimit(limit: limit);
  }

  Future<List> fetchNextPageOfMessages() {
    return CourierFlutterCorePlatform.instance.fetchNextPageOfMessages();
  }

  Future readMessage({ required String id }) {
    return CourierFlutterCorePlatform.instance.readMessage(id: id);
  }

  Future unreadMessage({ required String id }) {
    return CourierFlutterCorePlatform.instance.unreadMessage(id: id);
  }

  Future readAllInboxMessages() {
    return CourierFlutterCorePlatform.instance.readAllInboxMessages();
  }

  Future<dynamic> getUserPreferences({ String? paginationCursor }) {
    return CourierFlutterCorePlatform.instance.getUserPreferences(paginationCursor: paginationCursor);
  }

  Future<dynamic> getUserPreferencesTopic({ required String topicId }) {
    return CourierFlutterCorePlatform.instance.getUserPreferencesTopic(topicId: topicId);
  }

  Future<dynamic> putUserPreferencesTopic({ required String topicId, required String status, required bool hasCustomRouting, required List<String> customRouting }) {
    return CourierFlutterCorePlatform.instance.putUserPreferencesTopic(topicId: topicId, status: status, hasCustomRouting: hasCustomRouting, customRouting: customRouting);
  }

  /// Requests notification permission from your user (the popup dialog)
  /// You should call this where it makes the most sense for the user experience you are building
  /// Android does NOT support this feature yet due to Android AppCompatActivity limitations
  Future<NotificationPermissionStatus> requestNotificationPermission() async {
    final status = await CourierFlutterEventsPlatform.instance.requestNotificationPermission();
    return status.permissionStatus;
  }

  /// Returns the current push notification permission status
  /// Does not present a popup dialog to your user
  Future<NotificationPermissionStatus> getNotificationPermissionStatus() async {
    final status = await CourierFlutterEventsPlatform.instance.getNotificationPermissionStatus();
    return status.permissionStatus;
  }

  /// Show a log to the console
  static void log(String message) {
    if (Courier.shared._isDebugging) {
      print(message);
    }
  }

}
