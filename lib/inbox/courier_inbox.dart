import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:flutter/material.dart';

import 'courier_inbox_list_item.dart';

class CourierInbox extends StatefulWidget {
  final Function(InboxMessage, int)? onMessageClick;
  final Function(InboxAction, InboxMessage, int)? onActionClick;

  const CourierInbox({
    super.key,
    this.onMessageClick,
    this.onActionClick,
  });

  @override
  CourierInboxState createState() => CourierInboxState();
}

class CourierInboxState extends State<CourierInbox> {
  CourierInboxListener? _inboxListener;

  bool _isLoading = true;
  String? _error;
  List<InboxMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future _start() async {
    _inboxListener = await Courier.shared.addInboxListener(
      onInitialLoad: () {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _error = error;
        });
      },
      onMessagesChanged: (messages, unreadMessageCount, totalMessageCount, canPaginate) {
        setState(() {
          _messages = messages;
          _isLoading = false;
          _error = null;
        });
      },
    );
  }

  Future<void> _refresh() async {
    await Courier.shared.refreshInbox();
  }

  @override
  void dispose() {
    super.dispose();
    _inboxListener?.remove();
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(_error!),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text('No message found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scrollbar(
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemCount: _messages.length,
          itemBuilder: (BuildContext context, int index) {
            final message = _messages[index];
            return CourierInboxListItem(
              message: message,
              onMessageClick: (message) => widget.onMessageClick != null ? widget.onMessageClick!(message, index) : null,
              onActionClick: (action) => widget.onActionClick != null ? widget.onActionClick!(action, message, index) : null,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }
}
