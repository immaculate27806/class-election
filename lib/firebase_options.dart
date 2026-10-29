import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS is not configured yet.');
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDJ7Tkx3JcXBejzdsC2T-doDK4PoJNvrcQ',
    authDomain: 'class-election-51484.firebaseapp.com',
    projectId: 'class-election-51484',
    storageBucket: 'class-election-51484.firebasestorage.app',
    messagingSenderId: '529263192103',
    appId: '1:529263192103:web:4128b7b84ffe482dccc602',
    measurementId: 'G-60JTE0FW94',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJ7Tkx3JcXBejzdsC2T-doDK4PoJNvrcQ',
    authDomain: 'class-election-51484.firebaseapp.com',
    projectId: 'class-election-51484',
    storageBucket: 'class-election-51484.firebasestorage.app',
    messagingSenderId: '529263192103',
    appId: '1:529263192103:android:1a3995dc0b6e73f3ccc602',
  );
}
