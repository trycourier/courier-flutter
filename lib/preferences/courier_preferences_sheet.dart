import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/models/courier_preference_topic.dart';
import 'package:courier_flutter/preferences/courier_preferences.dart';
import 'package:courier_flutter/preferences/courier_preferences_theme.dart';
import 'package:flutter/material.dart';

class CourierSheetItem {
  final String title;
  bool isOn;
  final bool isDisabled;
  final CourierUserPreferencesChannel? channel;

  CourierSheetItem({
    required this.title,
    required this.isOn,
    required this.isDisabled,
    required this.channel,
  });
}

class CourierPreferencesSheet extends StatefulWidget {
  final Mode mode;
  final CourierPreferencesTheme theme;
  final CourierUserPreferencesTopic topic;
  final List<CourierSheetItem> items;

  const CourierPreferencesSheet({
    super.key,
    required this.mode,
    required this.theme,
    required this.topic,
    required this.items,
  });

  @override
  CourierPreferencesSheetState createState() => CourierPreferencesSheetState();
}

class CourierPreferencesSheetState extends State<CourierPreferencesSheet> {

  Widget _getListItem(int index, CourierSheetItem item) {

    final onChanged = item.isDisabled ? null : (bool value) {
      setState(() {
        widget.items[index].isOn = value;
      });
    };

    return ListTile(
      title: Text(item.title),
      onTap: () {
        if (onChanged != null) {
          onChanged(!item.isOn);
        }
      },
      trailing: Switch(
        value: item.isOn,
        onChanged: onChanged,
      ),
    );

  }

  Widget _buildContent(BuildContext context) {

    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => const Divider(),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      itemBuilder: (context, index) => _getListItem(index, widget.items[index]),
    );

    // if (widget.mode is TopicMode) {
    //   return ListView.separated(
    //     shrinkWrap: true,
    //     separatorBuilder: (context, index) => const Divider(),
    //     physics: const NeverScrollableScrollPhysics(),
    //     itemCount: 1,
    //     itemBuilder: (context, index) {
    //       return _getListItem('Receive Notifications');
    //     },
    //   );
    // } else if (widget.mode is ChannelsMode) {
    //   final mode = widget.mode as ChannelsMode;
    //   return ListView.separated(
    //     shrinkWrap: true,
    //     separatorBuilder: (context, index) => const Divider(),
    //     physics: const NeverScrollableScrollPhysics(),
    //     itemCount: mode.channels.length,
    //     itemBuilder: (context, index) => _getListItem(mode.channels[index].title),
    //   );
    // } else {
    //   return const SizedBox();
    // }
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
