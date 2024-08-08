import 'package:courier_flutter/channels/shared_method_channel.dart';
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
      await CourierRC.shared.signOut();
    });

    test('Sign Out', () async {

      await CourierRC.shared.signOut();

      final currentUserId = await CourierRC.shared.userId;
      final currentTenantId = await CourierRC.shared.tenantId;
      final isUserSignedIn = await CourierRC.shared.isUserSignedIn;

      expect(currentUserId, isNull);
      expect(currentTenantId, isNull);
      expect(isUserSignedIn, false);

    });

    test('Sign In', () async {

      final jwt = await ExampleServer.generateJwt(Env.authKey, userId);

      await CourierRC.shared.signIn(
        userId: userId,
        accessToken: jwt,
        clientKey: Env.clientKey,
        showLogs: true,
      );

      final currentUserId = await CourierRC.shared.userId;
      final currentTenantId = await CourierRC.shared.tenantId;
      final isUserSignedIn = await CourierRC.shared.isUserSignedIn;
      expect(currentUserId, userId);
      expect(currentTenantId, isNull);
      expect(isUserSignedIn, true);

    });

    test('Authentication Listener', () async {

      var hold = true;

      final listener = await CourierRC.shared.addAuthenticationListener((userId) {
        hold = userId == null;
      });

      final jwt = await ExampleServer.generateJwt(Env.authKey, userId);

      await CourierRC.shared.signIn(
        userId: userId,
        accessToken: jwt,
        clientKey: Env.clientKey,
        showLogs: true,
      );

      final isUserSignedIn = await CourierRC.shared.isUserSignedIn;
      expect(isUserSignedIn, true);

      while (hold) {
        // Hold
      }

      await listener.remove();

    });

  });

}