import 'dart:convert';

import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/models/courier_inbox_messages.dart';

class InboxClient {

  final CourierClientOptions _options;

  InboxClient(this._options);

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
