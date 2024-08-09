import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/models/courier_device.dart';

class TokenClient {
  final CourierClientOptions _options;

  TokenClient(this._options);

  Future putUserToken({required String token, required String provider, CourierDevice? device}) async {
    await _options.invokeClient('tokens.put_user_token', {
      'token': token,
      'provider': provider,
      'device': device?.toJson(),
    });
  }

  Future deleteUserToken({required String token}) async {
    await _options.invokeClient('tokens.delete_user_token', {
      'token': token,
    });
  }

}