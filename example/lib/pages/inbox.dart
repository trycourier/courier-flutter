import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/inbox/courier_inbox.dart';
import 'package:courier_flutter_sample/pages/inbox_custom.dart';
import 'package:flutter/material.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxState();
}

class _InboxState extends State<InboxPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final Map<String, Widget> pages = {
    'Default': CourierInbox(
      onMessageClick: (message, index) {
        message.isRead ? message.markAsUnread() : message.markAsRead();
      },
      onActionClick: (action, message, index) {
        print(action);
      },
    ),
    'Styled': CourierInbox(
      onMessageClick: (message, index) {
        message.isRead ? message.markAsUnread() : message.markAsRead();
      },
      onActionClick: (action, message, index) {
        print(action);
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
