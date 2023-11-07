import 'package:courier_flutter/courier_flutter.dart';

class InboxMessage {

  final String messageId;
  final String? title;
  final String? body;
  final String? preview;
  final String? created;
  final List<InboxAction>? actions;
  final dynamic data;
  bool? archived;
  String? read;
  String? opened;

  InboxMessage({
    required this.messageId,
    this.title,
    this.body,
    this.preview,
    this.created,
    this.actions,
    this.data,
    this.archived,
    this.read,
    this.opened,
  });

  String? get subtitle => body ?? preview;
  bool get isRead => read != null;
  bool get isOpened => opened != null;
  bool get isArchived => archived ?? false;

  void setRead() {
    read = DateTime.now().toIso8601String();
  }

  void setUnread() {
    read = null;
  }

  void setOpened() {
    opened = DateTime.now().toIso8601String();
  }

}

extension InboxMessageExtensions on InboxMessage {

  Future markAsRead() => Courier.shared.readMessage(id: messageId);

  Future markAsUnread() => Courier.shared.unreadMessage(id: messageId);

}