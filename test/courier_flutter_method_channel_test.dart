import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:courier_flutter/courier_flutter_method_channel.dart';

void main() {
  MethodChannelCourierFlutter platform = MethodChannelCourierFlutter();
  const MethodChannel channel = MethodChannel('courier_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
