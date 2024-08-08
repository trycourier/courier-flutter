import 'package:courier_flutter/channels/shared_method_channel.dart';

class CourierAuthenticationListener {

  String listenerId;
  Function(String? userId) onUserStateChanged;

  CourierAuthenticationListener({ required this.listenerId, required this.onUserStateChanged });

  Future remove() async => await CourierRC.shared.removeAuthenticationListener(id: listenerId);

}