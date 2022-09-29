import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'courier_flutter_core_method_channel.dart';

abstract class CourierFlutterPlatform extends PlatformInterface {
  /// Constructs a CourierFlutterPlatform.
  CourierFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static CourierFlutterPlatform _instance = CoreChannelCourierFlutter();

  /// The default instance of [CourierFlutterPlatform] to use.
  ///
  /// Defaults to [CoreChannelCourierFlutter].
  static CourierFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CourierFlutterPlatform] when
  /// they register themselves.
  static set instance(CourierFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> userId() {
    throw UnimplementedError('userId() has not been implemented.');
  }

  Future<String?> fcmToken() {
    throw UnimplementedError('fcmToken() has not been implemented.');
  }

  Future setFcmToken(String token) {
    throw UnimplementedError('setFcmToken() has not been implemented.');
  }

  Future signIn(String accessToken, String userId) {
    throw UnimplementedError('signIn() has not been implemented.');
  }

  Future signOut() {
    throw UnimplementedError('signOut() has not been implemented.');
  }

  Future<String> sendPush(String authKey, String userId, String title, String body) {
    throw UnimplementedError('sendPush() has not been implemented.');
  }

  Future getClickedNotification() {
    throw UnimplementedError('getClickedNotification() has not been implemented.');
  }

}
