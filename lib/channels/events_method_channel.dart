import 'dart:io';

import 'package:courier_flutter/channels/events_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../ios_foreground_notification_presentation_options.dart';

/// An implementation of [EventsChannelCourierFlutter] that uses method channels.
class EventsChannelCourierFlutter extends CourierFlutterEventsPlatform {

  @visibleForTesting
  final channel = const MethodChannel('courier_flutter_events');

  @override
  Future<String> requestNotificationPermission() async {

    try {
      return await channel.invokeMethod('requestNotificationPermission');
    } catch (error) {
      return 'unknown';
    }

  }

  @override
  Future<String> getNotificationPermissionStatus() async {

    try {
      return await channel.invokeMethod('getNotificationPermissionStatus');
    } catch (error) {
      return 'unknown';
    }

  }

  @override
  Future getClickedNotification() async {

    try {
      return await channel.invokeMethod('getClickedNotification');
    } catch (error) {
      return;
    }

  }

  @override
  Future iOSForegroundPresentationOptions(List<iOSNotificationPresentationOption> options) async {

    // Skip other platforms. Do not show error
    if (!Platform.isIOS) return;

    try {
      return await channel.invokeMethod('shared.push.set_ios_foreground_presentation_options', {
        'options': options.map((option) => option.value).toList(),
      });
    } catch (error) {
      return [];
    }

  }

  @override
  registerMessagingListeners({ required Function(dynamic message) onPushNotificationDelivered, required Function(dynamic message) onPushNotificationClicked, required Function(dynamic log) onLogPosted }) {
    channel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'log': {
          onLogPosted.call(call.arguments);
          break;
        }
        case 'pushNotificationDelivered': {
          onPushNotificationDelivered.call(call.arguments);
          break;
        }
        case 'pushNotificationClicked': {
          onPushNotificationClicked.call(call.arguments);
          break;
        }
      }
      return Future.value();
    });
  }

}
