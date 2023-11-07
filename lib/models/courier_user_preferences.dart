import 'package:courier_flutter/models/courier_pagination.dart';
import 'package:courier_flutter/models/courier_preference_topic.dart';

class CourierUserPreferences {

  final List<CourierUserPreferencesTopic> items;
  final CourierPagination paging;

  CourierUserPreferences({
    required this.items,
    required this.paging,
  });

  factory CourierUserPreferences.fromJson(dynamic data) {
    List<dynamic>? items = data['items'];
    List<CourierUserPreferencesTopic>? topics = items?.map((item) => CourierUserPreferencesTopic.fromJson(item)).toList();
    return CourierUserPreferences(
      items: topics ??= [],
      paging: CourierPagination.fromJson(data['paging']),
    );
  }

}