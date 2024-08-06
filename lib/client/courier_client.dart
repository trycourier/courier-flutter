import 'package:courier_flutter/client/brand_client.dart';
import 'package:courier_flutter/client/inbox_client.dart';
import 'package:courier_flutter/client/preference_client.dart';
import 'package:courier_flutter/client/token_client.dart';
import 'package:courier_flutter/client/tracking_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class TestClient extends PlatformInterface {

  final CourierClientOptions options;
  late final InboxClient inbox = InboxClient(options);
  final events = const MethodChannel('courier_flutter_client_events');

  TestClient({
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
  ), super(token: Object()) {

    events.setMethodCallHandler((call) {
      switch (call.method) {
        case 'client.events.inbox.socket.received_message':
          print("HERE");
      }
      return Future.value();
    });

  }

}

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

  final client = const MethodChannel('courier_flutter_client');
  final events = const MethodChannel('courier_flutter_client_events');

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
    return client.invokeMethod(method, invokingArguments);
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
        );
}
