import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'courier_flutter_events_method_channel.dart';

abstract class CourierFlutterEventsPlatform extends PlatformInterface {

  CourierFlutterEventsPlatform() : super(token: _token);
  static final Object _token = Object();
  static CourierFlutterEventsPlatform _instance = EventsChannelCourierFlutter();

  /// The default instance of [CourierFlutterEventsPlatform] to use.
  ///
  /// Defaults to [CourierFlutterEventsPlatform].
  static CourierFlutterEventsPlatform get instance => _instance;

  static set instance(CourierFlutterEventsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> requestNotificationPermission() async {
    throw UnimplementedError('requestNotificationPermission() has not been implemented.');
  }

  Future getClickedNotification() async {
    throw UnimplementedError('getClickedNotification() has not been implemented.');
  }

  registerMessagingListeners({ required Function(dynamic message) onPushNotificationDelivered, required Function(dynamic message) onPushNotificationClicked, required Function(dynamic log) onLogPosted }) {
    throw UnimplementedError('registerMessagingListeners() has not been implemented.');
  }

}
