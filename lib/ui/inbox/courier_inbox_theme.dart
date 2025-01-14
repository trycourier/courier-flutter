import 'package:courier_flutter/models/courier_brand.dart';
import 'package:flutter/material.dart';

class CourierInboxTheme {
  final String? brandId;
  final Color? tabIndicatorColor;
  final CourierInboxTabStyle tabStyle;
  final CourierInboxReadingSwipeActionStyle readingSwipeActionStyle;
  final CourierInboxArchivingSwipeActionStyle archivingSwipeActionStyle;
  final Color? loadingIndicatorColor;
  final CourierInboxUnreadIndicatorStyle unreadIndicatorStyle;
  final CourierInboxTextStyle titleStyle;
  final CourierInboxTextStyle timeStyle;
  final CourierInboxTextStyle bodyStyle;
  final CourierInboxButtonStyle buttonStyle;
  final CourierCellStyle cellStyle;
  final CourierInfoViewStyle infoViewStyle;
  final Widget? separator;

  CourierBrand? brand;

  CourierInboxTheme({
    this.brandId,
    this.tabIndicatorColor,
    this.tabStyle = const CourierInboxTabStyle(),
    this.readingSwipeActionStyle = const CourierInboxReadingSwipeActionStyle(),
    this.archivingSwipeActionStyle = const CourierInboxArchivingSwipeActionStyle(),
    this.loadingIndicatorColor,
    this.unreadIndicatorStyle = const CourierInboxUnreadIndicatorStyle(),
    this.titleStyle = const CourierInboxTextStyle(),
    this.timeStyle = const CourierInboxTextStyle(),
    this.bodyStyle = const CourierInboxTextStyle(),
    this.buttonStyle = const CourierInboxButtonStyle(),
    this.cellStyle = const CourierCellStyle(),
    this.infoViewStyle = const CourierInfoViewStyle(),
    this.separator = const Divider(height: 1, indent: 16, endIndent: 16),
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

  ButtonStyle? getButtonStyle(BuildContext context, bool isRead) {
    return (isRead ? buttonStyle.read : buttonStyle.unread) ?? _brandButtonColor(context);
  }

  Color getLoadingColor(BuildContext context) {
    return loadingIndicatorColor ?? _brandColor ?? Theme.of(context).primaryColor;
  }

  Color getUnreadIndicatorColor(BuildContext context) {
    return unreadIndicatorStyle.color ?? _brandColor ?? Theme.of(context).primaryColor;
  }

  Color getReadSwipeActionColor(BuildContext context) {
    return readingSwipeActionStyle.read.color ?? _brandColor ?? Theme.of(context).primaryColor;
  }

  Color getUnreadSwipeActionColor(BuildContext context) {
    return readingSwipeActionStyle.unread.color ?? _brandColor?.withOpacity(0.7) ?? Theme.of(context).primaryColor.withOpacity(0.7);
  }

  Color getArchiveSwipeActionColor(BuildContext context) {
    return archivingSwipeActionStyle.archive.color ?? Theme.of(context).colorScheme.error;
  }

  Color getTabIndicatorColor(BuildContext context) {
    return tabIndicatorColor ?? _brandColor ?? Theme.of(context).primaryColor;
  }

  TextStyle? getSelectedTabTextStyle(BuildContext context) {
    return tabStyle.selected.font ?? (_brandColor != null ? TextStyle(color: _brandColor) : Theme.of(context).tabBarTheme.labelStyle);
  }

  TextStyle? getUnselectedTabTextStyle(BuildContext context) {
    return tabStyle.unselected.font ?? Theme.of(context).tabBarTheme.unselectedLabelStyle;
  }

  Color getSelectedTabIndicatorBackgroundColor(BuildContext context) {
    return tabStyle.selected.indicator.color ?? _brandColor ?? Theme.of(context).primaryColor;
  }

  Color getUnselectedTabIndicatorBackgroundColor(BuildContext context) {
    return tabStyle.unselected.indicator.color ?? Theme.of(context).tabBarTheme.unselectedLabelStyle?.color ?? Colors.grey;
  }

  TextStyle? getSelectedIndicatorTabTextStyle(BuildContext context) {
    return tabStyle.selected.indicator.font ?? const TextStyle(color: Colors.white);
  }

  TextStyle? getUnselectedIndicatorTabTextStyle(BuildContext context) {
    return tabStyle.unselected.indicator.font ?? Theme.of(context).tabBarTheme.unselectedLabelStyle;
  }

  TextStyle? getTitleStyle(BuildContext context, bool isRead) {
    return (isRead ? titleStyle.read : titleStyle.unread) ?? Theme.of(context).textTheme.titleMedium;
  }

  TextStyle? getBodyStyle(BuildContext context, bool isRead) {
    return (isRead ? bodyStyle.read : bodyStyle.unread) ?? Theme.of(context).textTheme.bodyMedium;
  }

  TextStyle? getTimeStyle(BuildContext context, bool isRead) {
    return (isRead ? timeStyle.read : timeStyle.unread) ?? Theme.of(context).textTheme.labelMedium;
  }

  TextStyle? getInfoViewTitleStyle(BuildContext context) {
    return infoViewStyle.textStyle ?? Theme.of(context).textTheme.titleMedium;
  }

  ButtonStyle? getInfoViewButtonStyle(BuildContext context) {
    return infoViewStyle.buttonStyle ?? _brandButtonColor(context);
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

class CourierInboxTabStyle {
  final CourierInboxTabItemStyle selected;
  final CourierInboxTabItemStyle unselected;

  const CourierInboxTabStyle({
    this.selected = const CourierInboxTabItemStyle(),
    this.unselected = const CourierInboxTabItemStyle(),
  });
}

class CourierInboxTabItemStyle {
  final TextStyle? font;
  final CourierInboxTabIndicatorStyle indicator;

  const CourierInboxTabItemStyle({
    this.font,
    this.indicator = const CourierInboxTabIndicatorStyle(),
  });
}

class CourierInboxTabIndicatorStyle {
  final TextStyle? font;
  final Color? color;

  const CourierInboxTabIndicatorStyle({
    this.font,
    this.color,
  });
}

class CourierInboxReadingSwipeActionStyle {
  final CourierInboxSwipeActionStyle read;
  final CourierInboxSwipeActionStyle unread;

  const CourierInboxReadingSwipeActionStyle({
    this.read = const CourierInboxSwipeActionStyle(
      icon: null,
      color: null,
    ),
    this.unread = const CourierInboxSwipeActionStyle(
      icon: null,
      color: null,
    ),
  });
}

class CourierInboxArchivingSwipeActionStyle {
  final CourierInboxSwipeActionStyle archive;

  const CourierInboxArchivingSwipeActionStyle({
    this.archive = const CourierInboxSwipeActionStyle(
      icon: null,
      color: null,
    ),
  });
}

class CourierInboxSwipeActionStyle {
  final IconData? icon;
  final Color? color;

  const CourierInboxSwipeActionStyle({
    required this.icon,
    required this.color,
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

class CourierCellStyle {
  final DividerThemeData? separatorStyle;
  final EdgeInsetsGeometry? separatorInsets;
  final Color? separatorColor;
  final BoxDecoration? selectionStyle;

  const CourierCellStyle({
    this.separatorStyle,
    this.separatorInsets,
    this.separatorColor,
    this.selectionStyle,
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
