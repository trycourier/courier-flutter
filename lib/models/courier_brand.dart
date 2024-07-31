import 'package:courier_flutter/utils.dart';
import 'package:flutter/material.dart';

class CourierBrandResponse {
  final CourierBrandData? data;

  CourierBrandResponse({
    this.data,
  });

  factory CourierBrandResponse.fromJson(dynamic data) {
    return CourierBrandResponse(
      data: CourierBrandData.fromJson(data['data']),
    );
  }
}

class CourierBrandData {
  final CourierBrand? brand;

  CourierBrandData({
    this.brand,
  });

  factory CourierBrandData.fromJson(dynamic data) {
    return CourierBrandData(
      brand: CourierBrand.fromJson(data['brand']),
    );
  }
}

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
  final bool disableCourierFooter;

  CourierBrandInApp({
    required this.disableCourierFooter,
  });

  factory CourierBrandInApp.fromJson(dynamic data) {
    return CourierBrandInApp(
      disableCourierFooter: data['disableCourierFooter'],
    );
  }

  bool get showCourierFooter {
    return !disableCourierFooter;
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

  Color? primaryColor() {
    if (primary != null) {
      return hexToColor(primary!);
    }

    return null;
  }
}
