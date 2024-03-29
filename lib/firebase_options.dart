// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAR7i4WPegu51U5tZH_Jnv0zOFKQeLrCNs',
    appId: '1:127822371110:web:b92bdbe997675ffa7d49e7',
    messagingSenderId: '127822371110',
    projectId: 'guardian-9d8c5',
    authDomain: 'guardian-9d8c5.firebaseapp.com',
    storageBucket: 'guardian-9d8c5.appspot.com',
    measurementId: 'G-G03KS4P23G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlergplLL5cRz8EnfeBSKjwBw5_in4V2Q',
    appId: '1:127822371110:android:7de5a87f8f93cc717d49e7',
    messagingSenderId: '127822371110',
    projectId: 'guardian-9d8c5',
    storageBucket: 'guardian-9d8c5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJLxpDM3fB2mRRRKuA4MqlV3ZYFjoBCSI',
    appId: '1:127822371110:ios:9cdb778b795b78807d49e7',
    messagingSenderId: '127822371110',
    projectId: 'guardian-9d8c5',
    storageBucket: 'guardian-9d8c5.appspot.com',
    iosBundleId: 'com.linovt.Guardian',
  );
}
