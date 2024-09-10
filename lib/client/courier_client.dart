import 'package:courier_flutter/courier_flutter_channels.dart';
import 'package:courier_flutter/client/brand_client.dart';
import 'package:courier_flutter/client/inbox_client.dart';
import 'package:courier_flutter/client/preference_client.dart';
import 'package:courier_flutter/client/token_client.dart';
import 'package:courier_flutter/client/tracking_client.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class CourierClientOptions {
  final String id;
  final String? jwt;
  final String? clientKey;
  final String userId;
  final String? connectionId;
  final String? tenantId;
  final bool showLogs;

  CourierClientOptions({
    required this.id,
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

  Future<dynamic> invokeClient(String method, [dynamic arguments]) async {

    final result = await Future.wait([
      add(),
      PackageInfo.fromPlatform(),
    ]);

    final clientId = result[0] as String;
    final packageInfo = result[1] as PackageInfo;

    final invokingArguments = {
      'clientId': clientId,
      'version': packageInfo.version,
      if (arguments is Map<String, dynamic>) ...arguments,
    };

    return CourierFlutterChannels.client.invokeMethod(method, invokingArguments);
    
  }

  Future<String> add() async {
    return await CourierFlutterChannels.client.invokeMethod('client.add', {
      'clientId': id,
      'options': toJson(),
    });
  }

  Future<String> remove() async {
    return await CourierFlutterChannels.client.invokeMethod('client.remove', {
      'clientId': id,
    });
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
    id: const Uuid().v4(),
    jwt: jwt,
    clientKey: clientKey,
    userId: userId,
    connectionId: connectionId,
    tenantId: tenantId,
    showLogs: showLogs ?? kDebugMode,
  );

  Future add() async {
    return options.add();
  }

  Future<String> remove() async {
    return await options.remove();
  }

}
