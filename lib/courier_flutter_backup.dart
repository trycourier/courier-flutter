// import 'dart:async';
//
// import 'package:courier_flutter/channels/events_platform_interface.dart';
// import 'package:courier_flutter/channels/shared_method_channel.dart';
// import 'package:courier_flutter/courier_preference_channel.dart';
// import 'package:courier_flutter/courier_preference_status.dart';
// import 'package:courier_flutter/courier_provider.dart';
// import 'package:courier_flutter/models/courier_brand.dart';
// import 'package:courier_flutter/models/courier_inbox_listener.dart';
// import 'package:courier_flutter/models/courier_push_listener.dart';
// import 'package:courier_flutter/models/courier_user_preferences.dart';
// import 'package:courier_flutter/models/inbox_message.dart';
// import 'package:courier_flutter/notification_permission_status.dart';
// import 'package:flutter/foundation.dart';
// import 'ios_foreground_notification_presentation_options.dart';
//
// export 'models/inbox_message.dart';
// export 'models/inbox_action.dart';
//
// class Courier {
//
//   Courier._() {
//
//     // Set debugging mode to default if app is debugging
//     isDebugging = kDebugMode;
//
//     // Set the default iOS presentation options
//     iOSForegroundNotificationPresentationOptions = _iOSForegroundNotificationPresentationOptions;
//
//     // Register listeners for when the native system receives messages
//     CourierFlutterEventsPlatform.instance.registerMessagingListeners(
//       onPushNotificationDelivered: (message) {
//         _pushListeners.forEach((key, value) {
//           value.onPushDelivered?.call(message);
//         });
//       },
//       onPushNotificationClicked: (message) {
//         _pushListeners.forEach((key, value) {
//           value.onPushClicked?.call(message);
//         });
//       },
//       onLogPosted: (log) => {
//         /* Empty for now. Flutter will automatically print to console */
//       },
//     );
//
//   }
//
//   // Singleton
//   static Courier? _instance;
//
//   static Courier get shared => _instance ??= Courier._();
//
//   /// Allow multiple push event listeners
//   final Map<String, CourierPushListener> _pushListeners = {};
//
//   CourierPushListener addPushListener({ Function(dynamic message)? onPushDelivered, Function(dynamic message)? onPushClicked }) {
//     final listener = CourierPushListener.fromListeners(onPushDelivered, onPushClicked);
//     _pushListeners[listener.listenerId] = listener;
//     CourierFlutterEventsPlatform.instance.getClickedNotification();
//     return listener;
//   }
//
//   removePushListener({ required String id }) {
//     _pushListeners.remove(id);
//   }
//
//   /// Allows you to show or hide Courier Native SDK debugging logs
//   /// You likely want this to match your development environment debugging mode
//   bool _isDebugging = kDebugMode;
//
//   bool get isDebugging => _isDebugging;
//
//   set isDebugging(bool isDebugging) {
//     // CourierFlutterCorePlatform.instance.isDebugging(isDebugging);
//     _isDebugging = isDebugging;
//   }
//
//   /// Allows you to set how you would like the iOS SDK to handle
//   /// showing a push notification when it is received while the app is in the foreground.
//   /// This will not have an affect on any other platform
//   /// If you do not not want a system push to appear, pass []
//   List<iOSNotificationPresentationOption> _iOSForegroundNotificationPresentationOptions = iOSNotificationPresentationOption.values;
//
//   List<iOSNotificationPresentationOption>
//   get iOSForegroundNotificationPresentationOptions => _iOSForegroundNotificationPresentationOptions;
//   set iOSForegroundNotificationPresentationOptions(List<iOSNotificationPresentationOption> options) {
//     CourierFlutterEventsPlatform.instance.iOSForegroundPresentationOptions(options);
//     _iOSForegroundNotificationPresentationOptions = options;
//   }
//
//   /// Returns the currently stored ids in the native SDK
//   Future<String?> get userId => Courier2.shared.userId();
//   Future<String?> get tenantId => Courier2.shared.tenantId();
//
//   /// Returns the current token for a provider
//   Future<String?> getToken({ required String provider }) => Courier2.shared.getToken(provider: provider);
//   Future<String?> getTokenForProvider({ required CourierPushProvider provider }) => Courier2.shared.getToken(provider: provider.value);
//
//   /// Sets the current token for a provider
//   Future setToken({ required String provider, required String token }) => Courier2.shared.setToken(provider: provider, token: token);
//   Future setTokenForProvider({ required CourierPushProvider provider, required String token }) => Courier2.shared.setToken(provider: provider.value, token: token);
//
//   /// Stores the current user credentials in native level storage.
//   /// You likely want to be calling this where you normally manage your user's state.
//   /// This will persist across app sessions so that messages
//   /// are associated with the correct user.
//   /// Be sure to call `signOut()` when you want to remove the user credentials.
//   Future signIn({ required String userId, required String accessToken, String? clientKey, String? tenantId }) async {
//     await Courier2.shared.signIn(
//         userId: userId,
//         accessToken: accessToken,
//         clientKey: clientKey,
//         tenantId: tenantId,
//     );
//   }
//
//   /// Removes native level locally stored values for the user and access token
//   /// Will also delete the current apns / fcm tokens in Courier token management
//   /// So your user does not receive notifications if they are not signed in
//   Future signOut() async {
//     await Courier2.shared.signOut();
//   }
//
//   Future<CourierInboxListener> addInboxListener({ Function? onInitialLoad, Function(dynamic error)? onError, Function(List<InboxMessage> messages, int unreadMessageCount, int totalMessageCount, bool canPaginate)? onMessagesChanged }) {
//     return Courier2.shared.addInboxListener(onInitialLoad, onError, onMessagesChanged);
//   }
//
//   Future<String> removeInboxListener({ required String id }) {
//     return Courier2.shared.removeInboxListener(id: id);
//   }
//
//   Future<int> setInboxPaginationLimit({ required int limit }) {
//     return Courier2.shared.setInboxPaginationLimit(limit: limit);
//   }
//
//   Future refreshInbox() {
//     return Courier2.shared.refreshInbox();
//   }
//
//   Future<List<InboxMessage>> fetchNextPageOfMessages() {
//     return Courier2.shared.fetchNextPageOfMessages();
//   }
//
//   Future clickMessage({ required String id }) {
//     return Courier2.shared.clickMessage(id: id);
//   }
//
//   Future readMessage({ required String id }) {
//     return Courier2.shared.readMessage(id: id);
//   }
//
//   Future unreadMessage({ required String id }) {
//     return Courier2.shared.unreadMessage(id: id);
//   }
//
//   Future readAllInboxMessages() {
//     return Courier2.shared.readAllInboxMessages();
//   }
//
//   Future<CourierBrand?> getBrand({ required String id }) async {
//     final brand = await Courier2.shared.getBrand(id: id);
//     return brand != null ? CourierBrand.fromJson(brand) : null;
//   }
//
//   Future<CourierUserPreferences> getUserPreferences({ String? paginationCursor }) {
//     return Courier2.shared.getUserPreferences(paginationCursor: paginationCursor);
//   }
//
//   // Future<CourierUserPreferencesTopic> getUserPreferencesTopic({ required String topicId }) {
//   //   return CourierFlutterCorePlatform.instance.getUserPreferencesTopic(topicId: topicId);
//   // }
//
//   Future<dynamic> putUserPreferencesTopic({ required String topicId, required CourierUserPreferencesStatus status, required bool hasCustomRouting, required List<CourierUserPreferencesChannel> customRouting }) {
//     return Courier2.shared.putUserPreferencesTopic(topicId: topicId, status: status.value, hasCustomRouting: hasCustomRouting, customRouting: customRouting.map((e) => e.value).toList());
//   }
//
//   /// Requests notification permission from your user (the popup dialog)
//   /// You should call this where it makes the most sense for the user experience you are building
//   /// Android does NOT support this feature yet due to Android AppCompatActivity limitations
//   Future<NotificationPermissionStatus> requestNotificationPermission() async {
//     final status = await CourierFlutterEventsPlatform.instance.requestNotificationPermission();
//     return status.permissionStatus;
//   }
//
//   /// Returns the current push notification permission status
//   /// Does not present a popup dialog to your user
//   Future<NotificationPermissionStatus> getNotificationPermissionStatus() async {
//     final status = await CourierFlutterEventsPlatform.instance.getNotificationPermissionStatus();
//     return status.permissionStatus;
//   }
//
//   /// Show a log to the console
//   static void log(String message) {
//     if (Courier.shared._isDebugging) {
//       print(message);
//     }
//   }
//
// }