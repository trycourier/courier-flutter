import 'package:courier_flutter/courier_flutter_events_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An implementation of [EventsChannelCourierFlutter] that uses method channels.
class EventsChannelCourierFlutter extends CourierFlutterEventsPlatform {

  @visibleForTesting
  final channel = const MethodChannel('courier_flutter_events');

  @override
  Future<String> requestNotificationPermission() async {
    return await channel.invokeMethod('requestNotificationPermission');
  }

  @override
  Future<String> getNotificationPermissionStatus() async {
    return await channel.invokeMethod('getNotificationPermissionStatus');
  }

  @override
  Future getClickedNotification() async {
    return await channel.invokeMethod('getClickedNotification');
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
