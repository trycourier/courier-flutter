import 'package:courier_flutter/models/inbox_action.dart';
import 'package:courier_flutter/models/inbox_message.dart';
import 'package:courier_flutter/ui/courier_theme.dart';
import 'package:courier_flutter/ui/inbox/courier_inbox_theme.dart';
import 'package:courier_flutter/utils.dart';
import 'package:flutter/material.dart';

class CourierInboxListItem extends StatefulWidget {
  final CourierInboxTheme theme;
  final InboxMessage message;
  final Function(InboxMessage) onMessageClick;
  final Function(InboxAction) onActionClick;

  const CourierInboxListItem({
    super.key,
    required this.theme,
    required this.message,
    required this.onMessageClick,
    required this.onActionClick,
  });

  @override
  CourierInboxListItemState createState() => CourierInboxListItemState();
}

class CourierInboxListItemState extends State<CourierInboxListItem> {
  InboxMessage get _message => widget.message;

  bool get _showDotIndicator => widget.theme.unreadIndicatorStyle.indicator == CourierInboxUnreadIndicator.dot;

  List<Widget> _buildContent(BuildContext context) {
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
                              color: _message.isRead ? Colors.transparent : widget.theme.getUnreadIndicatorColor(context),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  Text(
                    style: widget.theme.getTitleStyle(context, _message.isRead),
                    _message.title ?? "Missing",
                  ),
                ],
              ),
            ),
            const SizedBox(width: CourierTheme.margin),
            Text(
              _message.time,
              style: widget.theme.getTimeStyle(context, _message.isRead),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      );
    }

    if (_message.subtitle != null) {
      items.add(
        Text(
          style: widget.theme.getBodyStyle(context, _message.isRead),
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
                style: widget.theme.getButtonStyle(context, _message.isRead),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onMessageClick(_message),
        child: Stack(
          children: [
            !_showDotIndicator ? Positioned(left: 2, top: 2, bottom: 2, width: 3.0, child: Container(color: _message.isRead ? Colors.transparent : widget.theme.getUnreadIndicatorColor(context))) : const SizedBox(),
            Padding(
              padding: EdgeInsets.only(left: !_showDotIndicator ? CourierTheme.margin : CourierTheme.margin * 1.5, right: CourierTheme.margin, top: CourierTheme.margin * 0.75, bottom: CourierTheme.margin * 0.75),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildContent(context).addSeparator(() {
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
  }
}
