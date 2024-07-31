import 'dart:convert';

import 'package:courier_flutter/models/courier_brand.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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

  @visibleForTesting
  final channel = const MethodChannel('courier_flutter_client');

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
}

class CourierClient {
  final CourierClientOptions options;

  late final TokenClient tokens = TokenClient(options: options);
  late final BrandClient brands = BrandClient(options);
  late final InboxClient inbox = InboxClient(options: options);
  late final PreferenceClient preferences = PreferenceClient(options: options);
  late final TrackingClient tracking = TrackingClient(options: options);

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

class TokenClient {
  TokenClient({required CourierClientOptions options});
}

class BrandClient {
  final CourierClientOptions _options;

  BrandClient(this._options);

  Future<CourierBrandResponse> getBrand({required String id}) async {
    final data = await _options.channel.invokeMethod('getBrand', {
      'options': _options.toJson(),
      'brandId': id,
    });
    final Map<String, dynamic> map = json.decode(data);
    return CourierBrandResponse.fromJson(map);
  }
}

class InboxClient {
  InboxClient({required CourierClientOptions options});
}

class PreferenceClient {
  PreferenceClient({required CourierClientOptions options});
}

class TrackingClient {
  TrackingClient({required CourierClientOptions options});
}
