import 'package:courier_flutter/models/courier_preference_topic.dart';
import 'package:courier_flutter/ui/courier_theme.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_list_item.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreferenceSection {
  final String title;
  final String id;
  List<CourierUserPreferencesTopic> topics;

  PreferenceSection({
    required this.title,
    required this.id,
    required this.topics,
  });
}

class CourierPreferencesSection extends StatefulWidget {
  final Mode mode;
  final CourierPreferencesTheme theme;
  final PreferenceSection section;
  final Function(CourierUserPreferencesTopic) onTopicClick;

  const CourierPreferencesSection({
    super.key,
    required this.mode,
    required this.theme,
    required this.section,
    required this.onTopicClick,
  });

  @override
  CourierPreferencesSectionState createState() => CourierPreferencesSectionState();
}

class CourierPreferencesSectionState extends State<CourierPreferencesSection> {
  PreferenceSection get _section => widget.section;

  @override
  Widget build(BuildContext context) {

    // Interleave list items with separators
    List<Widget> listItems = [];
    for (int i = 0; i < _section.topics.length; i++) {
      if (i > 0) {
        listItems.add(widget.theme.topicListItemSeparator ?? const SizedBox());
      }
      listItems.add(CourierPreferencesListItem(
        mode: widget.mode,
        theme: widget.theme,
        topic: _section.topics[i],
        onTopicClick: widget.onTopicClick,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: CourierTheme.margin, top: CourierTheme.margin, right: CourierTheme.margin, bottom: CourierTheme.margin / 2),
          child: Text(
            _section.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
        ),
        Column(
          children: listItems,
        ),
      ],
    );
  }
}
