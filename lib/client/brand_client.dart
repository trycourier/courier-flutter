import 'dart:convert';

import 'package:courier_flutter/client/courier_client.dart';
import 'package:courier_flutter/models/courier_brand.dart';

class BrandClient {
  final CourierClientOptions _options;

  BrandClient(this._options);

  Future<CourierBrandResponse> getBrand({required String brandId}) async {
    final data = await _options.invokeClient('client.brands.get_brand', {
      'brandId': brandId,
    });
    final Map<String, dynamic> map = json.decode(data);
    return CourierBrandResponse.fromJson(map);
  }
}