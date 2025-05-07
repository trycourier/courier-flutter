import 'dart:convert';

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
    final hex = includeAlpha
      ? toARGB32().toRadixString(16).padLeft(8, '0')
      : toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
    return '${leadingHashSign ? '#' : ''}$hex'.toUpperCase();
  }
}

String getInboxListItemSemanticsLabel(widget, context, bool showUnreadStyle) {
  Color unreadColor = widget.theme.getUnreadIndicatorColor(context);
  TextStyle? titleStyle = widget.theme.getTitleStyle(context, showUnreadStyle);
  TextStyle? timeStyle = widget.theme.getTimeStyle(context, showUnreadStyle);
  TextStyle? bodyStyle = widget.theme.getBodyStyle(context, showUnreadStyle);
  ButtonStyle? buttonStyle = widget.theme.getButtonStyle(context, showUnreadStyle);
  SemanticProperties semanticProperties = SemanticProperties([
    SemanticProperty('unreadColor', unreadColor.toHex()),
    SemanticProperty('titleStyle', titleStyle?.toJsonString() ?? "null"),
    SemanticProperty('timeStyle', timeStyle?.toJsonString() ?? "null"),
    SemanticProperty('bodyStyle', bodyStyle?.toJsonString() ?? "null"),
    SemanticProperty('buttonStyle', buttonStyle?.toJsonString() ?? "null"),
  ]);
  String label = jsonEncode(semanticProperties.toJson());
  return Courier.shared.isUITestsActive ? label : 'ListRow';
}

String getInboxTabSemanticsLabel(widget, context) {
  Color backgroundColor = widget.isActive ? widget.theme.getSelectedTabIndicatorBackgroundColor(context) : widget.theme.getUnselectedTabIndicatorBackgroundColor(context);
  TextStyle? textStyle = widget.isActive ? widget.theme.getSelectedIndicatorTabTextStyle(context) : widget.theme.getUnselectedIndicatorTabTextStyle(context);
  SemanticProperties semanticProperties = SemanticProperties([
    SemanticProperty('backgroundColor', backgroundColor.toHex()),
    SemanticProperty('textStyle', textStyle?.toJsonString() ?? "null"),
  ]);
  String label = jsonEncode(semanticProperties.toJson());
  return Courier.shared.isUITestsActive ? label : 'CourierTabContent';
}

String getPreferencesListItemSemanticsLabel(widget, context) {
  TextStyle? titleStyle = widget.theme.topicTitleStyle;
  TextStyle? subtitleStyle = widget.theme.topicSubtitleStyle;
  SemanticProperties semanticProperties = SemanticProperties([
    SemanticProperty('titleStyle', titleStyle?.toJsonString() ?? "null"),
    SemanticProperty('subtitleStyle', subtitleStyle?.toJsonString() ?? "null"),
  ]);
  String label = jsonEncode(semanticProperties.toJson());
  return Courier.shared.isUITestsActive ? label : 'ListTile';
}

String getPreferencesSectionSemanticsLabel(widget, context) {
  TextStyle? titleStyle = widget.theme.sectionTitleStyle ?? Theme.of(context).textTheme.titleLarge;
  SemanticProperties semanticProperties = SemanticProperties([
    SemanticProperty('titleStyle', titleStyle?.toJsonString() ?? "null"),
  ]);
  String label = jsonEncode(semanticProperties.toJson());
  return Courier.shared.isUITestsActive ? label : 'CourierPreferencesSection';
}

String getPreferencesSheetSwitchSemanticsLabel(widget) {
  String activeThumb = widget.theme.sheetSettingStyles?.activeThumbColor?.toHex() ?? 'null';
  String activeTrack = widget.theme.sheetSettingStyles?.activeTrackColor?.toHex() ?? 'null';
  String inactiveThumb = widget.theme.sheetSettingStyles?.inactiveThumbColor?.toHex() ?? 'null';
  String inactiveTrack = widget.theme.sheetSettingStyles?.inactiveTrackColor?.toHex() ?? 'null';
  SemanticProperties semanticProperties = SemanticProperties([
    SemanticProperty('activeThumbColor', activeThumb),
    SemanticProperty('activeTrackColor', activeTrack),
    SemanticProperty('inactiveThumbColor', inactiveThumb),
    SemanticProperty('inactiveTrackColor', inactiveTrack),
  ]);
  String label = jsonEncode(semanticProperties.toJson());
  return Courier.shared.isUITestsActive ? label : 'Switch';
}

class SemanticProperty {
  final String name;
  final String value;

  SemanticProperty(this.name, this.value);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }

  factory SemanticProperty.fromJson(Map<String, dynamic> json) {
    return SemanticProperty(
      json['name'],
      json['value'],
    );
  }
}

class SemanticProperties {
  final List<SemanticProperty> properties;

  SemanticProperties(this.properties);

  Map<String, dynamic> toJson() {
    return {
      'properties': properties.map((e) => e.toJson()).toList(),
    };
  }

  factory SemanticProperties.fromJson(Map<String, dynamic> json) {
    return SemanticProperties(
      (json['properties'] as List).map<SemanticProperty>((e) => SemanticProperty.fromJson(e)).toList(),
    );
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
