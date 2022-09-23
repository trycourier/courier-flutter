
import 'courier_flutter_platform_interface.dart';

class Courier {

  Courier._();
  static Courier? _instance;
  static Courier get shared => _instance ??= Courier._();

  Future<String?> get userId => CourierFlutterPlatform.instance.userId();

  Future signIn({ required String accessToken, required String userId }) {
    return CourierFlutterPlatform.instance.signIn(accessToken, userId);
  }

  Future signOut() {
    return CourierFlutterPlatform.instance.signOut();
  }

}
