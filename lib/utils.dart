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
