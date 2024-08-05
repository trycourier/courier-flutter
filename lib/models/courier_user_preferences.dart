import 'package:courier_flutter/courier_preference_channel.dart';

enum CourierPreferenceStatus {
  optedIn,
  optedOut,
  required,
  unknown,
}

extension CourierPreferenceStatusExtension on CourierPreferenceStatus {
  String get value {
    switch (this) {
      case CourierPreferenceStatus.optedIn:
        return 'OPTED_IN';
      case CourierPreferenceStatus.optedOut:
        return 'OPTED_OUT';
      case CourierPreferenceStatus.required:
        return 'REQUIRED';
      case CourierPreferenceStatus.unknown:
      default:
        return 'UNKNOWN';
    }
  }

  static CourierPreferenceStatus fromString(String value) {
    switch (value) {
      case 'OPTED_IN':
        return CourierPreferenceStatus.optedIn;
      case 'OPTED_OUT':
        return CourierPreferenceStatus.optedOut;
      case 'REQUIRED':
        return CourierPreferenceStatus.required;
      case 'UNKNOWN':
      default:
        return CourierPreferenceStatus.unknown;
    }
  }
}

enum CourierPreferenceChannel {
  directMessage,
  email,
  push,
  sms,
  webhook,
  unknown,
}

extension CourierPreferenceChannelExtension on CourierPreferenceChannel {
  String get value {
    switch (this) {
      case CourierPreferenceChannel.directMessage:
        return 'direct_message';
      case CourierPreferenceChannel.email:
        return 'email';
      case CourierPreferenceChannel.push:
        return 'push';
      case CourierPreferenceChannel.sms:
        return 'sms';
      case CourierPreferenceChannel.webhook:
        return 'webhook';
      case CourierPreferenceChannel.unknown:
      default:
        return 'unknown';
    }
  }

  static CourierPreferenceChannel fromString(String value) {
    switch (value) {
      case 'direct_message':
        return CourierPreferenceChannel.directMessage;
      case 'email':
        return CourierPreferenceChannel.email;
      case 'push':
        return CourierPreferenceChannel.push;
      case 'sms':
        return CourierPreferenceChannel.sms;
      case 'webhook':
        return CourierPreferenceChannel.webhook;
      case 'unknown':
      default:
        return CourierPreferenceChannel.unknown;
    }
  }
}

class CourierUserPreferences {
  final List<CourierPreferenceTopic> items;
  final Paging paging;

  CourierUserPreferences({
    required this.items,
    required this.paging,
  });

  factory CourierUserPreferences.fromJson(Map<String, dynamic> json) {
    return CourierUserPreferences(
      items: (json['items'] as List)
          .map((i) => CourierPreferenceTopic.fromJson(i as Map<String, dynamic>))
          .toList(),
      paging: Paging.fromJson(json['paging'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
      'paging': paging.toJson(),
    };
  }
}

class CourierPreferenceTopic {
  final CourierPreferenceStatus defaultStatus;
  final bool hasCustomRouting;
  final List<CourierPreferenceChannel> customRouting;
  final CourierPreferenceStatus status;
  final String topicId;
  final String topicName;
  final String sectionName;
  final String sectionId;

  CourierPreferenceTopic({
    required this.defaultStatus,
    required this.hasCustomRouting,
    required this.customRouting,
    required this.status,
    required this.topicId,
    required this.topicName,
    required this.sectionName,
    required this.sectionId,
  });

  factory CourierPreferenceTopic.fromJson(Map<String, dynamic> json) {
    return CourierPreferenceTopic(
      defaultStatus: CourierPreferenceStatusExtension.fromString(json['default_status'] as String),
      hasCustomRouting: json['has_custom_routing'] as bool,
      customRouting: (json['custom_routing'] as List<dynamic>).map((item) => CourierPreferenceChannelExtension.fromString(item as String)).toList(),
      status: CourierPreferenceStatusExtension.fromString(json['status'] as String),
      topicId: json['topic_id'] as String,
      topicName: json['topic_name'] as String,
      sectionName: json['section_name'] as String,
      sectionId: json['section_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'default_status': defaultStatus.value,
      'has_custom_routing': hasCustomRouting,
      'custom_routing': customRouting,
      'status': status.value,
      'topic_id': topicId,
      'topic_name': topicName,
      'section_name': sectionName,
      'section_id': sectionId,
    };
  }
}

class Paging {
  final String? cursor;
  final bool more;

  Paging({
    this.cursor,
    required this.more,
  });

  factory Paging.fromJson(Map<String, dynamic> json) {
    return Paging(
      cursor: json['cursor'] as String?,
      more: json['more'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cursor': cursor,
      'more': more,
    };
  }
}

class CourierUserPreferencesTopic {
  final CourierPreferenceTopic topic;

  CourierUserPreferencesTopic({
    required this.topic,
  });

  factory CourierUserPreferencesTopic.fromJson(Map<String, dynamic> json) {
    return CourierUserPreferencesTopic(
      topic: CourierPreferenceTopic.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic.toJson(),
    };
  }
}