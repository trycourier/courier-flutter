import 'dart:convert';

import 'package:courier_flutter/models/courier_preference_topic.dart';
import 'package:courier_flutter/preferences/courier_preferences_theme.dart';
import 'package:flutter/material.dart';

class CourierPreferencesListItem extends StatefulWidget {
  final CourierPreferencesTheme theme;
  final CourierUserPreferencesTopic topic;
  final Function(CourierUserPreferencesTopic) onTopicClick;

  const CourierPreferencesListItem({
    super.key,
    required this.theme,
    required this.topic,
    required this.onTopicClick,
  });

  @override
  CourierPreferencesListItemState createState() => CourierPreferencesListItemState();
}

class CourierPreferencesListItemState extends State<CourierPreferencesListItem> {
  CourierUserPreferencesTopic get _topic => widget.topic;

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        jsonEncode({
          'topicId': _topic.topicId,
          'topicName': _topic.topicName,
          'sectionName': _topic.sectionName,
          'sectionId': _topic.sectionId,
        }),
        style: const TextStyle(
          fontFamily: 'Courier',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onTopicClick(widget.topic),
        child: _buildContent(context),
      ),
    );
  }
}
