import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CourierInboxPaginationItem extends StatefulWidget {
  final bool isPaginating;
  final bool canPaginate;
  final VoidCallback onPaginationTriggered;
  final double triggerPoint;
  final Color loadingColor;
  final Key visibilityKey;

  const CourierInboxPaginationItem({
    super.key,
    required this.isPaginating,
    required this.canPaginate,
    required this.onPaginationTriggered,
    required this.triggerPoint,
    required this.loadingColor,
    required this.visibilityKey,
  });

  @override
  State<CourierInboxPaginationItem> createState() => _CourierInboxPaginationItemState();
}

class _CourierInboxPaginationItemState extends State<CourierInboxPaginationItem> {
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.visibilityKey,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0 && !widget.isPaginating && widget.canPaginate) {
          widget.onPaginationTriggered();
        }
      },
      child: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(top: 24, bottom: widget.triggerPoint),
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(widget.loadingColor),
            ),
          ),
        ),
      ),
    );
  }
}
