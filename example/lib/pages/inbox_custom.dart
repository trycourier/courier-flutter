import 'dart:convert';

import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:courier_flutter/models/inbox_message.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class CustomInboxPage extends StatefulWidget {
  const CustomInboxPage({super.key});

  @override
  State<CustomInboxPage> createState() => _CustomInboxPageState();
}

class _CustomInboxPageState extends State<CustomInboxPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
        if (mounted) {
          setState(() {
            _isLoading = true;
            _error = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = error;
          });
        }
      },
      onMessagesChanged: (messages, unreadMessageCount, totalMessageCount, canPaginate) {
        if (mounted) {
          setState(() {
            _messages = messages;
            _isLoading = false;
            _error = null;
          });
        }
      },
    );
  }

  Future<void> _refresh() async {
    await Courier.shared.refreshInbox();
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
          itemCount: _messages.length,
          itemBuilder: (BuildContext context, int index) {
            final message = _messages[index];

            return Container(
              color: message.isRead ? Colors.transparent : Colors.red,
              child: ListTile(
                onTap: () => _onMessageClick(message),
                subtitle: Text(
                  message.toJson(),
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
  String toJson() {
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
