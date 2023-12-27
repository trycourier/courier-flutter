import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/inbox/courier_inbox_builder.dart';
import 'package:courier_flutter/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:flutter/material.dart';

import 'courier_inbox_list_item.dart';

class CourierInbox extends StatefulWidget {
  final CourierInboxTheme _lightTheme;
  final CourierInboxTheme _darkTheme;
  final Function(InboxMessage, int)? onMessageClick;
  final Function(InboxAction, InboxMessage, int)? onActionClick;
  final ScrollController? scrollController;

  CourierInbox({
    super.key,
    CourierInboxTheme? lightTheme,
    CourierInboxTheme? darkTheme,
    this.scrollController,
    this.onMessageClick,
    this.onActionClick,
  })  : _lightTheme = lightTheme ?? CourierInboxTheme(),
        _darkTheme = darkTheme ?? CourierInboxTheme();

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

  CourierInboxTheme getTheme(bool isDarkMode) {
    return isDarkMode ? widget._darkTheme : widget._lightTheme;
  }

  Widget _buildContent(BuildContext context, bool isDarkMode) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: getTheme(isDarkMode).getLoadingColor(context),
        ),
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
      color: getTheme(isDarkMode).getLoadingColor(context),
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
                theme: getTheme(isDarkMode),
                message: message,
                onMessageClick: (message) => widget.onMessageClick != null ? widget.onMessageClick!(message, index) : null,
                onActionClick: (action) => widget.onActionClick != null ? widget.onActionClick!(action, message, index) : null,
              );
            } else {
              return Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(top: 24, bottom: _triggerPoint),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(getTheme(isDarkMode).getLoadingColor(context)),
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
    return CourierInboxBuilder(builder: (context, constraints, isDarkMode) {
      _triggerPoint = constraints.maxHeight / 2;
      return _buildContent(context, isDarkMode);
    });
  }

  @override
  void dispose() {
    // Remove the listeners
    _inboxListener?.remove();
    _scrollController.removeListener(_scrollListener);

    // Dispose the default controller
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }

    super.dispose();
  }
}
