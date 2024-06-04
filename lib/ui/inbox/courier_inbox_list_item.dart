import 'package:courier_flutter/courier_flutter.dart';
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
  final dotSize = 12.0;
  final margin = 16.0;

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
                          left: -(dotSize + dotSize / 2),
                          child: Container(
                            width: dotSize,
                            height: dotSize,
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
            SizedBox(width: margin),
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

    items.add(
      Wrap(
        spacing: margin / 2,
        runSpacing: 0.0,
        children: (_message.actions ?? []).map((action) {
          return FilledButton(
            style: widget.theme.getButtonStyle(context, _message.isRead),
            onPressed: () => widget.onActionClick(action),
            child: Text(action.content ?? ''),
          );
        }).toList(),
      ),
    );

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
              padding: EdgeInsets.only(left: !_showDotIndicator ? margin : margin * 1.5, right: 16.0, top: 12.0, bottom: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildContent(context).addSeparator(() {
                        return const SizedBox(height: 6.0);
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
