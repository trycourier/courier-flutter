import Flutter
import UIKit

public class SwiftCourierFlutterPlugin: NSObject, FlutterPlugin {
    
    private static let COURIER_ERROR_TAG = "Courier Android SDK Error"
    private static let CORE_CHANNEL = "courier_flutter_core"
    private static let EVENTS_CHANNEL = "courier_flutter_events"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CORE_CHANNEL, binaryMessenger: registrar.messenger())
        let instance = SwiftCourierFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          
        switch call.method {
            
        case "isDebugging":
            
            result(false)
            break
            
        default:
            
            result(FlutterMethodNotImplemented)
            
        }
          
    }
}
