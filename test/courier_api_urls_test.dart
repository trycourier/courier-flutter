import 'package:courier_flutter/client/courier_api_urls.dart';
import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/courier_flutter_channels.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CourierApiUrls', () {
    test('returns the EU preset', () {
      final apiUrls = CourierApiUrls.forRegion(CourierApiRegion.eu);

      expect(apiUrls.rest, 'https://api.eu.courier.com');
      expect(apiUrls.graphql, 'https://api.eu.courier.com/client/q');
      expect(apiUrls.inboxGraphql, 'https://inbox.eu.courier.io/q');
      expect(apiUrls.inboxWebSocket, 'wss://realtime.eu.courier.io');
    });

    test('serializes apiUrls into client options', () {
      final client = CourierClient(
        userId: 'user-123',
        apiUrls: const CourierApiUrls.eu(),
        showLogs: true,
      );

      expect(client.options.toJson()['apiUrls'], {
        'rest': 'https://api.eu.courier.com',
        'graphql': 'https://api.eu.courier.com/client/q',
        'inboxGraphql': 'https://inbox.eu.courier.io/q',
        'inboxWebSocket': 'wss://realtime.eu.courier.io',
      });
    });

    test('passes apiUrls through shared signIn', () async {
      MethodCall? lastCall;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        CourierFlutterChannels.shared,
        (call) async {
          lastCall = call;
          return null;
        },
      );

      await Courier.shared.signIn(
        userId: 'user-123',
        accessToken: 'jwt',
        apiUrls: const CourierApiUrls.eu(),
      );

      expect(lastCall?.method, 'auth.sign_in');
      expect((lastCall?.arguments as Map)['apiUrls'], {
        'rest': 'https://api.eu.courier.com',
        'graphql': 'https://api.eu.courier.com/client/q',
        'inboxGraphql': 'https://inbox.eu.courier.io/q',
        'inboxWebSocket': 'wss://realtime.eu.courier.io',
      });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(CourierFlutterChannels.shared, null);
    });
  });
}
