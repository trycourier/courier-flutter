import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FullInboxPage extends StatefulWidget {
  const FullInboxPage({super.key});

  @override
  State<FullInboxPage> createState() => _FullInboxPageState();
}

class _FullInboxPageState extends State<FullInboxPage> {

  final theme = CourierInboxTheme(
    unreadIndicatorStyle: const CourierInboxUnreadIndicatorStyle(
      indicator: CourierInboxUnreadIndicator.dot,
      color: Color(0xFF9747FF),
    ),
    loadingIndicatorColor: Color(0xFF9747FF),
    tabIndicatorColor: Color(0xFF9747FF),
    tabStyle: CourierInboxTabStyle(
      selected: CourierInboxTabItemStyle(
        font: GoogleFonts.sen().copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF9747FF),
        ),
        indicator: CourierInboxTabIndicatorStyle(
          color: Color(0xFF9747FF),
          font: GoogleFonts.sen().copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      unselected: CourierInboxTabItemStyle(
        font: GoogleFonts.sen().copyWith(
          fontWeight: FontWeight.normal,
          fontSize: 18,
          color: Colors.black45,
        ),
        indicator: CourierInboxTabIndicatorStyle(
          color: Colors.black45,
          font: GoogleFonts.sen().copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    ),
    readingSwipeActionStyle: CourierInboxReadingSwipeActionStyle(
      read: const CourierInboxSwipeActionStyle(
        icon: Icons.drafts,
        color: Color(0xFF9747FF),
      ),
      unread: CourierInboxSwipeActionStyle(
        icon: Icons.mark_email_read,
        color: Color(0xFF9747FF).withOpacity(0.5),
      ),
    ),
    archivingSwipeActionStyle: const CourierInboxArchivingSwipeActionStyle(
      archive: CourierInboxSwipeActionStyle(
        icon: Icons.inbox,
        color: Colors.red,
      ),
    ),
    titleStyle: CourierInboxTextStyle(
      read: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 18,
      ),
      unread: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    timeStyle: CourierInboxTextStyle(
      read: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      unread: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    bodyStyle: CourierInboxTextStyle(
      read: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
      unread: GoogleFonts.sen().copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    buttonStyle: CourierInboxButtonStyle(
      read: FilledButton.styleFrom(
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.sen().copyWith(
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
      ),
      unread: FilledButton.styleFrom(
        backgroundColor: Color(0xFF9747FF),
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.sen().copyWith(
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
      ),
    ),
    separator: null,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CourierInbox(
          canSwipePages: true,
          lightTheme: theme,
          darkTheme: theme,
          onMessageClick: (message, index) {
            message.isRead ? message.markAsUnread() : message.markAsRead();
          },
          onActionClick: (action, message, index) {
            print(action);
          },
        ),
      ),
    );
  }
}
