import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/courier_preference_status.dart';

class CourierUserPreferencesTopic {
  final CourierUserPreferencesStatus defaultStatus;
  final bool hasCustomRouting;
  final List<CourierUserPreferencesChannel> customRouting;
  final CourierUserPreferencesStatus status;
  final String topicId;
  final String topicName;

  CourierUserPreferencesTopic({
    required this.defaultStatus,
    required this.hasCustomRouting,
    required this.customRouting,
    required this.status,
    required this.topicId,
    required this.topicName,
  });

  factory CourierUserPreferencesTopic.fromJson(dynamic data) {
    return CourierUserPreferencesTopic(
      defaultStatus: CourierUserPreferencesStatus.fromJson(data['defaultStatus']),
      hasCustomRouting: data['hasCustomRouting'],
      customRouting: (data['customRouting'] as List).map((e) => CourierUserPreferencesChannel.fromJson(e)).toList(),
      status: CourierUserPreferencesStatus.fromJson(data['status']),
      topicId: data['topicId'],
      topicName: data['topicName'],
    );
  }
}