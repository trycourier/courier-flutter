import 'dart:convert';

import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/models/courier_brand.dart';

class BrandClient {
  final CourierClientOptions _options;

  BrandClient(this._options);

  Future<CourierBrandResponse> getBrand({required String id}) async {
    final data = await _options.invokeClient('client.brands.get_brand', {
      'brandId': id,
    });
    final Map<String, dynamic> map = json.decode(data);
    return CourierBrandResponse.fromJson(map);
  }
}