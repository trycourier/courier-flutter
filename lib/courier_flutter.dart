import 'package:flutter/foundation.dart';
import 'courier_flutter_core_platform_interface.dart';
import 'courier_flutter_events_platform_interface.dart';
import 'courier_provider.dart';
import 'ios_foreground_notification_presentation_options.dart';

class Courier {

  Function(dynamic message)? _onPushNotificationDelivered;
  set onPushNotificationDelivered(Function(dynamic message)? listener) {
    _onPushNotificationDelivered = listener;
  }

  // When registering the push notification click listener
  // The Flutter SDK will check to see if the native platform has a notification waiting for it
  Function(dynamic message)? _onPushNotificationClicked;
  set onPushNotificationClicked(Function(dynamic message)? listener) {
    _onPushNotificationClicked = listener;
    CourierFlutterEventsPlatform.instance.getClickedNotification();
  }

  Courier._() {

    // Set debugging mode to default if app is debugging
    isDebugging = kDebugMode;

    // Set the default iOS presentation options
    iOSForegroundNotificationPresentationOptions = _iOSForegroundNotificationPresentationOptions;

    // Register listeners for when the native system receives messages
    CourierFlutterEventsPlatform.instance.registerMessagingListeners(
        onPushNotificationDelivered: (message) => _onPushNotificationDelivered?.call(message),
        onPushNotificationClicked: (message) => _onPushNotificationClicked?.call(message),
        onLogPosted: (log) => { /* Empty for now. Does support receiving logs */ },
    );

  }

  static Courier? _instance;
  static Courier get shared => _instance ??= Courier._();

  bool _isDebugging = kDebugMode;
  bool get isDebugging => _isDebugging;
  set isDebugging(bool isDebugging) {
    CourierFlutterCorePlatform.instance.isDebugging(isDebugging);
    _isDebugging = isDebugging;
  }

  // Default presentation will use all available values
  // Pass [] if you do not want this to be used
  List<iOSNotificationPresentationOption> _iOSForegroundNotificationPresentationOptions = iOSNotificationPresentationOption.values;
  List<iOSNotificationPresentationOption> get iOSForegroundNotificationPresentationOptions => _iOSForegroundNotificationPresentationOptions;
  set iOSForegroundNotificationPresentationOptions(List<iOSNotificationPresentationOption> options) {
    CourierFlutterEventsPlatform.instance.iOSForegroundPresentationOptions(options);
    _iOSForegroundNotificationPresentationOptions = options;
  }

  Future<String?> get userId => CourierFlutterCorePlatform.instance.userId();

  Future<String?> get apnsToken => CourierFlutterCorePlatform.instance.apnsToken();

  Future<String?> get fcmToken => CourierFlutterCorePlatform.instance.fcmToken();

  Future setFcmToken({ required String token }) {
    return CourierFlutterCorePlatform.instance.setFcmToken(token);
  }

  // Will save a persistent reference to the accessToken and userId you provide
  // This will be available between app sessions
  // You must call signOut to remove these references
  Future signIn({ required String accessToken, required String userId }) {
    return CourierFlutterCorePlatform.instance.signIn(accessToken, userId);
  }

  Future signOut() {
    return CourierFlutterCorePlatform.instance.signOut();
  }

  Future<String> requestNotificationPermission() {
    return CourierFlutterEventsPlatform.instance.requestNotificationPermission();
  }

  Future<String> getNotificationPermissionStatus() {
    return CourierFlutterEventsPlatform.instance.getNotificationPermissionStatus();
  }

  Future<String> sendPush({ required String authKey, required String userId, required String title, required String body, required bool isProduction, required List<CourierProvider> providers }) {
    return CourierFlutterCorePlatform.instance.sendPush(authKey, userId, title, body, isProduction, providers);
  }

}
