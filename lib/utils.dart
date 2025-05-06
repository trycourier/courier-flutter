import 'package:courier_flutter/courier_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

extension WidgetListExtensions on List<Widget> {

  List<Widget> addSeparator(Widget Function() separatorBuilder) {
    if (isEmpty) {
      return this;
    }

    List<Widget> resultList = [];
    for (int i = 0; i < length; i++) {
      resultList.add(this[i]);
      if (i != length - 1) {
        Widget separator = separatorBuilder();
        resultList.add(separator);
      }
    }
    return resultList;
  }

}

Color hexToColor(String hexColor) {
  // Remove the '#' character if present
  hexColor = hexColor.replaceAll("#", "");

  // Parse the hex color code
  int hexValue = int.parse(hexColor, radix: 16);

  // Create a Color object from the hex value
  return Color(hexValue | 0xFF000000);
}

void launchCourierURL() async {
  final url = Uri.parse('https://www.courier.com');
  if (!await launchUrl(url) && kDebugMode) {
    print('Could not launch $url');
  }
}

extension AnimatedListStateExtensions on AnimatedListState {

  Future<void> insertItemAwaitable(int index, {Duration duration = const Duration(milliseconds: 300)}) async {
    await Future.wait([
      Future.delayed(duration),
      Future(() => insertItem(index, duration: duration))
    ]);
  }

  Future<void> removeItemAwaitable(int index, AnimatedRemovedItemBuilder builder, { Duration duration = const Duration(milliseconds: 300) }) async {
    await Future.wait([
      Future.delayed(duration),
      Future(() => removeItem(index, builder, duration: duration))
    ]);
  }

}

extension HexColor on Color {
  String toHex({bool leadingHashSign = true, bool includeAlpha = false}) {
    final buffer = StringBuffer();
    if (leadingHashSign) buffer.write('#');
    if (includeAlpha) buffer.write((a.round()).toRadixString(16).padLeft(2, '0'));
    buffer.write((r.round()).toRadixString(16).padLeft(2, '0'));
    buffer.write((g.round()).toRadixString(16).padLeft(2, '0'));
    buffer.write((b.round()).toRadixString(16).padLeft(2, '0'));
    return buffer.toString().toUpperCase();
  }
}

String getInboxListItemSemanticsLabel(widget, context, bool showUnreadStyle) {
  Color unreadColor = widget.theme.getUnreadIndicatorColor(context);
  TextStyle? titleStyle = widget.theme.getTitleStyle(context, showUnreadStyle);
  String titleLabel = 'fontColor: ${titleStyle?.color?.toHex()}, fontName: ${titleStyle?.fontFamily}, fontSize: ${titleStyle?.fontSize}';
  TextStyle? timeStyle = widget.theme.getTimeStyle(context, showUnreadStyle);
  String timeLabel = 'fontColor: ${timeStyle?.color?.toHex()}, fontName: ${timeStyle?.fontFamily}, fontSize: ${timeStyle?.fontSize}';
  TextStyle? bodyStyle = widget.theme.getBodyStyle(context, showUnreadStyle);
  String bodyLabel = 'fontColor: ${bodyStyle?.color?.toHex()}, fontName: ${bodyStyle?.fontFamily}, fontSize: ${bodyStyle?.fontSize}';
  ButtonStyle? buttonStyle = widget.theme.getButtonStyle(context, showUnreadStyle);
  String buttonLabel = 'backgroundColor: ${buttonStyle?.backgroundColor?.resolve({WidgetState.pressed})?.toHex()}, fontName: ${buttonStyle?.textStyle?.resolve({WidgetState.pressed})?.fontFamily}, fontSize: ${buttonStyle?.textStyle?.resolve({WidgetState.pressed})?.fontSize}';
  String label = 'ListRow unreadColor: ${unreadColor.toHex()}, titleLabel: {$titleLabel}, timeLabel: {$timeLabel}, bodyLabel: {$bodyLabel}, buttonLabel: {$buttonLabel}';
  return Courier.shared.isUITestsActive ? label : 'ListRow';
}

String getInboxTabSemanticsLabel(widget, context) {
  Color backgroundColor = widget.isActive ? widget.theme.getSelectedTabIndicatorBackgroundColor(context) : widget.theme.getUnselectedTabIndicatorBackgroundColor(context);
  TextStyle? textStyle = widget.isActive ? widget.theme.getSelectedIndicatorTabTextStyle(context) : widget.theme.getUnselectedIndicatorTabTextStyle(context);
  String label = 'CourierTabContent backgroundColor: ${backgroundColor.toHex()}, fontColor: ${textStyle?.color?.toHex()}, fontName: ${textStyle?.fontFamily}, fontSize: ${textStyle?.fontSize}';
  return Courier.shared.isUITestsActive ? label : 'CourierTabContent';
}

String getPreferencesListItemSemanticsLabel(widget, context) {
  TextStyle? titleStyle = widget.theme.topicTitleStyle;
  String titleLabel = 'fontColor: ${titleStyle?.color?.toHex()}, fontName: ${titleStyle?.fontFamily}, fontSize: ${titleStyle?.fontSize}';
  TextStyle? subtitleStyle = widget.theme.topicSubtitleStyle;
  String subtitleLabel = 'fontColor: ${subtitleStyle?.color?.toHex()}, fontName: ${subtitleStyle?.fontFamily}, fontSize: ${subtitleStyle?.fontSize}';
  String label = 'ListTile titleLabel: {$titleLabel}, subtitleLabel: {$subtitleLabel}';
  return Courier.shared.isUITestsActive ? label : 'ListTile';
}

String getPreferencesSectionSemanticsLabel(widget, context) {
  TextStyle? titleStyle = widget.theme.sectionTitleStyle ?? Theme.of(context).textTheme.titleLarge;
  String label = 'CourierPreferencesSection fontColor: ${titleStyle?.color?.toHex()}, fontName: ${titleStyle?.fontFamily}, fontSize: ${titleStyle?.fontSize}';
  return Courier.shared.isUITestsActive ? label : 'CourierPreferencesSection';
}

String getPreferencesSheetSwitchSemanticsLabel(widget) {
  String activeThumb = widget.theme.sheetSettingStyles?.activeThumbColor?.toHex() ?? 'null';
  String activeTrack = widget.theme.sheetSettingStyles?.activeTrackColor?.toHex() ?? 'null';
  String inactiveThumb = widget.theme.sheetSettingStyles?.inactiveThumbColor?.toHex() ?? 'null';
  String inactiveTrack = widget.theme.sheetSettingStyles?.inactiveTrackColor?.toHex() ?? 'null';
  String label = 'Switch activeThumbColor: $activeThumb, activeTrackColor: $activeTrack, inactiveThumbColor: $inactiveThumb, inactiveTrackColor: $inactiveTrack';
  return Courier.shared.isUITestsActive ? label : 'Switch';
}
