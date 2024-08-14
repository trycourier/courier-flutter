import 'package:courier_flutter/utils.dart';
import 'package:flutter/material.dart';

class CourierBrandResponse {
  final CourierBrandData? data;

  CourierBrandResponse({
    this.data,
  });

  factory CourierBrandResponse.fromJson(Map<String, dynamic> json) {
    return CourierBrandResponse(
      data: CourierBrandData.fromJson(json['data']),
    );
  }
}

class CourierBrandData {
  final CourierBrand? brand;

  CourierBrandData({
    this.brand,
  });

  factory CourierBrandData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CourierBrandData();
    }
    return CourierBrandData(
      brand: CourierBrand.fromJson(json['brand']),
    );
  }
}

class CourierBrand {
  final CourierBrandSettings? settings;

  CourierBrand({
    this.settings,
  });

  factory CourierBrand.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CourierBrand();
    }
    return CourierBrand(
      settings: CourierBrandSettings.fromJson(json['settings']),
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

  factory CourierBrandSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CourierBrandSettings();
    }
    return CourierBrandSettings(
      inapp: CourierBrandInApp.fromJson(json['inapp']),
      colors: CourierBrandColors.fromJson(json['colors']),
    );
  }
}

class CourierBrandInApp {
  final bool? disableCourierFooter;

  CourierBrandInApp({
    this.disableCourierFooter = false,
  });

  factory CourierBrandInApp.fromJson(Map<String, dynamic>? json) {
    return CourierBrandInApp(
      disableCourierFooter: json?['disableCourierFooter'],
    );
  }

  bool get showCourierFooter =>
      disableCourierFooter != null ? !disableCourierFooter! : true;
}

class CourierBrandColors {
  final String? primary;

  CourierBrandColors({
    this.primary,
  });

  factory CourierBrandColors.fromJson(Map<String, dynamic>? json) {
    return CourierBrandColors(
      primary: json?['primary'] as String?,
    );
  }

  Color? primaryColor() {
    return primary != null ? hexToColor(primary!) : null;
  }
}
