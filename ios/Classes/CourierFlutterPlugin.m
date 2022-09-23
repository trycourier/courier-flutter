#import "CourierFlutterPlugin.h"
#if __has_include(<courier_flutter/courier_flutter-Swift.h>)
#import <courier_flutter/courier_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "courier_flutter-Swift.h"
#endif

@implementation CourierFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCourierFlutterPlugin registerWithRegistrar:registrar];
}
@end
