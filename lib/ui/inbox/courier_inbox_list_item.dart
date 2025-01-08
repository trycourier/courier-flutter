import 'package:courier_flutter/models/inbox_action.dart';
import 'package:courier_flutter/models/inbox_message.dart';
import 'package:courier_flutter/ui/courier_theme.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CourierInboxListItem extends StatefulWidget {
  final CourierInboxTheme theme;
  final InboxMessage message;
  final Function(InboxMessage) onMessageClick;
  final Function(InboxMessage)? onMessageLongPress;
  final Function(InboxAction) onActionClick;
  final Function(InboxMessage) onArchive;
  final bool canPerformGestures;

  const CourierInboxListItem({
    super.key,
    required this.theme,
    required this.message,
    required this.onMessageClick,
    required this.onMessageLongPress,
    required this.onActionClick,
    required this.canPerformGestures,
    required this.onArchive,
  });

  @override
  CourierInboxListItemState createState() => CourierInboxListItemState();
}

class CourierInboxListItemState extends State<CourierInboxListItem> with SingleTickerProviderStateMixin {
  InboxMessage get _message => widget.message;
  bool get _showDotIndicator => widget.theme.unreadIndicatorStyle.indicator == CourierInboxUnreadIndicator.dot;

  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> dismiss() async {
    await _animationController.forward();
  }

  Future<void> animateIn({SlideDirection direction = SlideDirection.fromRight}) async {
    Offset beginOffset;
    switch (direction) {
      case SlideDirection.fromLeft:
        beginOffset = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.fromRight:
        beginOffset = const Offset(1.0, 0.0);
        break;
      case SlideDirection.fade:
        beginOffset = const Offset(0.0, 0.0);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.reset();
    await _animationController.forward();
  }

  List<Widget> _buildContent(BuildContext context, bool showUnreadStyle) {
    List<Widget> items = [];
    if (_message.title != null) {
      items.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  _showDotIndicator
                      ? Positioned(
                          left: -(CourierTheme.dotSize + CourierTheme.dotSize / 2),
                          child: Container(
                            width: CourierTheme.dotSize,
                            height: CourierTheme.dotSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: showUnreadStyle ? Colors.transparent : widget.theme.getUnreadIndicatorColor(context),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  Text(
                    style: widget.theme.getTitleStyle(context, showUnreadStyle),
                    _message.title ?? "Missing",
                  ),
                ],
              ),
            ),
            const SizedBox(width: CourierTheme.margin),
            Text(
              _message.time,
              style: widget.theme.getTimeStyle(context, showUnreadStyle),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      );
    }

    if (_message.subtitle != null) {
      items.add(
        Text(
          style: widget.theme.getBodyStyle(context, showUnreadStyle),
          _message.subtitle!,
        ),
      );
    }

    final actions = _message.actions ?? [];

    if (actions.isNotEmpty) {
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: CourierTheme.margin / 2),
          child: Wrap(
            spacing: CourierTheme.margin / 2,
            runSpacing: 0.0,
            children: actions.map((action) {
              return FilledButton(
                style: widget.theme.getButtonStyle(context, showUnreadStyle),
                onPressed: () => widget.onActionClick(action),
                child: Text(action.content ?? ''),
              );
            }).toList(),
          ),
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final isDone = _message.isRead || _message.isArchived;
    
    Widget content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onMessageClick(_message),
        onLongPress: widget.onMessageLongPress != null ? () => widget.onMessageLongPress!(_message) : null,
        child: Stack(
          children: [
            !_showDotIndicator ? Positioned(left: 2, top: 2, bottom: 2, width: 3.0, child: Container(color: isDone ? Colors.transparent : widget.theme.getUnreadIndicatorColor(context))) : const SizedBox(),
            Padding(
              padding: EdgeInsets.only(left: !_showDotIndicator ? CourierTheme.margin : CourierTheme.margin * 1.5, right: CourierTheme.margin, top: CourierTheme.margin * 0.75, bottom: CourierTheme.margin * 0.75),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildContent(context, isDone).addSeparator(() {
                        return const SizedBox(height: 2.0);
                      }),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );

    if (!widget.canPerformGestures) {
      return SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: content,
        ),
      );
    }

    bool didReach = false;

    return Dismissible(
      key: Key(_message.messageId),
      direction: DismissDirection.horizontal,
      onUpdate: (details) {
        if (details.reached && !didReach) {
          didReach = true;
          HapticFeedback.mediumImpact();
        } else if (!details.reached) {
          didReach = false;
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          widget.onArchive(_message);
        } else if (direction == DismissDirection.startToEnd) {
          widget.onMessageClick(_message);
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        color: Colors.blue,
        padding: const EdgeInsets.only(left: 16.0),
        child: Icon(
          isDone ? Icons.mark_email_read : Icons.mark_email_unread,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.archive,
          color: Colors.white,
        ),
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: content,
        ),
      ),
    );
  }
}

enum SlideDirection {
  fromLeft,
  fromRight,
  fade,
}
