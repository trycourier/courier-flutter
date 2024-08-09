import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/courier_preference_status.dart';
import 'package:flutter/foundation.dart';

class CourierUserPreferences {
  final List<CourierUserPreferencesTopic> items;
  final Paging paging;

  CourierUserPreferences({
    required this.items,
    required this.paging,
  });

  factory CourierUserPreferences.fromJson(Map<String, dynamic> json) {
    return CourierUserPreferences(
      items: (json['items'] as List)
          .map((i) => CourierUserPreferencesTopic.fromJson(i as Map<String, dynamic>))
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

class CourierUserPreferencesTopic {
  final CourierUserPreferencesStatus defaultStatus;
  final bool hasCustomRouting;
  final List<CourierUserPreferencesChannel> customRouting;
  final CourierUserPreferencesStatus status;
  final String topicId;
  final String topicName;
  final String sectionName;
  final String sectionId;

  CourierUserPreferencesTopic({
    required this.defaultStatus,
    required this.hasCustomRouting,
    required this.customRouting,
    required this.status,
    required this.topicId,
    required this.topicName,
    required this.sectionName,
    required this.sectionId,
  });

  factory CourierUserPreferencesTopic.fromJson(Map<String, dynamic> json) {
    return CourierUserPreferencesTopic(
      defaultStatus: CourierUserPreferencesStatus.fromJson(json['default_status'] as String),
      hasCustomRouting: json['has_custom_routing'] as bool,
      customRouting: (json['custom_routing'] as List<dynamic>).map((item) => CourierUserPreferencesChannel.fromJson(item)).toList(),
      status: CourierUserPreferencesStatus.fromJson(json['status'] as String),
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

  bool isEqual(CourierUserPreferencesTopic topic) {

    if (this == topic) return true;

    return defaultStatus == topic.defaultStatus &&
        hasCustomRouting == topic.hasCustomRouting &&
        listEquals(customRouting, topic.customRouting) &&
        status == topic.status &&
        topicId == topic.topicId &&
        topicName == topic.topicName &&
        sectionName == topic.sectionName &&
        sectionId == topic.sectionId;
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

class GetCourierUserPreferencesTopic {
  final CourierUserPreferencesTopic topic;

  GetCourierUserPreferencesTopic({
    required this.topic,
  });

  factory GetCourierUserPreferencesTopic.fromJson(Map<String, dynamic> json) {
    return GetCourierUserPreferencesTopic(
      topic: CourierUserPreferencesTopic.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic.toJson(),
    };
  }
}