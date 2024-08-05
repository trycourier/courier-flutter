import 'dart:convert';

import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/models/courier_inbox_messages.dart';

class InboxClient {
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

  Future openMessage({required String messageId}) async {
    await _options.invokeClient('client.inbox.open_message', {
      'messageId': messageId,
    });
  }

  Future readMessage({required String messageId}) async {
    await _options.invokeClient('client.inbox.read_message', {
      'messageId': messageId,
    });
  }

  Future unreadMessage({required String messageId}) async {
    await _options.invokeClient('client.inbox.unread_message', {
      'messageId': messageId,
    });
  }

  Future clickMessage({required String messageId, required String trackingId}) async {
    await _options.invokeClient('client.inbox.click_message', {
      'messageId': messageId,
      'trackingId': trackingId,
    });
  }

  Future archiveMessage({required String messageId}) async {
    await _options.invokeClient('client.inbox.archive_message', {
      'messageId': messageId,
    });
  }

  Future readAllMessages() async {
    await _options.invokeClient('client.inbox.read_all_messages');
  }

}