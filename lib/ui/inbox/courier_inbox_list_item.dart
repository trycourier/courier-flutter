import 'package:courier_flutter/models/inbox_action.dart';
import 'package:courier_flutter/models/inbox_message.dart';
import 'package:courier_flutter/ui/courier_theme.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CourierInboxListItem extends StatefulWidget {
  final CourierInboxTheme theme;
  final InboxMessage message;
  final bool canPerformGestures;
  final Function(InboxMessage) onMessageClick;
  final Function(InboxMessage)? onMessageLongPress;
  final Function(InboxAction) onActionClick;
  final Function(InboxMessage) onSwipeArchiveTrigger;
  final Function(InboxMessage) onSwipeArchiveComplete;
  final Function(InboxMessage) onArchiveButtonTrigger;

  const CourierInboxListItem({
    super.key,
    required this.theme,
    required this.message,
    required this.onMessageClick,
    required this.onMessageLongPress,
    required this.onActionClick,
    required this.canPerformGestures,
    required this.onArchiveButtonTrigger,
    required this.onSwipeArchiveTrigger,
    required this.onSwipeArchiveComplete,
  });

  @override
  CourierInboxListItemState createState() => CourierInboxListItemState();
}

class CourierInboxListItemState extends State<CourierInboxListItem> with TickerProviderStateMixin {
  late InboxMessage _message;
  bool get _showDotIndicator => widget.theme.unreadIndicatorStyle.indicator == CourierInboxUnreadIndicator.dot;

  late final SlidableController _slideController;
  final _dismissDuration = const Duration(milliseconds: 200);
  late final AnimationController _indicatorController;
  late final Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _message = widget.message;
    _slideController = SlidableController(this);
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      value: 1.0,
    );
    _indicatorAnimation = CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeInOut,
    );
  }

  @override 
  void dispose() {
    _slideController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  Future<void> refresh(InboxMessage newMessage) async {
    setState(() {
      _message = newMessage;
    });
  }

  Future<void> dismiss({ bool shouldOpen = false }) async {
    if (shouldOpen) {
      await _slideController.openTo(-1, duration: _dismissDuration);
    }

    await _slideController.dismiss(ResizeRequest(_dismissDuration, () {
      widget.onSwipeArchiveComplete(_message);
    }));
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
                          child: FadeTransition(
                            opacity: _indicatorAnimation,
                            child: Container(
                              width: CourierTheme.dotSize,
                              height: CourierTheme.dotSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: showUnreadStyle ? Colors.transparent : widget.theme.getUnreadIndicatorColor(context),
                              ),
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
    return Slidable(
      key: Key(_message.messageId),
      enabled: widget.canPerformGestures,
      controller: _slideController,
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onMessageClick(_message),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: isDone ? Icons.mark_email_read : Icons.mark_email_unread,
            label: isDone ? 'Mark Read' : 'Mark Unread',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          dismissalDuration: _dismissDuration,
          confirmDismiss: () async {
            HapticFeedback.mediumImpact();
            widget.onSwipeArchiveTrigger(_message);
            return true;
          },
          onDismissed: () {
            widget.onSwipeArchiveComplete(_message);
          },
        ),
        children: [
          SlidableAction(
            autoClose: false,
            onPressed: (_) async {
              HapticFeedback.mediumImpact();
              await _slideController.openTo(-1, duration: _dismissDuration);
              widget.onArchiveButtonTrigger(_message);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.archive,
            label: 'Archive',
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onMessageClick(_message),
          onLongPress: widget.onMessageLongPress != null ? () => widget.onMessageLongPress!(_message) : null,
          child: Stack(
            children: [
              !_showDotIndicator ? Positioned(
                left: 2,
                top: 2,
                bottom: 2,
                width: 3.0,
                child: FadeTransition(
                  opacity: _indicatorAnimation,
                  child: Container(
                    color: isDone ? Colors.transparent : widget.theme.getUnreadIndicatorColor(context)
                  ),
                ),
              ) : const SizedBox(),
              Padding(
                padding: EdgeInsets.only(
                  left: !_showDotIndicator ? CourierTheme.margin : CourierTheme.margin * 1.5,
                  right: CourierTheme.margin,
                  top: CourierTheme.margin * 0.75,
                  bottom: CourierTheme.margin * 0.75
                ),
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
      ),
    );
  }
}

enum SlideDirection {
  fromLeft,
  fromRight,
  fade,
}
