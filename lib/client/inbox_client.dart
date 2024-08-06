import 'dart:convert';

import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/models/courier_inbox_messages.dart';

class InboxClient {

  late final InboxSocket socket = InboxSocket(_options);
  final CourierClientOptions _options;

  InboxClient(this._options);

  Future<CourierGetInboxMessagesResponse> getMessages({int? paginationLimit, String? startCursor}) async {
    final data = await _options.invokeClient('client.inbox.get_messages', {
      'paginationLimit': paginationLimit,
      'startCursor': startCursor,
    });
    final Map<String, dynamic> map = json.decode(data);
    return CourierGetInboxMessagesResponse.fromJson(map);
  }

  Future<CourierGetInboxMessagesResponse> getArchivedMessages({int? paginationLimit, String? startCursor}) async {
    final data = await _options.invokeClient('client.inbox.get_archived_messages', {
      'paginationLimit': paginationLimit,
      'startCursor': startCursor,
    });
    final Map<String, dynamic> map = json.decode(data);
    return CourierGetInboxMessagesResponse.fromJson(map);
  }

  Future<CourierGetInboxMessageResponse> getMessageById({required String messageId}) async {
    final data = await _options.invokeClient('client.inbox.get_message_by_id', {
      'messageId': messageId,
    });
    final Map<String, dynamic> map = json.decode(data);
    return CourierGetInboxMessageResponse.fromJson(map);
  }

  Future<int> getUnreadMessageCount() async {
    return await _options.invokeClient('client.inbox.get_unread_message_count');
  }

  Future open({required String messageId}) async {
    await _options.invokeClient('client.inbox.open_message', {
      'messageId': messageId,
    });
  }

  Future read({required String messageId}) async {
    await _options.invokeClient('client.inbox.read_message', {
      'messageId': messageId,
    });
  }

  Future unread({required String messageId}) async {
    await _options.invokeClient('client.inbox.unread_message', {
      'messageId': messageId,
    });
  }

  Future click({required String messageId, required String trackingId}) async {
    await _options.invokeClient('client.inbox.click_message', {
      'messageId': messageId,
      'trackingId': trackingId,
    });
  }

  Future archive({required String messageId}) async {
    await _options.invokeClient('client.inbox.archive_message', {
      'messageId': messageId,
    });
  }

  Future readAll() async {
    await _options.invokeClient('client.inbox.read_all_messages');
  }

}

class InboxSocket {

  String? _id;
  final CourierClientOptions _options;
  // Function(InboxMessage)? receivedMessage;

  InboxSocket(this._options) {

    // _options.events.setMethodCallHandler((call) {
    //   switch (call.method) {
    //     case 'client.events.inbox.socket.received_message':
    //       print("HERE");
    //   }
    //   return Future.value();
    // });

  }

  Future<String> _register() async {
    _id ??= await _options.invokeClient('client.inbox.socket.register');
    return _id!;
  }

  Future receivedMessage() async {
    await _options.invokeClient('client.inbox.socket.received_message', {
      'socketId': await _register()
    });
  }

  Future connect() async {
    await _options.invokeClient('client.inbox.socket.connect', {
      'socketId': await _register()
    });
  }

  Future sendSubscribe({int version = 5}) async {
    await _options.invokeClient('client.inbox.socket.send_subscribe', {
      'socketId': await _register(),
      'version': version,
    });
  }

}
