import 'package:courier_flutter/channels/courier_flutter_channels.dart';
import 'package:courier_flutter/client/brand_client.dart';
import 'package:courier_flutter/client/inbox_client.dart';
import 'package:courier_flutter/client/preference_client.dart';
import 'package:courier_flutter/client/token_client.dart';
import 'package:courier_flutter/client/tracking_client.dart';
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
        );
}
