class CourierBrand {

  final CourierBrandSettings? settings;

  CourierBrand({
    this.settings,
  });

  factory CourierBrand.fromJson(dynamic data) {
    return CourierBrand(
      settings: CourierBrandSettings.fromJson(data['settings']),
    );
  }

}

class CourierBrandSettings {

  final CourierBrandInApp? inapp;
  final CourierBrandColors? colors;

  CourierBrandSettings({
    this.inapp,
    this.colors,
  });

  factory CourierBrandSettings.fromJson(dynamic data) {
    return CourierBrandSettings(
      inapp: CourierBrandInApp.fromJson(data['inapp']),
      colors: CourierBrandColors.fromJson(data['colors']),
    );
  }

}

class CourierBrandInApp {

  final bool showCourierFooter;

  CourierBrandInApp({
    required this.showCourierFooter,
  });

  factory CourierBrandInApp.fromJson(dynamic data) {
    return CourierBrandInApp(
      showCourierFooter: data['showCourierFooter'],
    );
  }

}

class CourierBrandColors {

  final String? primary;

  CourierBrandColors({
    this.primary,
  });

  factory CourierBrandColors.fromJson(dynamic data) {
    return CourierBrandColors(
      primary: data['primary'],
    );
  }

}