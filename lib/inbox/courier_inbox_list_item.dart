import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/models/inbox_message.dart';
import 'package:flutter/material.dart';

extension WidgetListExtensions on List<Widget> {
  List<Widget> addSeparator(Widget Function() separatorBuilder) {
    if (isEmpty) {
      return this;
    }

    List<Widget> resultList = [];
    for (int i = 0; i < length; i++) {
      resultList.add(this[i]);
      if (i != length - 1) {
        Widget separator = separatorBuilder();
        resultList.add(separator);
      }
    }
    return resultList;
  }
}

class CourierInboxListItem extends StatefulWidget {
  final InboxMessage message;
  final Function(InboxMessage) onMessageClick;
  final Function(InboxAction) onActionClick;

  const CourierInboxListItem({
    super.key,
    required this.message,
    required this.onMessageClick,
    required this.onActionClick,
  });

  @override
  CourierInboxListItemState createState() => CourierInboxListItemState();
}

class CourierInboxListItemState extends State<CourierInboxListItem> {
  InboxMessage get _message => widget.message;

  List<Widget> _buildContent() {
    List<Widget> items = [];

    if (_message.title != null) {
      items.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Container(
          //   width: 10,
          //   height: 10,
          //   color: Colors.purple,
          // ),
          Expanded(
            child: Text(_message.title ?? "Missing"),
          ),
          const SizedBox(width: 16.0),
          Text(
            _message.time,
            textAlign: TextAlign.right,
          ),
        ],
      ));
    }

    if (_message.subtitle != null) {
      items.add(Text(_message.subtitle!));
    }

    items.add(Row(
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: (_message.actions ?? []).map((action) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () => widget.onActionClick(action),
              child: Text(action.content ?? ''),
            );
          }).toList(),
        ),
      ],
    ));

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
            Positioned(
              left: 2,
              top: 2,
              bottom: 2,
              width: 3.0,
              child: Container(color: _message.isRead ? Colors.transparent : Colors.blue),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildContent().addSeparator(() {
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
