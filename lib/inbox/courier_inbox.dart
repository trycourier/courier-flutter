import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:flutter/material.dart';

import 'courier_inbox_list_item.dart';

class CourierInbox extends StatefulWidget {

  final Function(InboxMessage, int)? onMessageClick;
  final Function(InboxAction, InboxMessage, int)? onActionClick;
  final ScrollController? scrollController;

  const CourierInbox({
    super.key,
    this.scrollController,
    this.onMessageClick,
    this.onActionClick,
  });

  @override
  CourierInboxState createState() => CourierInboxState();
}

class CourierInboxState extends State<CourierInbox> {

  late final ScrollController _scrollController = widget.scrollController ?? ScrollController();
  CourierInboxListener? _inboxListener;

  bool _isLoading = true;
  String? _error;
  List<InboxMessage> _messages = [];
  bool _canPaginate = false;

  double _triggerPoint = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _scrollListener() {

    // Trigger the pagination
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent - _triggerPoint) {
      Courier.shared.fetchNextPageOfMessages();
    }

  }

  Future _start() async {

    // Attach scroll listener
    _scrollController.addListener(_scrollListener);

    // Attach inbox message listener
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
          _canPaginate = canPaginate;
        });
      },
    );
  }

  Future<void> _refresh() async {
    await Courier.shared.refreshInbox();
  }

  int get _itemCount => _messages.length + (_canPaginate ? 1 : 0);

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
        controller: _scrollController,
        child: ListView.separated(
          controller: _scrollController,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemCount: _itemCount,
          itemBuilder: (BuildContext context, int index) {

            if (index <= _messages.length - 1) {
              final message = _messages[index];
              return CourierInboxListItem(
                message: message,
                onMessageClick: (message) => widget.onMessageClick != null ? widget.onMessageClick!(message, index) : null,
                onActionClick: (action) => widget.onActionClick != null ? widget.onActionClick!(action, message, index) : null,
              );
            } else {
              return Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3, // Adjust the stroke width if needed
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Set the color
                    ),
                  ),
                ),
              );
            }

          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      _triggerPoint = constraints.maxHeight * 0.75;
      return _buildContent();
    });
  }

  @override
  void dispose() {
    _inboxListener?.remove();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

}
