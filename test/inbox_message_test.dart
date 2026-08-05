import 'package:courier_flutter/models/inbox_message.dart';
import 'package:flutter_test/flutter_test.dart';

/// The native SDKs have always sent `trackingIds` — both platform handlers serialize
/// a message with the native `toJson()`, which encodes them — but this model dropped
/// the key in `fromJson`, so a Flutter app had no way to reach a tracking id while
/// `CourierClient.inbox.click` requires the caller to supply one.
void main() {
  group('InboxMessage.fromJson trackingIds', () {
    test('parses tracking ids from the root of the message', () {
      final message = InboxMessage.fromJson({
        'messageId': 'msg-1',
        'title': 'Welcome',
        'trackingIds': {
          'archiveTrackingId': 'archive-1',
          'channelTrackingId': 'channel-1',
          'clickTrackingId': 'click-1',
          'deliverTrackingId': 'deliver-1',
          'openTrackingId': 'open-1',
          'readTrackingId': 'read-1',
          'unreadTrackingId': 'unread-1',
        },
      });

      expect(message.trackingIds, isNotNull);
      expect(message.trackingIds!.archiveTrackingId, 'archive-1');
      expect(message.trackingIds!.channelTrackingId, 'channel-1');
      expect(message.trackingIds!.clickTrackingId, 'click-1');
      expect(message.trackingIds!.deliverTrackingId, 'deliver-1');
      expect(message.trackingIds!.openTrackingId, 'open-1');
      expect(message.trackingIds!.readTrackingId, 'read-1');
      expect(message.trackingIds!.unreadTrackingId, 'unread-1');
    });

    test('exposes clickTrackingId, the id click() needs', () {
      final message = InboxMessage.fromJson({
        'messageId': 'msg-1',
        'trackingIds': {'clickTrackingId': 'click-1'},
      });

      expect(message.clickTrackingId, 'click-1');
    });

    test('is null when the message carries no tracking ids', () {
      final message = InboxMessage.fromJson({'messageId': 'msg-1', 'title': 'Welcome'});

      expect(message.trackingIds, isNull);
      expect(message.clickTrackingId, isNull);
    });

    // A partial object is normal — which ids are minted depends on the send.
    test('tolerates a partial tracking ids object', () {
      final message = InboxMessage.fromJson({
        'messageId': 'msg-1',
        'trackingIds': {'clickTrackingId': 'click-1'},
      });

      expect(message.clickTrackingId, 'click-1');
      expect(message.trackingIds!.readTrackingId, isNull);
    });

    // Defensive: the field arrives from a platform channel, so it is not typed.
    test('does not throw when trackingIds is not an object', () {
      expect(
        () => InboxMessage.fromJson({'messageId': 'msg-1', 'trackingIds': 'nonsense'}),
        returnsNormally,
      );
      expect(
        InboxMessage.fromJson({'messageId': 'msg-1', 'trackingIds': 'nonsense'}).trackingIds,
        isNull,
      );
    });

    test('round-trips through toJson', () {
      final message = InboxMessage.fromJson({
        'messageId': 'msg-1',
        'trackingIds': {'clickTrackingId': 'click-1', 'readTrackingId': 'read-1'},
      });

      final json = message.toJson();
      final trackingIds = json['trackingIds'] as Map<String, dynamic>;

      expect(trackingIds['clickTrackingId'], 'click-1');
      expect(trackingIds['readTrackingId'], 'read-1');

      // And survives a second parse, so a serialized message keeps its ids.
      expect(InboxMessage.fromJson(json).clickTrackingId, 'click-1');
    });

    test('other fields are unaffected', () {
      final message = InboxMessage.fromJson({
        'messageId': 'msg-1',
        'title': 'Welcome',
        'preview': 'Preview',
        'data': {'orderId': 'ord_1'},
        'trackingIds': {'clickTrackingId': 'click-1'},
      });

      expect(message.messageId, 'msg-1');
      expect(message.title, 'Welcome');
      expect(message.preview, 'Preview');
      expect(message.data['orderId'], 'ord_1');
    });
  });
}
