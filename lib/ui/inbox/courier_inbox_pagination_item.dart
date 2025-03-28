import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CourierInboxPaginationItem extends StatelessWidget {
  final bool isPaginating;
  final bool canPaginate;
  final VoidCallback onPaginationTriggered;
  final double triggerPoint;
  final Color loadingColor;

  const CourierInboxPaginationItem({
    super.key,
    required this.isPaginating,
    required this.canPaginate,
    required this.onPaginationTriggered,
    required this.triggerPoint,
    required this.loadingColor,
  });
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('pagination'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0 && !isPaginating && canPaginate) {
          onPaginationTriggered();
        }
      },
      child: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(top: 24, bottom: triggerPoint),
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
            ),
          ),
        ),
      ),
    );
  }
}
