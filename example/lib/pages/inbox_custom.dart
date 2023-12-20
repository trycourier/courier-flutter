import 'dart:convert';

import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class CustomInboxPage extends StatefulWidget {
  const CustomInboxPage({super.key});

  @override
  State<CustomInboxPage> createState() => _CustomInboxPageState();
}

class _CustomInboxPageState extends State<CustomInboxPage> {
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

  Future<void> _onMessageClick(InboxMessage message) async {
    message.isRead ? await message.markAsUnread() : await message.markAsRead();
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
          separatorBuilder: (context, index) => const Divider(),
          itemCount: _messages.length,
          itemBuilder: (BuildContext context, int index) {
            final message = _messages[index];

            return Container(
              color: message.isRead ? Colors.transparent : Colors.red,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _onMessageClick(message);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      jsonEncode({
                        'messageId': message.messageId,
                        'title': message.title,
                        'body': message.body,
                        'data': message.data,
                        'actions': message.actions?.map((action) => {
                          'title': action.content,
                          'data': action.data,
                        }).toList() ?? [],
                      }),
                      style: GoogleFonts.robotoMono(fontSize: 16.0),
                    ),
                  ),
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
    return _buildContent();
  }
}
