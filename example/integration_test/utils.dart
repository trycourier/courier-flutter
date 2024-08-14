import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/courier_flutter.dart';
import 'package:courier_flutter_sample/env.dart';
import 'example_server.dart';

Future<String> sendMessage(String userId) {
  return ExampleServer.sendTest(Env.authKey, userId, "inbox");
}

Future delay({int milliseconds = 5000}) {
  return Future.delayed(Duration(milliseconds: milliseconds));
}

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

    await Courier.shared.signIn(
      userId: userId,
      accessToken: jwt ?? Env.authKey,
      clientKey: Env.clientKey,
      showLogs: true,
    );
  }
}

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
