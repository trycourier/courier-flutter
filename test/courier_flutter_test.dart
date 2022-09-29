import 'package:flutter_test/flutter_test.dart';
import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/courier_flutter_core_platform_interface.dart';
import 'package:courier_flutter/courier_flutter_core_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCourierFlutterPlatform
    with MockPlatformInterfaceMixin
    implements CourierFlutterCorePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CourierFlutterCorePlatform initialPlatform = CourierFlutterCorePlatform.instance;

  test('$CoreChannelCourierFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<CoreChannelCourierFlutter>());
  });

  test('getPlatformVersion', () async {
    Courier courierFlutterPlugin = Courier();
    MockCourierFlutterPlatform fakePlatform = MockCourierFlutterPlatform();
    CourierFlutterCorePlatform.instance = fakePlatform;

    expect(await courierFlutterPlugin.getPlatformVersion(), '42');
  });
}
