import 'package:flutter/material.dart';

class CourierInboxTheme {

  final Color? loadingIndicatorColor;
  final CourierInboxUnreadIndicatorStyle unreadIndicatorStyle;
  final CourierInboxTextStyle? titleStyle;
  final CourierInboxTextStyle? timeStyle;
  final CourierInboxTextStyle? bodyStyle;
  final CourierInboxButtonStyle? buttonStyle;
  final Widget? separator;

  CourierInboxTheme({
    this.loadingIndicatorColor,
    this.unreadIndicatorStyle = const CourierInboxUnreadIndicatorStyle(),
    this.titleStyle,
    this.timeStyle,
    this.bodyStyle,
    this.buttonStyle,
    this.separator = const Divider(height: 1, indent: 16, endIndent: 16),
  });

  ButtonStyle? getButtonStyle(BuildContext context, bool isRead) {
    return (isRead ? buttonStyle?.read : buttonStyle?.unread) ?? Theme.of(context).elevatedButtonTheme.style;
  }

  Color getLoadingColor(BuildContext context) {
    return loadingIndicatorColor ?? Theme.of(context).primaryColor;
  }

  Color getUnreadIndicatorColor(BuildContext context) {
    return unreadIndicatorStyle.color ?? Theme.of(context).primaryColor;
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
