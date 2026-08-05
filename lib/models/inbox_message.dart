import 'package:courier_flutter/courier_flutter.dart';
import 'package:intl/intl.dart';

/// Tracking ids for an inbox message, as published at the root of the message by
/// both the GraphQL read and the `iwpv=v2` socket.
class InboxMessageTrackingIds {
  final String? archiveTrackingId;
  final String? channelTrackingId;
  final String? clickTrackingId;
  final String? deliverTrackingId;
  final String? openTrackingId;
  final String? readTrackingId;
  final String? unreadTrackingId;

  InboxMessageTrackingIds({
    this.archiveTrackingId,
    this.channelTrackingId,
    this.clickTrackingId,
    this.deliverTrackingId,
    this.openTrackingId,
    this.readTrackingId,
    this.unreadTrackingId,
  });

  factory InboxMessageTrackingIds.fromJson(Map<String, dynamic> json) {
    return InboxMessageTrackingIds(
      archiveTrackingId: json['archiveTrackingId'],
      channelTrackingId: json['channelTrackingId'],
      clickTrackingId: json['clickTrackingId'],
      deliverTrackingId: json['deliverTrackingId'],
      openTrackingId: json['openTrackingId'],
      readTrackingId: json['readTrackingId'],
      unreadTrackingId: json['unreadTrackingId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'archiveTrackingId': archiveTrackingId,
      'channelTrackingId': channelTrackingId,
      'clickTrackingId': clickTrackingId,
      'deliverTrackingId': deliverTrackingId,
      'openTrackingId': openTrackingId,
      'readTrackingId': readTrackingId,
      'unreadTrackingId': unreadTrackingId,
    };
  }
}

class InboxMessage {
  final String messageId;
  final String? title;
  final String? body;
  final String? preview;
  final String? created;
  String? archived;
  String? read;
  String? opened;
  final List<InboxAction>? actions;
  final dynamic data;

  /// Tracking ids for this message.
  ///
  /// The native SDKs have always sent these — both platform handlers serialize a
  /// message with the native `toJson()`, which encodes `trackingIds` — but this
  /// model dropped the key on the floor in [fromJson]. So a Flutter app had no way
  /// to reach a tracking id, and [CourierClient.inbox.click] requires the caller to
  /// supply one. That made click tracking effectively unreachable from Dart.
  final InboxMessageTrackingIds? trackingIds;

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
    this.trackingIds,
  });

  /// Convenience accessor for the id [CourierClient.inbox.click] needs.
  String? get clickTrackingId => trackingIds?.clickTrackingId;

  factory InboxMessage.fromJson(Map<String, dynamic> data) {
    List<dynamic>? actions = data['actions'];
    return InboxMessage(
      messageId: data['messageId'],
      title: data['title'],
      body: data['body'],
      preview: data['preview'],
      actions: actions?.map((action) => InboxAction(content: action['content'], href: action['href'], data: action['data'])).toList(),
      data: data['data'],
      created: data['created'],
      archived: data['archived'],
      read: data['read'],
      opened: data['opened'],
      trackingIds: data['trackingIds'] is Map
          ? InboxMessageTrackingIds.fromJson(
              Map<String, dynamic>.from(data['trackingIds'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'title': title,
      'body': body, 
      'preview': preview,
      'created': created,
      'archived': archived,
      'read': read,
      'opened': opened,
      'actions': actions?.map((action) => {
        'content': action.content,
        'href': action.href,
        'data': action.data,
      }).toList(),
      'data': data,
      'trackingIds': trackingIds?.toJson(),
    };
  }

  String? get subtitle => body ?? preview;

  bool get isRead => read != null;

  bool get isOpened => opened != null;

  bool get isArchived => archived != null;

  DateTime? get createdAt {
    if (created == null) return null;
    try {
      return DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parseUtc(created!).toLocal();
    } catch (e) {
      return null;
    }
  }

  void setRead() {
    read = DateTime.now().toIso8601String();
  }

  void setUnread() {
    read = null;
  }

  void setOpened() {
    opened = DateTime.now().toIso8601String();
  }

  void setArchived() {
    archived = DateTime.now().toIso8601String();
  }

  void setUnarchived() {
    archived = null;
  }

  String get time {
    if (created != null) {
      // Define the date format and specify that it should be parsed in UTC to avoid timezone issues
      final dateFormatter = DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ');

      try {
        // Parse the created date in UTC and then convert it to the local time zone
        final date = dateFormatter.parseUtc(created!).toLocal();
        final timeDifference = DateTime.now().difference(date);

        final timeSince = timeDifference.inSeconds;

        if (timeSince < 1) {
          return 'now';
        } else if (timeSince < 60) {
          return '$timeSince seconds ago';
        } else if (timeSince < 120) {
          return '1 minute ago';
        } else if (timeSince < 3600) {
          return '${timeSince ~/ 60} minutes ago';
        } else if (timeSince < 86400) {
          return '${timeSince ~/ 3600} hours ago';
        } else {
          return '${timeSince ~/ 86400} days ago';
        }
      } catch (e) {
        // If parsing fails, return a default value
        return 'unknown time';
      }
    }

    return 'now';
  }
}

extension InboxMessageExtensions on InboxMessage {

  Future markAsOpened() {
    setOpened();
    return Courier.shared.openMessage(messageId: messageId);
  }

  Future markAsClicked() {
    return Courier.shared.clickMessage(messageId: messageId);
  }

  Future markAsRead() {
    setRead();
    return Courier.shared.readMessage(messageId: messageId);
  }

  Future markAsUnread() {
    setUnread();
    return Courier.shared.unreadMessage(messageId: messageId);
  }

  Future markAsArchived() {
    setArchived();
    return Courier.shared.archiveMessage(messageId: messageId);
  }

}
