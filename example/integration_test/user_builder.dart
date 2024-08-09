import 'package:courier_flutter/courier_flutter_v2.dart';
import 'package:courier_flutter_sample/env.dart';
import 'example_server.dart';

class UserBuilder {
  static Future build({
    bool useJWT = true,
    required String userId,
    String? tenantId,
  }) async {
    String? jwt;

    if (useJWT) {
      jwt = await ExampleServer.generateJwt(
        Env.authKey,
        userId,
      );
    }

    await CourierRC.shared.signIn(
      userId: userId,
      accessToken: jwt ?? Env.authKey,
      clientKey: Env.clientKey,
      showLogs: true,
    );
  }
}
