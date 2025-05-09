import 'package:courier_flutter/courier_preference_status.dart';
import 'package:courier_flutter/models/courier_user_preferences.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_theme.dart';
import 'package:courier_flutter/utils.dart';
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

  @override
  Widget build(BuildContext context) {
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

    return Semantics(
      label: widget.getSemanticsLabel(context),
      child: ListTile(
        title: Text(
          title,
          style: widget.theme.topicTitleStyle,
        ),
        subtitle: Text(
          subtitle,
          style: widget.theme.topicSubtitleStyle,
        ),
        trailing: widget.theme.topicTrailing,
        onTap: () => widget.onTopicClick(widget.topic),
      )
    );
  }
}
