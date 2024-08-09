import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/courier_flutter_v2.dart';
import 'package:courier_flutter/models/inbox_message.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter_sample/env.dart';
import 'package:courier_flutter_sample/pages/inbox_custom.dart';
import 'package:courier_flutter_sample/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxState();
}

class _InboxState extends State<InboxPage> with SingleTickerProviderStateMixin {
  final ScrollController _customScrollController = ScrollController();
  TabController? _tabController;

  final customTheme = CourierInboxTheme(
    brandId: Env.brandId,
    unreadIndicatorStyle: const CourierInboxUnreadIndicatorStyle(
      indicator: CourierInboxUnreadIndicator.dot,
      color: AppTheme.primaryColor,
    ),
    titleStyle: CourierInboxTextStyle(
      read: AppTheme.titleText,
      unread: AppTheme.unreadTitleText,
    ),
    timeStyle: CourierInboxTextStyle(
      read: AppTheme.bodyText,
      unread: AppTheme.unreadBodyText,
    ),
    bodyStyle: CourierInboxTextStyle(
      read: AppTheme.bodyText,
      unread: AppTheme.unreadBodyText,
    ),
    buttonStyle: CourierInboxButtonStyle(
      read: AppTheme.buttonStyle,
      unread: AppTheme.unreadButtonStyle,
    ),
    separator: null,
  );

  late final Map<String, Widget> pages = {
    'Default': CourierInbox(
      keepAlive: true,
      onMessageClick: (message, index) {
        message.isRead ? message.markAsUnread() : message.markAsRead();
      },
      onActionClick: (action, message, index) {
        print(action);
      },
    ),
    'Styled': CourierInbox(
      keepAlive: true,
      lightTheme: customTheme,
      darkTheme: customTheme,
      scrollController: _customScrollController,
      onMessageClick: (message, index) {
        message.isRead ? message.markAsUnread() : message.markAsRead();
      },
      onActionClick: (action, message, index) {
        print(action);
        _customScrollController.jumpTo(0);
      },
    ),
    'Custom': const CustomInboxPage(),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: pages.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _customScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
        actions: [
          IconButton(
            tooltip: 'Read All Messages',
            icon: const Icon(Icons.mark_email_read), // Example icon for the button
            onPressed: () => CourierRC.shared.readAllInboxMessages(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: pages.keys.map((String title) => Tab(text: title)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: pages.values.toList(),
      ),
    );
  }
}
