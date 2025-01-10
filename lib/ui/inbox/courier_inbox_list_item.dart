import 'package:courier_flutter/models/inbox_action.dart';
import 'package:courier_flutter/models/inbox_message.dart';
import 'package:courier_flutter/ui/courier_theme.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter/ui/inbox/swipable_container.dart';
import 'package:courier_flutter/utils.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CourierInboxListItem extends StatefulWidget {
  final CourierInboxTheme theme;
  final InboxMessage message;
  final bool canPerformGestures;
  final Function() onMessageIsVisible;
  final Function(InboxMessage) onMessageClick;
  final Function(InboxMessage)? onMessageLongPress;
  final Function(InboxAction) onActionClick;
  final Function(InboxMessage) onReadGesture;
  final Function(InboxMessage) onArchiveGesture;

  const CourierInboxListItem({
    super.key,
    required this.theme,
    required this.message,
    required this.onMessageClick,
    required this.onMessageLongPress,
    required this.onActionClick,
    required this.canPerformGestures,
    required this.onMessageIsVisible,
    required this.onReadGesture,
    required this.onArchiveGesture,
  });

  @override
  CourierInboxListItemState createState() => CourierInboxListItemState();
}

class CourierInboxListItemState extends State<CourierInboxListItem> with TickerProviderStateMixin {
  late InboxMessage _message;
  bool get _showDotIndicator => widget.theme.unreadIndicatorStyle.indicator == CourierInboxUnreadIndicator.dot;

  late final AnimationController _indicatorController;
  late final Animation<double> _indicatorAnimation;
  late final AnimationController _enterController;
  late final Animation<double> _enterSizeAnimation;
  late final Animation<double> _enterSlideAnimation;
  late final AnimationController _exitController; 
  late final Animation<double> _exitSizeAnimation;
  final GlobalKey<SwipableContainerState> _swipableContainerKey = GlobalKey<SwipableContainerState>();

  static const _exitDuration = Duration(milliseconds: 200);
  static const _enterDuration = Duration(milliseconds: 400);
  static const _indicatorDuration = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _message = widget.message;
    
    // Initialize indicator animation
    _indicatorController = AnimationController(
      vsync: this,
      duration: _indicatorDuration,
      value: 1.0,
    );
    _indicatorAnimation = CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeInOut,
    );

    // Initialize enter animation
    _enterController = AnimationController(
      vsync: this, 
      duration: _enterDuration,
      value: 1.0,
    );
    
    // First half of animation - size change
    _enterSizeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Second half of animation - slide in
    _enterSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    // Initialize exit animation
    _exitController = AnimationController(
      vsync: this,
      duration: _exitDuration,
    );
    
    // Exit animation - size change (opposite of enter animation)
    _exitSizeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeIn,
    ));
    
  }

  @override 
  void dispose() {
    _indicatorController.dispose();
    _enterController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> refresh(InboxMessage newMessage) async {
    setState(() {
      _message = newMessage;
    });
  }

  Future<void> enter() async {
    _enterController.value = 0.0;
    return _enterController.forward();
  }

  Future<void> dismiss() async {
    _exitController.value = 0.0;
    return _exitController.forward();
  }

  Future<void> exit() async {
    await Future.wait([
      _swipableContainerKey.currentState?.simulateRightToLeftSwipe() ?? Future.value(),
      dismiss()
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
    return AnimatedBuilder(
      animation: Listenable.merge([_enterSizeAnimation, _enterSlideAnimation, _exitSizeAnimation]),
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _exitSizeAnimation,
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
                  key: _swipableContainerKey,
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
