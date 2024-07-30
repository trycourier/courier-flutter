import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:courier_flutter/courier_client.dart';

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Courier Client Integration Tests', () {

    setUp(() {
      // TODO
    });

    test('getPlatformVersion', () async {

      final client = CourierClient(apiKey: "example");

      final message = await client.getPlatformVersion();

      expect(message, 'Something');

    });

  });

}