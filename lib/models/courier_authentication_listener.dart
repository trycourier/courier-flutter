import 'package:courier_flutter/courier_flutter_v2.dart';

class CourierAuthenticationListener {

  String listenerId;
  Function(String? userId) onUserStateChanged;

  CourierAuthenticationListener({ required this.listenerId, required this.onUserStateChanged });

  Future remove() async => await CourierRC.shared.removeAuthenticationListener(listenerId: listenerId);

}