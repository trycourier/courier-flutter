import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:courier_flutter/channels/courier_flutter_core_method_channel.dart';

void main() {
  CoreChannelCourierFlutter platform = CoreChannelCourierFlutter();
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
    expect(await platform.userId(), null);
  });
}
