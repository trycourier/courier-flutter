import 'package:courier_flutter/inbox/watermark.dart';
import 'package:courier_flutter/utils.dart';
import 'package:flutter/material.dart';

class CourierFooter extends StatelessWidget {

  final bool shouldShow;

  const CourierFooter({Key? key, required this.shouldShow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildFooter(context);
  }

  Widget _buildFooter(BuildContext context) {
    if (shouldShow) {
      return Material(
        elevation: 8,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          alignment: Alignment.center,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: TextButton(
              onPressed: () => _showSheet(context),
              child: const Watermark(),
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  launchCourierURL();
                },
                child: const Text('Go to Courier'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}