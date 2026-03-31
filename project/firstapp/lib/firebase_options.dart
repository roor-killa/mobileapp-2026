// File generated manually from google-services.json
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAh76n-9BRh6zfFO51f76rkKC0tyqzgVwM',
    appId: '1:42237182374:android:3764bf12b26117dffd8f67',
    messagingSenderId: '42237182374',
    projectId: 'mobileapp-bkn',
    storageBucket: 'mobileapp-bkn.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDzUb4JQVv46daxCYt8HLOyZHyTmo3muls',
    appId: '1:42237182374:ios:bcc1bfeba9526db4fd8f67',
    messagingSenderId: '42237182374',
    projectId: 'mobileapp-bkn',
    storageBucket: 'mobileapp-bkn.firebasestorage.app',
    iosBundleId: 'com.bokaynou.bkn',
  );
}
