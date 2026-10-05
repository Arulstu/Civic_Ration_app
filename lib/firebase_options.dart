// Generated and hardened firebase_options.dart with multiplatform fallback
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
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCipA4rxaEe67razSRAFFiU-ECO9NOd7mc',
    appId: '1:1098350848598:web:ac3f8461bd64a4bdd729f7',
    messagingSenderId: '1098350848598',
    projectId: 'ration-824b9',
    authDomain: 'ration-824b9.firebaseapp.com',
    storageBucket: 'ration-824b9.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCipA4rxaEe67razSRAFFiU-ECO9NOd7mc',
    appId: '1:1098350848598:android:ac3f8461bd64a4bdd729f7',
    messagingSenderId: '1098350848598',
    projectId: 'ration-824b9',
    storageBucket: 'ration-824b9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCipA4rxaEe67razSRAFFiU-ECO9NOd7mc',
    appId: '1:1098350848598:ios:ac3f8461bd64a4bdd729f7',
    messagingSenderId: '1098350848598',
    projectId: 'ration-824b9',
    storageBucket: 'ration-824b9.firebasestorage.app',
    iosClientId: '1098350848598-ios.googleusercontent.com',
    iosBundleId: 'com.civic.ration',
  );
}
