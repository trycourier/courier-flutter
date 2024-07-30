import 'dart:async';

import 'package:courier_flutter/channels/events_platform_interface.dart';
import 'package:courier_flutter/interfaces/client_interface.dart';
import 'package:courier_flutter/models/courier_inbox_listener.dart';

class CourierClient {

  final String apiKey;

  CourierClient({required this.apiKey});

  Future<String> getPlatformVersion() async {
    return await CourierClientInterface.instance.getPlatformVersion();
  }

}