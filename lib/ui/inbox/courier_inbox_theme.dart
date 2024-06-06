import 'package:courier_flutter/models/courier_brand.dart';
import 'package:flutter/material.dart';

class CourierInboxTheme {

  final String? brandId;
  final Color? loadingIndicatorColor;
  final CourierInboxUnreadIndicatorStyle unreadIndicatorStyle;
  final CourierInboxTextStyle? titleStyle;
  final CourierInboxTextStyle? timeStyle;
  final CourierInboxTextStyle? bodyStyle;
  final CourierInboxButtonStyle? buttonStyle;
  final CourierInfoViewStyle? infoViewStyle;
  final Widget? separator;

  CourierBrand? brand;

  CourierInboxTheme({
    this.brandId,
    this.loadingIndicatorColor,
    this.unreadIndicatorStyle = const CourierInboxUnreadIndicatorStyle(),
    this.titleStyle,
    this.timeStyle,
    this.bodyStyle,
    this.buttonStyle,
    this.infoViewStyle,
    this.separator = const Divider(height: 1, indent: 16, endIndent: 16),
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

  ButtonStyle? getButtonStyle(BuildContext context, bool isRead) {
    return (isRead ? buttonStyle?.read : buttonStyle?.unread) ?? _brandButtonColor(context);
  }

  Color getLoadingColor(BuildContext context) {
    return loadingIndicatorColor ?? _brandColor ?? Theme.of(context).primaryColor;
  }

  Color getUnreadIndicatorColor(BuildContext context) {
    return unreadIndicatorStyle.color ?? _brandColor ?? Theme.of(context).primaryColor;
  }

  TextStyle? getTitleStyle(BuildContext context, bool isRead) {
    return (isRead ? titleStyle?.read : titleStyle?.unread) ?? Theme.of(context).textTheme.titleMedium;
  }

  TextStyle? getBodyStyle(BuildContext context, bool isRead) {
    return (isRead ? bodyStyle?.read : bodyStyle?.unread) ?? Theme.of(context).textTheme.bodyMedium;
  }

  TextStyle? getTimeStyle(BuildContext context, bool isRead) {
    return (isRead ? timeStyle?.read : timeStyle?.unread) ?? Theme.of(context).textTheme.labelMedium;
  }

  TextStyle? getInfoViewTitleStyle(BuildContext context) {
    return infoViewStyle?.textStyle ?? Theme.of(context).textTheme.titleMedium;
  }

  ButtonStyle? getInfoViewButtonStyle(BuildContext context) {
    return infoViewStyle?.buttonStyle ?? _brandButtonColor(context);
  }

}

class CourierInboxTextStyle {
  final TextStyle? unread;
  final TextStyle? read;

  const CourierInboxTextStyle({
    this.unread,
    this.read,
  });
}

class CourierInboxButtonStyle {
  final ButtonStyle? unread;
  final ButtonStyle? read;

  const CourierInboxButtonStyle({
    this.unread,
    this.read,
  });
}

enum CourierInboxUnreadIndicator { line, dot }

class CourierInboxUnreadIndicatorStyle {
  final CourierInboxUnreadIndicator indicator;
  final Color? color;

  const CourierInboxUnreadIndicatorStyle({
    this.indicator = CourierInboxUnreadIndicator.line,
    this.color,
  });
}

class CourierInfoViewStyle {
  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;

  const CourierInfoViewStyle({
    this.textStyle,
    this.buttonStyle,
  });

}
