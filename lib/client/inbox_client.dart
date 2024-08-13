import 'dart:convert';

import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_inbox_messages.dart';
import 'package:uuid/uuid.dart';

class InboxClient {

  final CourierClientOptions _options;

  InboxClient(this._options);

  late final InboxSocket socket = InboxSocket(_options);

  Future<CourierGetInboxMessagesResponse> getMessages({int? paginationLimit, String? startCursor}) async {
    final data = await _options.invokeClient('inbox.get_messages', {
      'paginationLimit': paginationLimit,
      'startCursor': startCursor,
    });
    final Map<String, dynamic> map = json.decode(data);
    return CourierGetInboxMessagesResponse.fromJson(map);
  }

  Future<CourierGetInboxMessagesResponse> getArchivedMessages({int? paginationLimit, String? startCursor}) async {
    final data = await _options.invokeClient('inbox.get_archived_messages', {
      'paginationLimit': paginationLimit,
      'startCursor': startCursor,
    });
    final Map<String, dynamic> map = json.decode(data);
    return CourierGetInboxMessagesResponse.fromJson(map);
  }

  Future<CourierGetInboxMessageResponse> getMessageById({required String messageId}) async {
    final data = await _options.invokeClient('inbox.get_message_by_id', {
      'messageId': messageId,
    });
    final Map<String, dynamic> map = json.decode(data);
    return CourierGetInboxMessageResponse.fromJson(map);
  }

  Future<int> getUnreadMessageCount() async {
    return await _options.invokeClient('inbox.get_unread_message_count');
  }

  Future open({required String messageId}) async {
    await _options.invokeClient('inbox.open_message', {
      'messageId': messageId,
    });
  }

  Future read({required String messageId}) async {
    await _options.invokeClient('inbox.read_message', {
      'messageId': messageId,
    });
  }

  Future unread({required String messageId}) async {
    await _options.invokeClient('inbox.unread_message', {
      'messageId': messageId,
    });
  }

  Future click({required String messageId, required String trackingId}) async {
    await _options.invokeClient('inbox.click_message', {
      'messageId': messageId,
      'trackingId': trackingId,
    });
  }

  Future archive({required String messageId}) async {
    await _options.invokeClient('inbox.archive_message', {
      'messageId': messageId,
    });
  }

  Future readAll() async {
    await _options.invokeClient('inbox.read_all_messages');
  }

}

class InboxSocket {

  String? id;
  Function(InboxMessage message)? receivedMessage;
  Function(dynamic event)? receivedMessageEvent;

  final CourierClientOptions _options;

  InboxSocket(this._options);

  Future<String> _addSocket() async {
    final socketId = const Uuid().v4();
    id = await _options.invokeClient('inbox.socket.add_socket', {
      'socketId': socketId,
    });
    return socketId;
  }

  Future _removeSocket({required String socketId}) async {
    await _options.invokeClient('inbox.socket.remove_socket', {
      'socketId': socketId,
    });
  }

  Future connect() async {
    final socketId = id ?? await _addSocket();
    await _options.invokeClient('inbox.socket.connect', {
      'socketId': socketId,
    });
  }

  Future disconnect() async {
    if (id != null) {
      await _options.invokeClient('inbox.socket.disconnect', {
        'socketId': id!,
      });
      await _removeSocket(
          socketId: id!
      );
    }
    receivedMessage = null;
    receivedMessageEvent = null;
  }

  Future sendSubscribe({int version = 5}) async {
    final socketId = id ?? await _addSocket();
    await _options.invokeClient('inbox.socket.send_subscribe', {
      'socketId': socketId,
      'version': version,
    });
  }

  Future onReceivedMessage(Function(InboxMessage message)? listener) async {
    final socketId = id ?? await _addSocket();
    await _options.invokeClient('inbox.socket.receive_messages', {
      'socketId': socketId,
    });
    receivedMessage = listener;
  }

  Future onReceivedMessageEvent(Function(dynamic event)? listener) async {
    final socketId = id ?? await _addSocket();
    await _options.invokeClient('inbox.socket.receive_message_events', {
      'socketId': socketId,
    });
    receivedMessageEvent = listener;
  }

}
