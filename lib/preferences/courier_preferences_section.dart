import 'package:courier_flutter/models/courier_preference_topic.dart';
import 'package:courier_flutter/preferences/courier_preferences_list_item.dart';
import 'package:courier_flutter/preferences/courier_preferences_theme.dart';
import 'package:flutter/material.dart';

class PreferenceSection {
  final String title;
  final String id;
  List<CourierUserPreferencesTopic> topics;
  PreferenceSection({required this.title, required this.id, required this.topics});
}

class CourierPreferencesSection extends StatefulWidget {
  final CourierPreferencesTheme theme;
  final PreferenceSection section;
  final Function(CourierUserPreferencesTopic) onTopicClick;

  const CourierPreferencesSection({super.key, required this.theme, required this.section, required this.onTopicClick});

  @override
  CourierPreferencesSectionState createState() => CourierPreferencesSectionState();
}

class CourierPreferencesSectionState extends State<CourierPreferencesSection> {
  PreferenceSection get _section => widget.section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.grey[300],
          padding: EdgeInsets.all(8.0),
          child: Text(
            _section.title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          children: _section.topics.map((topic) {
            return CourierPreferencesListItem(
              theme: widget.theme,
              topic: topic,
              onTopicClick: widget.onTopicClick,
            );
          }).toList(),
        ),
      ],
    );
  }
}
