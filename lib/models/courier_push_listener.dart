import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter/utils.dart';

class CourierPushListener {

  String listenerId;
  Function(dynamic message)? onPushDelivered;
  Function(dynamic message)? onPushClicked;

  CourierPushListener({ required this.listenerId });

  factory CourierPushListener.fromListeners(Function(dynamic message)? onPushDelivered, Function(dynamic message)? onPushClicked) {
    final listener = CourierPushListener(
      listenerId: getUUID()
    );
    listener.onPushDelivered = onPushDelivered;
    listener.onPushClicked = onPushClicked;
    return listener;
  }

  // TODO
  // Future remove() => Courier.shared.removeInboxListener(id: listenerId);

}