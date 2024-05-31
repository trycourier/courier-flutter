import 'package:courier_flutter/models/courier_preference_topic.dart';
import 'package:courier_flutter/preferences/courier_preferences.dart';
import 'package:courier_flutter/preferences/courier_preferences_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CourierPreferencesSheet extends StatefulWidget {
  final Mode mode;
  final CourierPreferencesTheme theme;
  final CourierUserPreferencesTopic topic;

  const CourierPreferencesSheet({
    super.key,
    required this.mode,
    required this.theme,
    required this.topic,
  });

  @override
  CourierPreferencesSheetState createState() => CourierPreferencesSheetState();
}

Widget _getListItem(String title) {
  return ListTile(
    title: Text(title),
    trailing: Switch(
      value: true,
      onChanged: (bool value) {
        print(value);
      },
    ),
  );
}

class CourierPreferencesSheetState extends State<CourierPreferencesSheet> {
  Widget _buildContent(BuildContext context) {
    if (widget.mode is TopicMode) {
      return ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) => const Divider(),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 1,
        itemBuilder: (context, index) {
          return _getListItem('Receive Notifications');
        },
      );
    } else if (widget.mode is ChannelsMode) {
      final mode = widget.mode as ChannelsMode;
      return ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) => const Divider(),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mode.channels.length,
        itemBuilder: (context, index) {
          return _getListItem(mode.channels[index].title);
        },
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.topic.topicName),
          ),
          _buildContent(context)
        ],
      ),
    );
  }
}
