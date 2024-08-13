import 'dart:convert';

import 'package:courier_flutter/channels/courier_flutter_channels.dart';
import 'package:courier_flutter/client/brand_client.dart';
import 'package:courier_flutter/client/inbox_client.dart';
import 'package:courier_flutter/client/preference_client.dart';
import 'package:courier_flutter/client/token_client.dart';
import 'package:courier_flutter/client/tracking_client.dart';
import 'package:courier_flutter/models/inbox_message.dart';
import 'package:flutter/foundation.dart';

class CourierClientOptions {
  final String? jwt;
  final String? clientKey;
  final String userId;
  final String? connectionId;
  final String? tenantId;
  final bool showLogs;

  CourierClientOptions({
    this.jwt,
    this.clientKey,
    required this.userId,
    this.connectionId,
    this.tenantId,
    required this.showLogs,
  });

  Map<String, dynamic> toJson() {
    return {
      'jwt': jwt,
      'clientKey': clientKey,
      'userId': userId,
      'connectionId': connectionId,
      'tenantId': tenantId,
      'showLogs': showLogs,
    };
  }

  Future<dynamic> invokeClient(String method, [dynamic arguments]) {
    final Map<String, dynamic> invokingArguments = {
      'options': toJson(),
      if (arguments is Map<String, dynamic>) ...arguments,
    };
    return CourierFlutterChannels.client.invokeMethod(method, invokingArguments);
  }
}

class CourierClient {
  final CourierClientOptions options;

  late final TokenClient tokens = TokenClient(options);
  late final BrandClient brands = BrandClient(options);
  late final InboxClient inbox = InboxClient(options);
  late final PreferenceClient preferences = PreferenceClient(options);
  late final TrackingClient tracking = TrackingClient(options);

  CourierClient({
    String? jwt,
    String? clientKey,
    required String userId,
    String? connectionId,
    String? tenantId,
    bool? showLogs,
  }) : options = CourierClientOptions(
          jwt: jwt,
          clientKey: clientKey,
          userId: userId,
          connectionId: connectionId,
          tenantId: tenantId,
          showLogs: showLogs ?? kDebugMode,
        ) {
    _registerEvents();
  }

  _registerEvents() {
    CourierFlutterChannels.events.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'client.inbox.socket.received_message': {

          String socketId = call.arguments['socketId'];
          final message = call.arguments['message'];

          InboxSocket socket = inbox.socket;

          if (socketId == socket.id) {
            final Map<String, dynamic> map = json.decode(message);
            final inboxMessage = InboxMessage.fromJson(map);
            socket.receivedMessage?.call(inboxMessage);
          }

          break;

        }
        case 'client.inbox.socket.received_message_event': {

          String socketId = call.arguments['socketId'];
          final event = call.arguments['event'];

          InboxSocket socket = inbox.socket;

          if (socketId == socket.id) {
            final Map<String, dynamic> map = json.decode(event);
            // final inboxMessage = InboxMessage.fromJson(map);
            socket.receivedMessageEvent?.call(event); // TODO: Parse response and check getMessages
          }

          break;
        }
      }
    });
  }

}
