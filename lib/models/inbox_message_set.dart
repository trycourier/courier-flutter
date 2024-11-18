import 'package:courier_flutter/models/inbox_message.dart';

class InboxMessageSet {
  List<InboxMessage> messages;
  int totalCount;
  bool canPaginate;
  String? paginationCursor;

  InboxMessageSet({
    required this.messages,
    required this.totalCount, 
    required this.canPaginate,
    this.paginationCursor,
  });

  factory InboxMessageSet.fromJson(Map<String, dynamic> json) {
    return InboxMessageSet(
      messages: (json['messages'] as List<dynamic>)
          .map((message) => InboxMessage.fromJson(message))
          .toList(),
      totalCount: json['totalCount'] as int,
      canPaginate: json['canPaginate'] as bool,
      paginationCursor: json['paginationCursor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((message) => message.toJson()).toList(),
      'totalCount': totalCount,
      'canPaginate': canPaginate,
      'paginationCursor': paginationCursor,
    };
  }
}
