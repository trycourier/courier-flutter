import 'package:courier_flutter/courier_flutter.dart';

class CourierPushListener {

  String listenerId;
  Function(dynamic message)? onPushDelivered;
  Function(dynamic message)? onPushClicked;

  CourierPushListener({ required this.listenerId, this.onPushDelivered, this.onPushClicked });

  void remove() => Courier.shared.removePushListener(listenerId: listenerId);

}