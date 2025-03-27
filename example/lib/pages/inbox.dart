import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter_sample/env.dart';
import 'package:courier_flutter_sample/pages/inbox_custom.dart';
import 'package:courier_flutter_sample/theme.dart';
import 'package:flutter/material.dart';
import 'package:courier_flutter_sample/pages/full_inbox_page.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxState();
}

class _InboxState extends State<InboxPage> with SingleTickerProviderStateMixin {
  final ScrollController _feedScrollController = ScrollController();
  final ScrollController _archivedScrollController = ScrollController();
  TabController? _tabController;

  final customTheme = CourierInboxTheme(
    unreadIndicatorStyle: const CourierInboxUnreadIndicatorStyle(
      indicator: CourierInboxUnreadIndicator.dot,
      color: AppTheme.primaryColor,
    ),
    loadingIndicatorColor: AppTheme.primaryColor,
    tabIndicatorColor: AppTheme.primaryColor,
    tabStyle: CourierInboxTabStyle(
      selected: CourierInboxTabItemStyle(
        font: AppTheme.unreadTitleText.copyWith(color: AppTheme.primaryColor),
        indicator: CourierInboxTabIndicatorStyle(
          color: AppTheme.primaryColor,
          font: AppTheme.bodyText.copyWith(color: Colors.white),
        ),
      ),
      unselected: CourierInboxTabItemStyle(
        font: AppTheme.titleText.copyWith(color: AppTheme.secondaryColor),
        indicator: CourierInboxTabIndicatorStyle(
          color: AppTheme.secondaryColor,
          font: AppTheme.bodyText.copyWith(color: Colors.white),
        ),
      ),
    ),
    readingSwipeActionStyle: CourierInboxReadingSwipeActionStyle(
      read: const CourierInboxSwipeActionStyle(
        icon: Icons.drafts,
        color: AppTheme.primaryColor,
      ),
      unread: CourierInboxSwipeActionStyle(
        icon: Icons.mark_email_read,
        color: AppTheme.primaryColor.withOpacity(0.5),
      ),
    ),
    archivingSwipeActionStyle: const CourierInboxArchivingSwipeActionStyle(
      archive: CourierInboxSwipeActionStyle(
        icon: Icons.inbox,
        color: Colors.red,
      ),
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
      onError: (error) {
        print(error);
      },
    ),
    'Branded': CourierInbox(
      keepAlive: true,
      lightTheme: CourierInboxTheme(
        brandId: Env.brandId,
      ),
      darkTheme: CourierInboxTheme(
        brandId: Env.brandId,
      ),
      onMessageClick: (message, index) {
        message.isRead ? message.markAsUnread() : message.markAsRead();
      },
      onError: (error) {
        print(error);
      },
    ),
    'Styled': CourierInbox(
      keepAlive: true,
      showCourierFooter: false,
      lightTheme: customTheme,
      darkTheme: customTheme,
      feedScrollController: _feedScrollController,
      archivedScrollController: _archivedScrollController,
      onMessageClick: (message, index) {
        message.isRead ? message.markAsUnread() : message.markAsRead();
      },
      onMessageLongPress: (message, index) {
        showModalBottomSheet(
          context: context,
          clipBehavior: Clip.hardEdge,
          builder: (BuildContext context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(message.isRead ? 'Mark as unread' : 'Mark as read'),
                      onTap: () {
                        message.isRead ? message.markAsUnread() : message.markAsRead();
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Archive'),
                      onTap: () {
                        message.markAsArchived();
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Scroll to top'),
                      onTap: () {
                        _feedScrollController.jumpTo(0);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Cancel'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      onActionClick: (action, message, index) {
        print(action);
      },
      onError: (error) {
        print(error);
      },
    ),
    'Custom': const CustomInboxPage(),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: pages.length, vsync: this);
    Future.delayed(const Duration(seconds: 10), () async {
      await Courier.shared.signOut();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _feedScrollController.dispose();
    _archivedScrollController.dispose();
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
            onPressed: () => Courier.shared.readAllInboxMessages(),
          ),
          IconButton(
            tooltip: 'Open Full Inbox',
            icon: const Icon(Icons.open_in_new), // Example icon for the button
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FullInboxPage()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: pages.keys.map((String title) => Tab(text: title)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages.values.toList(),
      ),
    );
  }
}
