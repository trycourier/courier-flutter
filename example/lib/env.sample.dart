import 'package:firebase_core/firebase_core.dart';

class SampleEnv {
  static const userId = 'XXXXX';
  static const accessToken = 'XXXXX';
  static const authKey = 'XXXXX';

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'XXXXX',
    appId: 'XXXXX',
    messagingSenderId: 'XXXXX',
    projectId: 'XXXXX',
    storageBucket: 'XXXXX',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'XXXXX',
    appId: 'XXXXX',
    messagingSenderId: 'XXXXX',
    projectId: 'XXXXX',
    storageBucket: 'XXXXX',
    iosClientId: 'XXXXX',
    iosBundleId: 'XXXXX',
  );
}
