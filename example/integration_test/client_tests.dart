import 'package:courier_flutter/models/courier_device.dart';
import 'package:courier_flutter_sample/env.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';

import 'client_builder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final userId = const Uuid().v1();

  group('Client Tests', () {
    test('Options are setup', () async {
      final client = await ClientBuilder.build(userId: userId);
      final options = client.options;
      expect(options.userId, userId);
    });
  });

  group('Brand Tests', () {
    test('Get Brand', () async {
      final client = await ClientBuilder.build(userId: userId);
      final res = await client.brands.getBrand(id: Env.brandId);
      expect(res.data?.brand, isNotNull);
      expect(res.data?.brand?.settings?.inapp?.showCourierFooter, false);
    });
  });

  group('Token Management Tests', () {
    test('Put Token', () async {
      final client = await ClientBuilder.build(userId: userId);
      await client.tokens.putUserToken(
        token: 'example_token',
        provider: 'firebase-fcm',
      );
    });
    test('Put Token with Device', () async {
      final client = await ClientBuilder.build(userId: userId);
      final device = CourierDevice(appId: 'example_app_id');
      await client.tokens.putUserToken(
        token: 'example_token',
        provider: 'firebase-fcm',
        device: device,
      );
    });
    test('Delete Token', () async {
      final client = await ClientBuilder.build(userId: userId);
      final device = CourierDevice(appId: 'example_app_id');
      await client.tokens.putUserToken(
        token: 'example_token',
        provider: 'firebase-fcm',
        device: device,
      );
    });
  });
}
