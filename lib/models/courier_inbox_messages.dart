import 'package:courier_flutter/models/inbox_message.dart';

class CourierGetInboxMessagesResponse {
  final GetInboxMessagesData? data;

  CourierGetInboxMessagesResponse({this.data});

  factory CourierGetInboxMessagesResponse.fromJson(Map<String, dynamic> json) {
    return CourierGetInboxMessagesResponse(
      data: json['data'] != null ? GetInboxMessagesData.fromJson(json['data']) : null,
    );
  }

}

class GetInboxMessagesData {
  final int? count;
  final GetInboxMessagesNodes? messages;

  GetInboxMessagesData({this.count = 0, this.messages});

  factory GetInboxMessagesData.fromJson(Map<String, dynamic> json) {
    return GetInboxMessagesData(
      count: json['count'] ?? 0,
      messages: json['messages'] != null ? GetInboxMessagesNodes.fromJson(json['messages']) : null,
    );
  }

}

class GetInboxMessagesNodes {
  final GetInboxMessagesPageInfo? pageInfo;
  final List<InboxMessage>? nodes;

  GetInboxMessagesNodes({this.pageInfo, this.nodes});

  factory GetInboxMessagesNodes.fromJson(Map<String, dynamic> json) {
    return GetInboxMessagesNodes(
      pageInfo: json['pageInfo'] != null ? GetInboxMessagesPageInfo.fromJson(json['pageInfo']) : null,
      nodes: json['nodes'] != null ? List<InboxMessage>.from(json['nodes'].map((item) => InboxMessage.fromJson(item))) : null,
    );
  }

}

class GetInboxMessagesPageInfo {
  final String? startCursor;
  final bool? hasNextPage;

  GetInboxMessagesPageInfo({this.startCursor, this.hasNextPage});

  factory GetInboxMessagesPageInfo.fromJson(Map<String, dynamic> json) {
    return GetInboxMessagesPageInfo(
      startCursor: json['startCursor'],
      hasNextPage: json['hasNextPage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startCursor': startCursor,
      'hasNextPage': hasNextPage,
    };
  }
}

class CourierGetInboxMessageResponse {
  final GetInboxMessageData? data;

  CourierGetInboxMessageResponse({this.data});

  factory CourierGetInboxMessageResponse.fromJson(Map<String, dynamic> json) {
    return CourierGetInboxMessageResponse(
      data: json['data'] != null ? GetInboxMessageData.fromJson(json['data']) : null,
    );
  }

}

class GetInboxMessageData {
  final InboxMessage message;

  GetInboxMessageData({required this.message});

  factory GetInboxMessageData.fromJson(Map<String, dynamic> json) {
    return GetInboxMessageData(
      message: InboxMessage.fromJson(json['message']),
    );
  }

}