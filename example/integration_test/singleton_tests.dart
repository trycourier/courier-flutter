import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter_sample/env.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';

import 'example_server.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final userId = const Uuid().v1();

  Future<String> sendMessage(String userId) {
    return ExampleServer.sendTest(Env.authKey, userId, "inbox");
  }

  Future delay({int milliseconds = 5000}) {
    return Future.delayed(Duration(milliseconds: milliseconds));
  }

  group('Authentication', () {

    setUp(() async {
      await Courier.shared.signOut();
    });

    test('Sign Out', () async {
      await Courier.shared.signOut();
      final currentUserId = await Courier.shared.userId;
      final currentTenantId = await Courier.shared.tenantId;
      expect(currentUserId, isNull);
      expect(currentTenantId, isNull);
    });

    test('Sign In', () async {

      final jwt = await ExampleServer.generateJwt(Env.authKey, userId);
      await Courier.shared.signIn(
          userId: userId,
          accessToken: jwt,
          clientKey: Env.clientKey,
      );

      final currentUserId = await Courier.shared.userId;
      final currentTenantId = await Courier.shared.tenantId;
      expect(currentUserId, isNull);
      expect(currentTenantId, isNull);

    });

  });

}