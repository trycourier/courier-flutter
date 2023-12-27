import 'package:flutter/material.dart';

class CourierInboxBuilder extends StatelessWidget {

  final Widget Function(BuildContext, BoxConstraints, bool) builder;

  const CourierInboxBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
      return builder(context, constraints, currentBrightness == Brightness.dark);
    });
  }
}
