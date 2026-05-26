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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDlI0HWX7FkXnUUDisJ6RrP5FlU7kRKUgk',
    appId: '1:534733405792:web:c0a685ff1da9b0a2628d05',
    messagingSenderId: '534733405792',
    projectId: 'sociallink-71308',
    authDomain: 'sociallink-71308.firebaseapp.com',
    storageBucket: 'sociallink-71308.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCWi7JGrM_mJqZ5NwV5cD8hf-UtFaz60zk',
    appId: '1:534733405792:android:bf40345baddccfe7628d05',
    messagingSenderId: '534733405792',
    projectId: 'sociallink-71308',
    storageBucket: 'sociallink-71308.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlI0HWX7FkXnUUDisJ6RrP5FlU7kRKUgk',
    appId: '1:534733405792:ios:1a2b3c4d5e6f7g8h9i',
    messagingSenderId: '534733405792',
    projectId: 'sociallink-71308',
    storageBucket: 'sociallink-71308.firebasestorage.app',
    iosBundleId: 'com.example.sociallink',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDlI0HWX7FkXnUUDisJ6RrP5FlU7kRKUgk',
    appId: '1:534733405792:ios:1a2b3c4d5e6f7g8h9i',
    messagingSenderId: '534733405792',
    projectId: 'sociallink-71308',
    storageBucket: 'sociallink-71308.firebasestorage.app',
    iosBundleId: 'com.example.sociallink',
  );
}
