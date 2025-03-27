import 'dart:convert';

import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/inbox_feed.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class CustomInboxPage extends StatefulWidget {
  const CustomInboxPage({super.key});

  @override
  State<CustomInboxPage> createState() => _CustomInboxPageState();
}

class _CustomInboxPageState extends State<CustomInboxPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  CourierInboxListener? _inboxListener;

  bool _isLoading = true;
  String? _error;
  List<InboxMessage> _messages = [];
  bool _canLoadMore = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void didMount() {
    _start();
  }

  Future _start() async {

    if (!mounted) {
      return;
    }

    _inboxListener = await Courier.shared.addInboxListener(
      onLoading: (isRefresh) {
        setState(() {
          if (!isRefresh) _isLoading = true;
          _error = null;
        });
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
          _error = error;
        });
      },
      onUnreadCountChanged: (unreadCount) {
        print('unreadCount: $unreadCount');
      },
      onTotalCountChanged: (feed, totalCount) {
        print('totalCount: $totalCount');
      },
      onMessagesChanged: (messages, canPaginate, feed) {
        if (feed == InboxFeed.feed) {
          setState(() {
            _messages = messages;
            _isLoading = false;
            _error = null;
            _canLoadMore = canPaginate;
          });
        }
      },
      onPageAdded: (messages, canPaginate, isFirstPage, feed) {
        if (feed == InboxFeed.feed && !isFirstPage) {
          setState(() {
            _messages = messages;
            _isLoading = false;
            _error = null;
            _canLoadMore = canPaginate;
          });
        }
      },
      onMessageEvent: (message, index, feed, event) {
        switch (event) {
          case InboxMessageEvent.added:
            setState(() {
              _messages.insert(index, message);
            });
            break;
          case InboxMessageEvent.read:
            setState(() {
              _messages[index] = message;
            });
            break;
          case InboxMessageEvent.unread:
            setState(() {
              _messages[index] = message;
            });
            break;
          case InboxMessageEvent.opened:
            setState(() {
              _messages[index] = message;
            });
            break;
          case InboxMessageEvent.archived:
            setState(() {
              _messages.removeAt(index);
            });
            break;
          case InboxMessageEvent.clicked:
            setState(() {
              _messages[index] = message;
            });
            break;
        }
      },
    );
  }

  Future<void> _refresh() async {
    await Courier.shared.refreshInbox();
  }

  Future<void> _loadMore() async {
    await Courier.shared.fetchNextInboxPage(feed: InboxFeed.feed);
  }

  Future<void> _onMessageClick(InboxMessage message) async {
    message.isRead ? await message.markAsUnread() : await message.markAsRead();
  }

  void _removeInboxListener() {
    if (_inboxListener != null) {
      _inboxListener!.remove().then((_) {
        _inboxListener = null;
      }).catchError((error) {
        Courier.log('Failed to remove inbox listener: $error');
      });
    }
  }

  @override
  void dispose() async {
    _removeInboxListener();
    super.dispose();
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'No message found',
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scrollbar(
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: _messages.length + (_canLoadMore ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (_canLoadMore && index == _messages.length) {
              _loadMore();
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final message = _messages[index];

            return Container(
              color: message.isRead ? Colors.transparent : Colors.red,
              child: ListTile(
                onTap: () => _onMessageClick(message),
                subtitle: Text(
                  message.toDisplayString(),
                  style: GoogleFonts.robotoMono(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _buildContent();
  }

}

extension InboxExtension on InboxMessage {
  String toDisplayString() {
    var jsonObject = {
      'messageId': messageId,
      'title': title,
      'body': body,
      'data': data,
      'created': created,
      'archived': archived,
      'actions': actions
              ?.map((action) => {
                    'title': action.content,
                    'data': action.data,
                  })
              .toList() ??
          [],
    };

    var encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(jsonObject);
  }
}
