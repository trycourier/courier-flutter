import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter_sample/env.dart';
import 'example_server.dart';

class ClientBuilder {
  static Future<CourierClient> build({
    bool useJWT = true,
    required String userId,
    String? connectionId,
    String? tenantId,
  }) async {
    String? jwt;

    if (useJWT) {
      jwt = await ExampleServer.generateJwt(
        Env.authKey,
        userId,
      );
    }

    return CourierClient(
      jwt: jwt,
      clientKey: Env.clientKey,
      userId: userId,
      connectionId: connectionId,
      tenantId: tenantId,
      showLogs: true,
    );
  }
}