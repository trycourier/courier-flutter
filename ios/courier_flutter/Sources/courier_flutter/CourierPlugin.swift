import Flutter
import UIKit
import Courier_iOS

public class CourierPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        CourierSharedMethodHandler.register(with: registrar)
        CourierClientMethodHandler.register(with: registrar)
    }
    
}
