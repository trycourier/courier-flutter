class CourierDevice {
  final String? appId;
  final String? adId;
  final String? deviceId;
  final String? platform;
  final String? manufacturer;
  final String? model;

  CourierDevice({
    this.appId,
    this.adId,
    this.deviceId,
    this.platform,
    this.manufacturer,
    this.model,
  });

  Map<String, dynamic> toJson() {
    return {
      'app_id': appId,
      'ad_id': adId,
      'device_id': deviceId,
      'platform': platform,
      'manufacturer': manufacturer,
      'model': model,
    };
  }
}
