import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/inbox/courier_inbox.dart';
import 'package:courier_flutter/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter_sample/pages/inbox_custom.dart';
import 'package:flutter/material.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxState();
}

class _InboxState extends State<InboxPage> with SingleTickerProviderStateMixin {
  final ScrollController _customScrollController = ScrollController();
  TabController? _tabController;

  late final Map<String, Widget> pages = {
    'Default': CourierInbox(
      onMessageClick: (message, index) {
        message.isRead ? message.markAsUnread() : message.markAsRead();
      },
      onActionClick: (action, message, index) {
        print(action);
      },
    ),
    'Styled': CourierInbox(
      lightTheme: CourierInboxTheme(
        loadingIndicatorColor: Colors.black,
        unreadIndicatorStyle: CourierInboxUnreadIndicatorStyle(
          indicator: CourierInboxUnreadIndicator.dot,
          color: Colors.red,
        ),
        titleStyle: CourierInboxTextStyle(
          read: TextStyle(color: Colors.blue, fontSize: 20),
          unread: TextStyle(color: Colors.red, fontSize: 20),
        ),
        timeStyle: CourierInboxTextStyle(
          read: TextStyle(color: Colors.blue, fontSize: 16),
          unread: TextStyle(color: Colors.red, fontSize: 16),
        ),
        bodyStyle: CourierInboxTextStyle(
          read: TextStyle(color: Colors.blue, fontSize: 16),
          unread: TextStyle(color: Colors.red, fontSize: 16),
        ),
        buttonStyle: CourierInboxButtonStyle(
          read: FilledButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          unread: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          )
        ),
        separator: null,
      ),
      darkTheme: CourierInboxTheme(
        loadingIndicatorColor: Colors.red,
        bodyStyle: CourierInboxTextStyle(
          read: TextStyle(color: Colors.red),
          unread: TextStyle(color: Colors.green),
        ),
        buttonStyle: CourierInboxButtonStyle(
          read: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          unread: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ),
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
    _tabController = TabController(length: 3, vsync: this);
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
            onPressed: () => Courier.shared.readAllInboxMessages(),
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
