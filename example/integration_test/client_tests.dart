import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/courier_preference_status.dart';
import 'package:courier_flutter/models/courier_device.dart';
import 'package:courier_flutter/models/courier_tracking_event.dart';
import 'package:courier_flutter_sample/env.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';

import 'client_builder.dart';
import 'example_server.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final userId = const Uuid().v1();
  const trackingUrl = "https://af6303be-0e1e-40b5-bb80-e1d9299cccff.ct0.app/t/tzgspbr4jcmcy1qkhw96m0034bvy";

  Future<String> sendMessage(String userId) {
    return ExampleServer.sendTest(Env.authKey, userId, "inbox");
  }

  Future delay({int milliseconds = 5000}) {
    return Future.delayed(Duration(milliseconds: milliseconds));
  }

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
      final res = await client.brands.getBrand(brandId: Env.brandId);
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

  group('Tracking Tests', () {
    test('Track Delivered', () async {
      final client = await ClientBuilder.build(userId: userId);
      await client.tracking.postTrackingUrl(
        url: trackingUrl,
        event: CourierTrackingEvent.delivered,
      );
    });
    test('Track Clicked', () async {
      final client = await ClientBuilder.build(userId: userId);
      await client.tracking.postTrackingUrl(
        url: trackingUrl,
        event: CourierTrackingEvent.clicked,
      );
    });
  });

  group('Preferences Tests', () {
    test('Get Preferences', () async {
      final client = await ClientBuilder.build(userId: userId);
      final res = await client.preferences.getUserPreferences();
      expect(res.items, isNotEmpty);
    });
    test('Get Preference Topic', () async {
      final client = await ClientBuilder.build(userId: userId);
      final res = await client.preferences.getUserPreferenceTopic(topicId: Env.preferenceTopicId);
      expect(res.topic.topicId, Env.preferenceTopicId);
    });
    test('Put Preference Topic', () async {
      final client = await ClientBuilder.build(userId: userId);
      await client.preferences.putUserPreferenceTopic(
        topicId: Env.preferenceTopicId,
        status: CourierUserPreferencesStatus.optedIn,
        hasCustomRouting: true,
        customRouting: [CourierUserPreferencesChannel.push],
      );
    });
  });

  group('Inbox Tests', () {
    test('Get All Messages', () async {
      final client = await ClientBuilder.build(userId: userId);
      final res = await client.inbox.getMessages();
      expect(res.data?.messages, isNotNull);
    });
    test('Get Archived Messages', () async {
      final client = await ClientBuilder.build(userId: userId);
      final res = await client.inbox.getArchivedMessages();
      expect(res.data?.messages, isNotNull);
    });
    test('Get Message By ID', () async {
      final messageId = await sendMessage(userId);
      await delay();
      final client = await ClientBuilder.build(userId: userId);
      final res = await client.inbox.getMessageById(messageId: messageId);
      expect(res.data?.message.messageId, messageId);
    });
    test('Get Unread Message Count', () async {
      final newUser = const Uuid().v1();
      await sendMessage(newUser);
      await delay();
      final client = await ClientBuilder.build(userId: newUser);
      final count = await client.inbox.getUnreadMessageCount();
      expect(count, 1);
    });
    test('Open Message', () async {
      final messageId = await sendMessage(userId);
      await delay();
      final client = await ClientBuilder.build(userId: userId);
      await client.inbox.open(messageId: messageId);
    });
    test('Click Message', () async {
      final messageId = await sendMessage(userId);
      await delay();
      final client = await ClientBuilder.build(userId: userId);
      await client.inbox.click(messageId: messageId, trackingId: "example_id");
    });
    test('Read Message', () async {
      final messageId = await sendMessage(userId);
      await delay();
      final client = await ClientBuilder.build(userId: userId);
      await client.inbox.read(messageId: messageId);
    });
    test('Unread Message', () async {
      final messageId = await sendMessage(userId);
      await delay();
      final client = await ClientBuilder.build(userId: userId);
      await client.inbox.unread(messageId: messageId);
    });
    test('Archive Message', () async {
      final messageId = await sendMessage(userId);
      await delay();
      final client = await ClientBuilder.build(userId: userId);
      await client.inbox.archive(messageId: messageId);
    });
    test('Read All Messages', () async {
      await sendMessage(userId);
      await delay();
      final client = await ClientBuilder.build(userId: userId);
      await client.inbox.readAll();
    });
    test('Register Socket', () async {

      var hold = true;

      final testClient = TestClient(
        clientKey: Env.clientKey,
        userId: userId,
        showLogs: true,
      );

      testClient.inbox.socket.receivedMessage();
      testClient.inbox.socket.connect();
      testClient.inbox.socket.sendSubscribe();

      // final client = await ClientBuilder.build(userId: userId);
      // await client.inbox.socket.receivedMessage();
      // await client.inbox.socket.connect();
      // await client.inbox.socket.sendSubscribe();

      await sendMessage(userId);

      // TODO: Handle the event callback

      while (hold) {
        // Hold
      }

    });
  });
}
