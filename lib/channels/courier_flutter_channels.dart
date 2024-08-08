import 'package:flutter/services.dart';

abstract class CourierFlutterChannels {
  static const MethodChannel client = MethodChannel('courier_flutter_client');
  static const MethodChannel shared = MethodChannel('courier_flutter_shared');
  static const MethodChannel events = MethodChannel('courier_flutter_events');
}