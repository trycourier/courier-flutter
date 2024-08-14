import 'package:courier_flutter/courier_flutter.dart';

class CourierAuthenticationListener {

  String listenerId;
  Function(String? userId) onUserStateChanged;

  CourierAuthenticationListener({ required this.listenerId, required this.onUserStateChanged });

  Future remove() async => await Courier.shared.removeAuthenticationListener(listenerId: listenerId);

}