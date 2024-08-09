import 'dart:convert';

import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/courier_preference_status.dart';
import 'package:courier_flutter/models/courier_user_preferences.dart';

class PreferenceClient {
  final CourierClientOptions _options;

  PreferenceClient(this._options);

  Future<CourierUserPreferences> getUserPreferences({String? paginationCursor}) async {
    final data = await _options.invokeClient('client.preferences.get_user_preferences', {
      'paginationCursor': paginationCursor,
    });
    final Map<String, dynamic> map = json.decode(data);
    return CourierUserPreferences.fromJson(map);
  }

  Future<GetCourierUserPreferencesTopic> getUserPreferenceTopic({required String topicId}) async {
    final data = await _options.invokeClient('client.preferences.get_user_preference_topic', {
      'topicId': topicId,
    });
    final Map<String, dynamic> map = json.decode(data);
    return GetCourierUserPreferencesTopic.fromJson(map);
  }

  Future putUserPreferencesTopic({required String topicId, required CourierUserPreferencesStatus status, required bool hasCustomRouting, required List<CourierUserPreferencesChannel> customRouting}) async {
    await _options.invokeClient('client.preferences.put_user_preferences_topic', {
      'topicId': topicId,
      'status': status.value,
      'hasCustomRouting': hasCustomRouting,
      'customRouting': customRouting.map((e) => e.value).toList(),
    });
  }

}