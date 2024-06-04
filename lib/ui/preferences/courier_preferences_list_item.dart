import 'dart:convert';

import 'package:courier_flutter/courier_preference_status.dart';
import 'package:courier_flutter/models/courier_preference_topic.dart';
import 'package:courier_flutter/ui/courier_theme.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_theme.dart';
import 'package:flutter/material.dart';

class CourierPreferencesListItem extends StatefulWidget {
  final Mode mode;
  final CourierPreferencesTheme theme;
  final CourierUserPreferencesTopic topic;
  final Function(CourierUserPreferencesTopic) onTopicClick;

  const CourierPreferencesListItem({
    super.key,
    required this.mode,
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

    final title = _topic.topicName;
    var subtitle = "";

    if (widget.mode is TopicMode) {
      subtitle = _topic.status.title;
    } else if (widget.mode is ChannelsMode) {
      final mode = widget.mode as ChannelsMode;
      if (_topic.status == CourierUserPreferencesStatus.optedOut) {
        subtitle = "Off";
      } else if (_topic.status == CourierUserPreferencesStatus.required && _topic.customRouting.isEmpty) {
        subtitle = "On: ${mode.channels.map((channel) => channel.title).join(', ')}";
      } else if (_topic.status == CourierUserPreferencesStatus.optedIn && _topic.customRouting.isEmpty) {
        subtitle = "On: ${mode.channels.map((channel) => channel.title).join(', ')}";
      } else {
        subtitle = "On: ${_topic.customRouting.map((route) => route.title).join(', ')}";
      }
    }

    return Padding(
      padding: const EdgeInsets.all(CourierTheme.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: CourierTheme.margin / 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Courier',
              color: Colors.black54
            ),
          ),
        ],
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
