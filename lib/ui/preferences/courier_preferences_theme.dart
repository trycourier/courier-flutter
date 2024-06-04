import 'package:courier_flutter/models/courier_brand.dart';
import 'package:flutter/material.dart';

import '../inbox/courier_inbox_theme.dart';

class CourierPreferencesTheme {

  final String? brandId;
  final Color? loadingIndicatorColor;
  final Widget? topicListItemSeparator;
  final Widget? sheetListItemSeparator;
  final CourierInboxInfoViewStyle? infoViewStyle;

  CourierBrand? brand;

  CourierPreferencesTheme({
    this.brandId,
    this.loadingIndicatorColor,
    this.infoViewStyle,
    this.topicListItemSeparator = const Divider(height: 1, indent: 16, endIndent: 16),
    this.sheetListItemSeparator = const Divider(height: 1, indent: 16, endIndent: 16),
  });

  Color? get _brandColor => brand?.settings?.colors?.primaryColor();

  ButtonStyle? _brandButtonColor(BuildContext context) {

    final themeStyles = Theme.of(context).elevatedButtonTheme.style;

    final backgroundColor = _brandColor != null ? MaterialStateProperty.all(_brandColor) : themeStyles?.backgroundColor;

    return ButtonStyle(
      textStyle: themeStyles?.textStyle,
      backgroundColor: backgroundColor,
      foregroundColor: themeStyles?.foregroundColor,
      overlayColor: themeStyles?.overlayColor,
      shadowColor: themeStyles?.shadowColor,
      surfaceTintColor: themeStyles?.surfaceTintColor,
      elevation: themeStyles?.elevation,
      padding: themeStyles?.padding,
      minimumSize: themeStyles?.minimumSize,
      fixedSize: themeStyles?.fixedSize,
      maximumSize: themeStyles?.maximumSize,
      iconColor: themeStyles?.iconColor,
      iconSize: themeStyles?.iconSize,
      side: themeStyles?.side,
      shape: themeStyles?.shape,
      mouseCursor: themeStyles?.mouseCursor,
      visualDensity: themeStyles?.visualDensity,
      tapTargetSize: themeStyles?.tapTargetSize,
      animationDuration: themeStyles?.animationDuration,
      enableFeedback: themeStyles?.enableFeedback,
      alignment: themeStyles?.alignment,
      splashFactory: themeStyles?.splashFactory,
    );

  }

  Color getLoadingColor(BuildContext context) {
    return loadingIndicatorColor ?? _brandColor ?? Theme.of(context).primaryColor;
  }

  TextStyle? getInfoViewTitleStyle(BuildContext context) {
    return infoViewStyle?.textStyle ?? Theme.of(context).textTheme.titleMedium;
  }

  ButtonStyle? getInfoViewButtonStyle(BuildContext context) {
    return infoViewStyle?.buttonStyle ?? _brandButtonColor(context);
  }

}
