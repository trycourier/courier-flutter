import 'package:flutter_test/flutter_test.dart';
import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/courier_flutter_platform_interface.dart';
import 'package:courier_flutter/courier_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCourierFlutterPlatform
    with MockPlatformInterfaceMixin
    implements CourierFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CourierFlutterPlatform initialPlatform = CourierFlutterPlatform.instance;

  test('$MethodChannelCourierFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCourierFlutter>());
  });

  test('getPlatformVersion', () async {
    Courier courierFlutterPlugin = Courier();
    MockCourierFlutterPlatform fakePlatform = MockCourierFlutterPlatform();
    CourierFlutterPlatform.instance = fakePlatform;

    expect(await courierFlutterPlugin.getPlatformVersion(), '42');
  });
}
