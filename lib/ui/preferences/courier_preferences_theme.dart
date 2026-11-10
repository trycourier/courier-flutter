import 'package:courier_flutter/models/courier_brand.dart';
import 'package:courier_flutter/ui/courier_background.dart';
import 'package:flutter/material.dart';

import '../inbox/courier_inbox_theme.dart';

class CourierPreferencesTheme {
  final String? brandId;

  /// Fills the whole preferences view and the topic sheet: the list, and the loading, empty
  /// and error states. Default text, icon and divider colors switch to white or black so they
  /// stay readable on it. Styles you set yourself are used as they are.
  final Color? backgroundColor;
  final Color? loadingIndicatorColor;
  final TextStyle? sectionTitleStyle;
  final Widget? topicSeparator;
  final TextStyle? topicTitleStyle;
  final TextStyle? topicSubtitleStyle;
  final Widget? topicTrailing;
  final TextStyle? sheetTitleStyle;
  final Widget? sheetSeparator;
  final SheetSettingStyles? sheetSettingStyles;
  final ShapeBorder? sheetShape;
  final CourierInfoViewStyle? infoViewStyle;

  CourierBrand? brand;

  CourierPreferencesTheme({
    this.brandId,
    this.backgroundColor,
    this.loadingIndicatorColor,
    this.topicSeparator = const Divider(height: 1, indent: 16, endIndent: 16),
    this.sectionTitleStyle,
    this.topicTitleStyle,
    this.topicSubtitleStyle,
    this.topicTrailing,
    this.sheetTitleStyle,
    this.sheetSettingStyles,
    this.sheetShape,
    this.sheetSeparator = const Divider(height: 1, indent: 16, endIndent: 16),
    this.infoViewStyle,
  });

  Color? get _brandColor => brand?.settings?.colors?.primaryColor();

  ButtonStyle? _brandButtonColor(BuildContext context) {
    final themeStyles = Theme.of(context).elevatedButtonTheme.style;

    final backgroundColor = _brandColor != null ? WidgetStateProperty.all(_brandColor) : themeStyles?.backgroundColor;

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
    return loadingIndicatorColor ?? _brandColor ?? Theme.of(context).courierAccentColor;
  }

  TextStyle? getInfoViewTitleStyle(BuildContext context) {
    return mergeCourierTextStyle(Theme.of(context).textTheme.titleMedium, infoViewStyle?.textStyle);
  }

  ButtonStyle? getInfoViewButtonStyle(BuildContext context) {
    return infoViewStyle?.buttonStyle ?? _brandButtonColor(context);
  }

  TextStyle? getSectionTitleStyle(BuildContext context) {
    return mergeCourierTextStyle(Theme.of(context).textTheme.titleLarge, sectionTitleStyle);
  }

  TextStyle? getSheetTitleStyle(BuildContext context) {
    return mergeCourierTextStyle(Theme.of(context).textTheme.titleLarge, sheetTitleStyle);
  }

}

class SheetSettingStyles {

  final TextStyle? textStyle;
  final Color? activeThumbColor;
  final Color? activeTrackColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;

  SheetSettingStyles({
    this.textStyle,
    this.activeThumbColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
  });

}
