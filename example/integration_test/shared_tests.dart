import 'dart:io';

import 'package:courier_flutter/courier_flutter.dart';
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

  group('Push', () {

    setUp(() async {
      await Courier.shared.signOut();
    });

    test('iOS Foreground Presentation Options', () async {

      if (!Platform.isIOS) {
        return;
      }

      const options = iOSNotificationPresentationOption.values;
      final newOptions = await Courier.setIOSForegroundPresentationOptions(options: options);
      expect(options, newOptions);

    });

  });

  group('Client', () {

    setUp(() async {
      await Courier.shared.signOut();
    });

    test('Null', () async {

      final client = await Courier.shared.client;

      expect(client?.options.jwt, isNull);
      expect(client?.options.userId, isNull);

    });

    test('Options', () async {

      await UserBuilder.build(userId: userId);

      final client = await Courier.shared.client;

      expect(client?.options.userId, userId);

    });

    test('Use API', () async {

      await UserBuilder.build(userId: userId);

      final client = await Courier.shared.client;

      final res = await client?.brands.getBrand(brandId: Env.brandId);

      expect(res?.data?.brand, isNotNull);

    });

  });

  group('Authentication', () {

    setUp(() async {
      await Courier.shared.signOut();
    });

    test('Sign Out', () async {

      await Courier.shared.signOut();

      final currentUserId = await Courier.shared.userId;
      final currentTenantId = await Courier.shared.tenantId;
      final isUserSignedIn = await Courier.shared.isUserSignedIn;

      expect(currentUserId, isNull);
      expect(currentTenantId, isNull);
      expect(isUserSignedIn, false);

    });

    test('Sign In', () async {

      await Courier.shared.signIn(
          userId: userId,
          accessToken: "example_key"
      );

      final currentUserId = await Courier.shared.userId;
      final currentTenantId = await Courier.shared.tenantId;
      final isUserSignedIn = await Courier.shared.isUserSignedIn;
      expect(currentUserId, userId);
      expect(currentTenantId, isNull);
      expect(isUserSignedIn, true);

    });

    test('Authentication Listener', () async {

      var hold = true;

      final listener = await Courier.shared.addAuthenticationListener((userId) {
        hold = userId == null;
      });

      await UserBuilder.build(userId: userId);

      final isUserSignedIn = await Courier.shared.isUserSignedIn;
      expect(isUserSignedIn, true);

      while (hold) {
        // Hold
      }

      await listener.remove();

    });

    test('Remove All Authentication Listeners', () async {

      await Courier.shared.addAuthenticationListener((userId) => print(userId));
      await Courier.shared.addAuthenticationListener((userId) => print(userId));
      await Courier.shared.addAuthenticationListener((userId) => print(userId));

      await Courier.shared.removeAllAuthenticationListeners();

    });

  });

  group('Tokens', () {

    setUp(() async {
      await Courier.shared.signOut();
    });

    test('APNS Token', () async {

      if (!Platform.isIOS) {
        return;
      }

      await UserBuilder.build(userId: userId);

      final apnsToken = await Courier.shared.apnsToken;
      print(apnsToken);

    });

    test('FCM Token', () async {

      if (!Platform.isAndroid) {
        return;
      }

      await UserBuilder.build(userId: userId);

      final fcmToken = await Courier.shared.fcmToken;
      print(fcmToken);

    });

    test('Get All Tokens', () async {

      await UserBuilder.build(userId: userId);

      // Save tokens courier remote and local
      await Future.wait([
        Courier.shared.setToken(token: "token1", provider: "provider0"),
        Courier.shared.setTokenForProvider(token: "token2", provider: CourierPushProvider.apn),
        Courier.shared.setTokenForProvider(token: "token3", provider: CourierPushProvider.firebaseFcm),
        Courier.shared.setTokenForProvider(token: "token4", provider: CourierPushProvider.expo),
      ]);

      final tokensWithUser = await Courier.shared.tokens;
      expect(tokensWithUser.length, 4);

      // Remove current user
      await Courier.shared.signOut();

      // Ensure tokens still exist locally
      final tokensWithoutUser = await Courier.shared.tokens;
      expect(tokensWithoutUser.length, 4);

    });

    test('Set Token', () async {

      await UserBuilder.build(userId: userId);

      await Courier.shared.setTokenForProvider(
          token: "token",
          provider: CourierPushProvider.firebaseFcm
      );

    });

    test('Get Token', () async {

      await UserBuilder.build(userId: userId);

      const provider = CourierPushProvider.firebaseFcm;
      const example = "example_token";

      await Courier.shared.setTokenForProvider(
          token: example,
          provider: provider
      );

      final token = await Courier.shared.getTokenForProvider(provider: provider);
      expect(token, example);

    });

  });

  group('Inbox', () {

    setUp(() async {
      await Courier.shared.signOut();
    });

    test('Pagination Limit', () async {

      await UserBuilder.build(userId: userId);

      await Courier.shared.setInboxPaginationLimit(limit: -100);
      final limit1 = await Courier.shared.inboxPaginationLimit;
      expect(limit1, 1);

      await Courier.shared.setInboxPaginationLimit(limit: 10000);
      final limit2 = await Courier.shared.inboxPaginationLimit;
      expect(limit2, 100);

    });

    test('Get Inbox Messages', () async {

      await UserBuilder.build(userId: userId);

      final messages = await Courier.shared.inboxMessages;
      expect(messages, []);

    });

    test('Refresh Inbox', () async {

      await UserBuilder.build(userId: userId);

      await Courier.shared.refreshInbox();

    });

    test('Fetch Next Page', () async {

      await UserBuilder.build(userId: userId);

      final messages = await Courier.shared.fetchNextInboxPage();
      expect(messages, []);

    });

    test('Add Inbox Listener', () async {

      if (Platform.isAndroid) {
        print("Android threading issue with tests prevents this test from working. Be sure to test the sample app.");
        return;
      }

      await UserBuilder.build(userId: userId);

      var hold = true;

      final listener = await Courier.shared.addInboxListener(
        onInitialLoad: null,
        onError: null,
        onMessagesChanged: (messages, unreadCount, totalCount, canPaginate) {
          hold = false;
        }
      );

      while (hold) {
        // Hold
      }

      await listener.remove();

    });

    test('Open Message', () async {

      await UserBuilder.build(userId: userId);

      final messageId = await sendMessage(userId);

      await Courier.shared.openMessage(messageId: messageId);

    });

    test('Read Message', () async {

      await UserBuilder.build(userId: userId);

      final messageId = await sendMessage(userId);

      await Courier.shared.readMessage(messageId: messageId);

    });

    test('Unread Message', () async {

      await UserBuilder.build(userId: userId);

      final messageId = await sendMessage(userId);

      await Courier.shared.unreadMessage(messageId: messageId);

    });

    test('Click Message', () async {

      await UserBuilder.build(userId: userId);

      final messageId = await sendMessage(userId);

      await Courier.shared.clickMessage(messageId: messageId);

    });

    test('Archive Message', () async {

      await UserBuilder.build(userId: userId);

      final messageId = await sendMessage(userId);

      await Courier.shared.archiveMessage(messageId: messageId);

    });

    test('Read All Messages', () async {

      await UserBuilder.build(userId: userId);

      await sendMessage(userId);

      await Courier.shared.readAllInboxMessages();

    });

  });

}