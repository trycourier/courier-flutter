import 'dart:async';

import 'package:courier_flutter/models/inbox_action.dart';
import 'package:courier_flutter/models/inbox_feed.dart';
import 'package:courier_flutter/models/inbox_message.dart';
import 'package:courier_flutter/ui/courier_theme.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter/ui/inbox/swipable_container.dart';
import 'package:courier_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CourierInboxListItem extends StatefulWidget {
  final CourierInboxTheme theme;
  final InboxFeed feed;
  final InboxMessage message;
  final int index;
  final bool canPerformGestures;
  final bool shouldAnimateOnLoad;
  final Function() onMessageIsVisible;
  final Function(InboxMessage) onMessageClick;
  final Function(InboxMessage)? onMessageLongPress;
  final Function(InboxAction) onActionClick;
  final Function(InboxMessage) onReadGesture;
  final Function(InboxMessage) onArchiveGesture;
  final Function(InboxMessage) onMessageAdded;

  const CourierInboxListItem({
    super.key,
    required this.theme,
    required this.feed,
    required this.message,
    required this.index,
    required this.shouldAnimateOnLoad,
    required this.onMessageClick,
    required this.onMessageLongPress,
    required this.onActionClick,
    required this.canPerformGestures,
    required this.onMessageIsVisible,
    required this.onReadGesture,
    required this.onArchiveGesture,
    required this.onMessageAdded,
  });

  @override
  CourierInboxListItemState createState() => CourierInboxListItemState();
}

class CourierInboxListItemState extends State<CourierInboxListItem> with TickerProviderStateMixin {
  late InboxMessage _message;

  // State
  SwipableContainerState? _swipableContainerState;

  // Animation durations
  static const _enterDuration = Duration(milliseconds: 400);
  static const _exitDuration = Duration(milliseconds: 200);

  // Enter animations
  late final AnimationController _enterController;
  late final Animation<double> _enterSizeAnimation;
  late final Animation<double> _enterSlideAnimation;

  // Exit animations
  late final AnimationController _exitController;
  late final Animation<double> _exitSizeAnimation;
  late final Animation<double> _exitFadeAnimation;

  // Computed properties
  bool get _showDotIndicator => widget.theme.unreadIndicatorStyle.indicator == CourierInboxUnreadIndicator.dot;

  @override
  void initState() {
    super.initState();

    // Set initial message
    _message = widget.message;

    // Initialize enter animation
    _enterController = AnimationController(
      vsync: this, 
      duration: _enterDuration,
      value: widget.shouldAnimateOnLoad ? 0.0 : 1.0,
    );

    // First half of animation - size change
    _enterSizeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    // Second half of animation - slide in
    _enterSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    ));

    // Initialize exit animation
    _exitController = AnimationController(
      vsync: this,
      duration: _exitDuration,
    );
    
    // Exit animations - size change and fade out
    _exitSizeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInOutCubic,
    ));

    _exitFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
    ));

    _animateOnLoad();
  }

  Future<void> _animateOnLoad() async {
    if (!mounted) return;
    if (widget.shouldAnimateOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _enterController.forward();
        if (mounted) {
          widget.onMessageAdded(widget.message);
        }
      });
    } else {
      widget.onMessageAdded(widget.message);
    }
  }

  @override 
  void dispose() {
    _exitController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  Future<void> refresh(InboxMessage newMessage) async {
    if (!mounted) return;
    setState(() {
      _message = newMessage;
    });
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> dismiss() async {
    if (!mounted) return;
    return _swipableContainerState?.animateRightToLeft();
  }

  Future<void> remove({Duration duration = _exitDuration}) async {
    if (!mounted) return;
    _exitController.duration = duration;
    _exitController.value = 0.0;
    return _exitController.forward();
  }

  Future<void> exit() async {
    await Future.wait([
      dismiss(),
      remove(),
    ]);
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
          widget.message.subtitle!,
        ),
      );
    }

    final actions = widget.message.actions ?? [];

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
    return AnimatedBuilder(
      animation: Listenable.merge([_enterSizeAnimation, _enterSlideAnimation, _exitSizeAnimation, _exitFadeAnimation]),
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _exitSizeAnimation,
          child: FadeTransition(
            opacity: false ? _exitFadeAnimation : const AlwaysStoppedAnimation(1.0), // TODO: Fix this later
            child: SizeTransition(
              sizeFactor: _enterSizeAnimation,
              axisAlignment: 1.0,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(1.0, 0.0),
                ).animate(_enterSlideAnimation),
                child: VisibilityDetector(
                  key: Key(_message.messageId),
                  onVisibilityChanged: (VisibilityInfo info) {
                    if (info.visibleFraction > 0 && !_message.isOpened) {
                      widget.onMessageIsVisible();
                    }
                  },
                  child: SwipableContainer(
                    onStateReady: (state) => _swipableContainerState = state,
                    canPerformGestures: widget.canPerformGestures,
                    isRead: isDone,
                    readIcon: Icons.mark_email_read,
                    unreadIcon: Icons.mark_email_unread,
                    readColor: Colors.blueGrey,
                    unreadColor: Colors.blue,
                    archiveIcon: Icons.archive,
                    archiveColor: Colors.red,
                    onLeftToRightAction: () => widget.onReadGesture(_message),
                    onRightToLeftAction: () => widget.onArchiveGesture(_message),
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => widget.onMessageClick(widget.message),
                          onLongPress: widget.onMessageLongPress != null ? () => widget.onMessageLongPress!(widget.message) : null,
                          child: Stack(
                            children: [
                              !_showDotIndicator ? Positioned(
                                left: 2,
                                top: 2,
                                bottom: 2,
                                width: 3.0,
                                child: Container(
                                  color: isDone ? Colors.transparent : widget.theme.getUnreadIndicatorColor(context)
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
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

}
