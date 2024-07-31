import 'package:courier_flutter/courier_client.dart';
import 'package:courier_flutter_sample/env.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';

import 'client_builder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Client Tests', () {

    test('Options are setup', () async {

      final userId = const Uuid().v1();
      final client = await ClientBuilder.build(userId: userId);

      final options = client.options;
      expect(options.userId, userId);

    });

  });

  group('Brand Tests', () {

    test('Get Brand', () async {

      final userId = const Uuid().v1();
      final client = await ClientBuilder.build(userId: userId);

      final res = await client.brands.getBrand(id: Env.brandId);
      expect(res.data?.brand, isNotNull);
      expect(res.data?.brand?.settings?.inapp?.showCourierFooter, false);

    });

  });

}
