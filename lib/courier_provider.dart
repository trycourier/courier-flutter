enum CourierProvider {
  apns,
  fcm,
}

extension CourierProviderExt on CourierProvider {

  String get value {
    switch (this) {
      case CourierProvider.apns:
        return 'apn';
      case CourierProvider.fcm:
        return 'firebase-fcm';
      default: {
        return 'unknown';
      }
    }
  }

}