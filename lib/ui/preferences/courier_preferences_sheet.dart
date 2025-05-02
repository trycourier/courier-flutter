import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/courier_preference_channel.dart';
import 'package:courier_flutter/models/courier_user_preferences.dart';
import 'package:courier_flutter/ui/courier_theme.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_theme.dart';
import 'package:courier_flutter/utils.dart';
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

  String getSwitchSemanticsLabel() {
    String activeThumb = widget.theme.sheetSettingStyles?.activeThumbColor?.toHex() ?? 'null';
    String activeTrack = widget.theme.sheetSettingStyles?.activeTrackColor?.toHex() ?? 'null';
    String inactiveThumb = widget.theme.sheetSettingStyles?.inactiveThumbColor?.toHex() ?? 'null';
    String inactiveTrack = widget.theme.sheetSettingStyles?.inactiveTrackColor?.toHex() ?? 'null';
    String label = 'Switch activeThumbColor: $activeThumb, activeTrackColor: $activeTrack, inactiveThumbColor: $inactiveThumb, inactiveTrackColor: $inactiveTrack';
    return Courier.shared.isUITestsActive ? label : 'Switch';
  }

  Widget _getListItem(int index, CourierSheetItem item) {
    final onChanged = item.isDisabled
        ? null
        : (bool value) {
            setState(() {
              widget.items[index].isOn = value;
            });
          };

    return ListTile(
      title: Text(
        item.title,
        style: widget.theme.sheetSettingStyles?.textStyle,
      ),
      onTap: () {
        if (onChanged != null) {
          onChanged(!item.isOn);
        }
      },
      trailing: Semantics(
        label: getSwitchSemanticsLabel(),
        child: Switch(
          activeColor: onChanged == null ? null : widget.theme.sheetSettingStyles?.activeThumbColor,
          activeTrackColor: onChanged == null ? null : widget.theme.sheetSettingStyles?.activeTrackColor,
          inactiveThumbColor: onChanged == null ? null : widget.theme.sheetSettingStyles?.inactiveThumbColor,
          inactiveTrackColor: onChanged == null ? null : widget.theme.sheetSettingStyles?.inactiveTrackColor,
          value: item.isOn,
          onChanged: onChanged,
        )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(CourierTheme.margin),
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).bottomSheetTheme.dragHandleColor ?? Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: CourierTheme.margin, top: CourierTheme.margin / 2, right: CourierTheme.margin, bottom: CourierTheme.margin),
            child: Text(
              widget.topic.topicName,
              style: widget.theme.sheetTitleStyle ?? Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (context, index) => widget.theme.sheetSeparator ?? const SizedBox(),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            itemBuilder: (context, index) => _getListItem(index, widget.items[index]),
          )
        ],
      ),
    );
  }
}
