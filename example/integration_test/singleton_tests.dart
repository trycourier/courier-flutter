import 'package:courier_flutter/courier_flutter_v2.dart';
import 'package:courier_flutter/courier_provider.dart';
import 'package:courier_flutter_sample/env.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';

import 'example_server.dart';
import 'user_builder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final userId = const Uuid().v1();

  Future<String> sendMessage(String userId) {
    return ExampleServer.sendTest(Env.authKey, userId, "inbox");
  }

  Future delay({int milliseconds = 5000}) {
    return Future.delayed(Duration(milliseconds: milliseconds));
  }

  group('Client', () {

    setUp(() async {
      await CourierRC.shared.signOut();
    });

    test('Null', () async {

      final client = await CourierRC.shared.client;

      expect(client?.options.jwt, isNull);
      expect(client?.options.userId, isNull);

    });

    test('Options', () async {

      await UserBuilder.build(userId: userId);

      final client = await CourierRC.shared.client;

      expect(client?.options.userId, userId);

    });

    test('Use API', () async {

      await UserBuilder.build(userId: userId);

      final client = await CourierRC.shared.client;

      final res = await client?.brands.getBrand(brandId: Env.brandId);

      expect(res?.data?.brand, isNotNull);

    });

  });

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

      await UserBuilder.build(userId: userId);

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

      await UserBuilder.build(userId: userId);

      final isUserSignedIn = await CourierRC.shared.isUserSignedIn;
      expect(isUserSignedIn, true);

      while (hold) {
        // Hold
      }

      await listener.remove();

    });

    test('Remove All Authentication Listeners', () async {

      await CourierRC.shared.addAuthenticationListener((userId) => print(userId));
      await CourierRC.shared.addAuthenticationListener((userId) => print(userId));
      await CourierRC.shared.addAuthenticationListener((userId) => print(userId));

      await CourierRC.shared.removeAllAuthenticationListeners();

    });

  });

  group('Tokens', () {

    setUp(() async {
      await CourierRC.shared.signOut();
    });

    test('APNS Token', () async {

      await UserBuilder.build(userId: userId);

      final apnsToken = await CourierRC.shared.apnsToken;
      print(apnsToken);

    });

    test('Get All Tokens', () async {

      await UserBuilder.build(userId: userId);

      // Save tokens courier remote and local
      await Future.wait([
        CourierRC.shared.setToken(token: "token1", provider: "provider0"),
        CourierRC.shared.setTokenForProvider(token: "token2", provider: CourierPushProvider.apn),
        CourierRC.shared.setTokenForProvider(token: "token3", provider: CourierPushProvider.firebaseFcm),
        CourierRC.shared.setTokenForProvider(token: "token4", provider: CourierPushProvider.expo),
      ]);

      final tokensWithUser = await CourierRC.shared.tokens;
      expect(tokensWithUser.length, 4);

      // Remove current user
      await CourierRC.shared.signOut();

      // Ensure tokens still exist locally
      final tokensWithoutUser = await CourierRC.shared.tokens;
      expect(tokensWithoutUser.length, 4);

    });

    test('Set Token', () async {

      await UserBuilder.build(userId: userId);

      await CourierRC.shared.setTokenForProvider(
          token: "token",
          provider: CourierPushProvider.firebaseFcm
      );

    });

    test('Get Token', () async {

      await UserBuilder.build(userId: userId);

      const provider = CourierPushProvider.firebaseFcm;
      const example = "example_token";

      await CourierRC.shared.setTokenForProvider(
          token: example,
          provider: provider
      );

      final token = await CourierRC.shared.getTokenForProvider(provider: provider);
      expect(token, example);

    });

  });

  group('Inbox', () {

    setUp(() async {
      await CourierRC.shared.signOut();
    });

    test('Pagination Limit', () async {

      await UserBuilder.build(userId: userId);

      await CourierRC.shared.setInboxPaginationLimit(limit: -100);
      final limit1 = await CourierRC.shared.inboxPaginationLimit;
      expect(limit1, 1);

      await CourierRC.shared.setInboxPaginationLimit(limit: 10000);
      final limit2 = await CourierRC.shared.inboxPaginationLimit;
      expect(limit2, 100);

    });

    test('Get Inbox Messages', () async {

      await UserBuilder.build(userId: userId);

      final messages = await CourierRC.shared.inboxMessages;
      expect(messages, []);

    });

    test('Refresh Inbox', () async {

      await UserBuilder.build(userId: userId);

      await CourierRC.shared.refreshInbox();

    });

    test('Fetch Next Page', () async {

      await UserBuilder.build(userId: userId);

      final messages = await CourierRC.shared.fetchNextInboxPage();
      expect(messages, []);

    });

    // test('Add Inbox Listener', () async {
    //
    //   await UserBuilder.build(userId: userId);
    //
    //   var hold = true;
    //
    //   final listener = await CourierRC.shared.addInboxListener(
    //     onInitialLoad: () {
    //       print("Loading");
    //     },
    //     onError: (error) {
    //       print(error);
    //     },
    //     onMessagesChanged: (messages, unreadCount, totalCount, canPaginate) {
    //       print("onMessagesChanged");
    //       hold = messages.isEmpty;
    //     }
    //   );
    //
    //   await delay();
    //
    //   // TODO: Message count not working on second message
    //
    //   await sendMessage(userId);
    //
    //   while (hold) {
    //     // Hold
    //   }
    //
    //   final messages = await CourierRC.shared.inboxMessages;
    //   expect(messages.length, 1);
    //
    //   await listener.remove();
    //
    // });

    test('Open Message', () async {

      await UserBuilder.build(userId: userId);

      final messageId = await sendMessage(userId);

      await CourierRC.shared.openMessage(messageId: messageId);

    });

    test('Read Message', () async {

      await UserBuilder.build(userId: userId);

      final messageId = await sendMessage(userId);

      await CourierRC.shared.readMessage(messageId: messageId);

    });

    test('Unread Message', () async {

      await UserBuilder.build(userId: userId);

      final messageId = await sendMessage(userId);

      await CourierRC.shared.unreadMessage(messageId: messageId);

    });

    test('Click Message', () async {

      await UserBuilder.build(userId: userId);

      final messageId = await sendMessage(userId);

      await CourierRC.shared.clickMessage(messageId: messageId);

    });

    test('Archive Message', () async {

      await UserBuilder.build(userId: userId);

      final messageId = await sendMessage(userId);

      await CourierRC.shared.archiveMessage(messageId: messageId);

    });

    test('Read All Messages', () async {

      await UserBuilder.build(userId: userId);

      await sendMessage(userId);

      await CourierRC.shared.readAllInboxMessages();

    });

  });

}