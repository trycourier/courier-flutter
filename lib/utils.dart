import 'dart:convert';

import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/semantic_property.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_list_item.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_list_item.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_section.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_sheet.dart';
import 'package:courier_flutter/ui/preferences/courier_preferences_theme.dart';
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
    final hex = includeAlpha
      ? toARGB32().toRadixString(16).padLeft(8, '0')
      : toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
    return '${leadingHashSign ? '#' : ''}$hex'.toUpperCase();
  }
}

extension InboxListItemSemanticsExtension on CourierInboxListItem {
  String getSemanticsLabel(BuildContext context, bool showUnreadStyle) {
    final Color unreadColor = theme.getUnreadIndicatorColor(context);
    final TextStyle? titleStyle = theme.getTitleStyle(context, showUnreadStyle);
    final TextStyle? timeStyle = theme.getTimeStyle(context, showUnreadStyle);
    final TextStyle? bodyStyle = theme.getBodyStyle(context, showUnreadStyle);
    final ButtonStyle? buttonStyle = theme.getButtonStyle(context, showUnreadStyle);

    final semanticProperties = SemanticProperties([
      SemanticProperty('unreadColor', unreadColor.toHex()),
      SemanticProperty('titleStyle', titleStyle?.toJsonString() ?? "null"),
      SemanticProperty('timeStyle', timeStyle?.toJsonString() ?? "null"),
      SemanticProperty('bodyStyle', bodyStyle?.toJsonString() ?? "null"),
      SemanticProperty('buttonStyle', buttonStyle?.toJsonString() ?? "null"),
    ]);

    final String label = jsonEncode(semanticProperties.toJson());

    return Courier.shared.isUITestsActive ? label : 'CourierInboxListItem';
  }
}

extension InboxTabSemanticsExtension on CourierTabContent {
  String getSemanticsLabel(BuildContext context) {
    final Color backgroundColor = isActive
        ? theme.getSelectedTabIndicatorBackgroundColor(context)
        : theme.getUnselectedTabIndicatorBackgroundColor(context);

    final TextStyle? textStyle = isActive
        ? theme.getSelectedIndicatorTabTextStyle(context)
        : theme.getUnselectedIndicatorTabTextStyle(context);

    final semanticProperties = SemanticProperties([
      SemanticProperty('backgroundColor', backgroundColor.toHex()),
      SemanticProperty('textStyle', textStyle?.toJsonString() ?? "null"),
    ]);

    final String label = jsonEncode(semanticProperties.toJson());

    return Courier.shared.isUITestsActive ? label : 'CourierTabContent';
  }
}

extension PreferencesListItemSemanticsExtension on CourierPreferencesListItem {
  String getSemanticsLabel(BuildContext context) {
    final TextStyle? titleStyle = theme.topicTitleStyle;
    final TextStyle? subtitleStyle = theme.topicSubtitleStyle;

    final SemanticProperties semanticProperties = SemanticProperties([
      SemanticProperty('titleStyle', titleStyle?.toJsonString() ?? "null"),
      SemanticProperty('subtitleStyle', subtitleStyle?.toJsonString() ?? "null"),
    ]);

    final String label = jsonEncode(semanticProperties.toJson());

    return Courier.shared.isUITestsActive ? label : 'CourierPreferencesListItem';
  }
}

extension PreferencesSectionSemanticsExtension on CourierPreferencesSection {
  String getSemanticsLabel(BuildContext context) {
    final TextStyle? titleStyle = theme.sectionTitleStyle ?? Theme.of(context).textTheme.titleLarge;

    final SemanticProperties semanticProperties = SemanticProperties([
      SemanticProperty('titleStyle', titleStyle?.toJsonString() ?? "null"),
    ]);

    final String label = jsonEncode(semanticProperties.toJson());

    return Courier.shared.isUITestsActive ? label : 'CourierPreferencesSection';
  }
}

extension PreferencesSheetSemanticsExtension on CourierPreferencesSheet {
  String getSemanticsLabel() {
    final String activeThumb = theme.sheetSettingStyles?.activeThumbColor?.toHex() ?? 'null';
    final String activeTrack = theme.sheetSettingStyles?.activeTrackColor?.toHex() ?? 'null';
    final String inactiveThumb = theme.sheetSettingStyles?.inactiveThumbColor?.toHex() ?? 'null';
    final String inactiveTrack = theme.sheetSettingStyles?.inactiveTrackColor?.toHex() ?? 'null';

    final SemanticProperties semanticProperties = SemanticProperties([
      SemanticProperty('activeThumbColor', activeThumb),
      SemanticProperty('activeTrackColor', activeTrack),
      SemanticProperty('inactiveThumbColor', inactiveThumb),
      SemanticProperty('inactiveTrackColor', inactiveTrack),
    ]);

    final String label = jsonEncode(semanticProperties.toJson());

    return Courier.shared.isUITestsActive ? label : 'CourierPreferencesSheet';
  }
}

extension UnreadCountIndicatorSemanticsExtension on UnreadCountIndicator {
  String getSemanticsLabel(Color background) {
    final String backgroundColor = background.toHex();

    final SemanticProperties semanticProperties = SemanticProperties([
      SemanticProperty('backgroundColor', backgroundColor),
    ]);

    final String label = jsonEncode(semanticProperties.toJson());

    return Courier.shared.isUITestsActive ? label : 'UnreadCountIndicator';
  }
}

extension SemanticsExtension on CourierPreferences {
  String getSemanticsLabel(BuildContext context, CourierPreferencesTheme theme) {
    final String loadingColor = theme.getLoadingColor(context).toHex();

    final SemanticProperties semanticProperties = SemanticProperties([
      SemanticProperty('loadingColor', loadingColor),
    ]);

    final String label = jsonEncode(semanticProperties.toJson());

    return Courier.shared.isUITestsActive ? label : 'RefreshIndicator';
  }
}

extension TextStyleToJsonString on TextStyle {
  String toJsonString() {
    return jsonEncode(toJson());
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'fontWeight': fontWeight.toString(),
      'fontStyle': fontStyle?.index,
      'color': color?.toHex(),
      'backgroundColor': backgroundColor?.toHex(),
      'decoration': decoration.toString(),
      'decorationColor': decorationColor?.toHex(),
      'decorationStyle': decorationStyle?.index,
      'decorationThickness': decorationThickness,
      'fontFamily': fontFamily,
      'fontFeatures': fontFeatures?.map((e) => e.toString()).toList(),
      'letterSpacing': letterSpacing,
      'wordSpacing': wordSpacing,
      'height': height,
      'locale': locale?.toLanguageTag(),
      'textBaseline': textBaseline?.index,
    };
  }
}

extension ButtonStyleToJsonString on ButtonStyle {
  String toJsonString() {
    return jsonEncode(toJson());
  }

  Map<String, dynamic> toJson() {
    return {
      'foregroundColor': foregroundColor?.resolve({})?.toHex(),
      'backgroundColor': backgroundColor?.resolve({})?.toHex(),
    };
  }
}
