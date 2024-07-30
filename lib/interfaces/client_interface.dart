import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class CourierClientInterface extends PlatformInterface {

  /// Creates the module and gives it an id
  CourierClientInterface() : super(token: _token);
  static final Object _token = Object();

  /// Returns the instance of the module
  static CourierClientInterface get instance => _instance;
  static CourierClientInterface _instance = CourierClientChannel();
  static set instance(CourierClientInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> getPlatformVersion() async {
    throw UnimplementedError('getPlatformVersion() has not been implemented.');
  }

}

class CourierClientChannel extends CourierClientInterface {

  @visibleForTesting
  final channel = const MethodChannel('courier_flutter_core');

  @override
  Future<String> getPlatformVersion() async {
    return await channel.invokeMethod('getPlatformVersion');
  }

}