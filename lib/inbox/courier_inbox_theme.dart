import 'package:flutter/material.dart';

class CourierInboxTheme {
  Color? _loadingIndicatorColor;
  CourierInboxUnreadIndicatorStyle? _unreadIndicatorStyle;
  TextStyle? _bodyStyle;
  ButtonStyle? _buttonStyle;

  CourierInboxTheme({
    Color? loadingIndicatorColor,
    CourierInboxUnreadIndicatorStyle? unreadIndicatorStyle,
    TextStyle? bodyStyle,
    ButtonStyle? buttonStyle,
  }) {
    _loadingIndicatorColor = loadingIndicatorColor;
    _unreadIndicatorStyle = unreadIndicatorStyle;
    _bodyStyle = bodyStyle;
    _buttonStyle = buttonStyle;
  }

  ButtonStyle? getButtonStyle(BuildContext context) {
    return _buttonStyle ?? Theme.of(context).elevatedButtonTheme.style;
  }

  Color getLoadingColor(BuildContext context) {
    return _loadingIndicatorColor ?? Theme.of(context).primaryColor;
  }

  Color getUnreadIndicatorColor(BuildContext context) {
    return _unreadIndicatorStyle?.color ?? Theme.of(context).primaryColor;
  }

  TextStyle? getBodyStyle(BuildContext context) {
    return _bodyStyle ?? Theme.of(context).textTheme.bodyMedium;
  }

}

class CourierInboxTextStyle {
  TextStyle? unread;
  TextStyle? read;

  CourierInboxTextStyle({
    this.unread,
    this.read,
  });
}

enum CourierInboxUnreadIndicator { line, dot }

class CourierInboxUnreadIndicatorStyle {
  final CourierInboxUnreadIndicator indicator;
  final Color? color;

  CourierInboxUnreadIndicatorStyle({
    this.indicator = CourierInboxUnreadIndicator.line,
    this.color,
  });
}
