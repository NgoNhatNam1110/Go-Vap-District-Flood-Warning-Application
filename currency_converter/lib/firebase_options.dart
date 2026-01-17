/// File cấu hình Firebase cho ứng dụng
/// 
/// HƯỚNG DẪN:
/// 1. Đăng ký ứng dụng Flutter trên Firebase Console
/// 2. Tải google-services.json (Android) và GoogleService-Info.plist (iOS)
/// 3. Chạy lệnh: flutterfire configure
/// 4. File này sẽ được tự động generate
/// 
/// Nếu chưa có, hãy chạy:
/// $ flutterfire configure --platforms=android,ios,windows,web,macos
///
/// Link hướng dẫn: https://firebase.flutter.dev/docs/overview/

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isIOS) {
      return ios;
    }
    if (Platform.isWindows) {
      return windows;
    }
    if (Platform.isMacOS) {
      return macos;
    }
    if (Platform.isLinux) {
      return linux;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  /// CẤU HÌNH CHO ANDROID
  /// 
  /// Hãy thay thế các giá trị sau bằng thông tin từ Firebase Console:
  /// - projectId: Project ID từ Firebase Console
  /// - apiKey: Android API Key
  /// - appId: Android App ID
  /// - messagingSenderId: GCP Project Number
  /// - databaseURL: Firestore Database URL (nếu dùng)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY_HERE',
    appId: 'YOUR_ANDROID_APP_ID_HERE',
    messagingSenderId: 'YOUR_GCP_PROJECT_NUMBER',
    projectId: 'your-firebase-project-id',
    databaseURL: 'https://your-project.firebaseio.com',
  );

  /// CẤU HÌNH CHO iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY_HERE',
    appId: 'YOUR_IOS_APP_ID_HERE',
    messagingSenderId: 'YOUR_GCP_PROJECT_NUMBER',
    projectId: 'your-firebase-project-id',
    databaseURL: 'https://your-project.firebaseio.com',
    iosBundleId: 'com.example.currencyConverter',
  );

  /// CẤU HÌNH CHO WEB
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY_HERE',
    appId: 'YOUR_WEB_APP_ID_HERE',
    messagingSenderId: 'YOUR_GCP_PROJECT_NUMBER',
    projectId: 'your-firebase-project-id',
    authDomain: 'your-project.firebaseapp.com',
    databaseURL: 'https://your-project.firebaseio.com',
    storageBucket: 'your-project.appspot.com',
  );

  /// CẤU HÌNH CHO WINDOWS
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY_HERE',
    appId: 'YOUR_WINDOWS_APP_ID_HERE',
    messagingSenderId: 'YOUR_GCP_PROJECT_NUMBER',
    projectId: 'your-firebase-project-id',
    authDomain: 'your-project.firebaseapp.com',
    databaseURL: 'https://your-project.firebaseio.com',
    storageBucket: 'your-project.appspot.com',
  );

  /// CẤU HÌNH CHO macOS
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY_HERE',
    appId: 'YOUR_MACOS_APP_ID_HERE',
    messagingSenderId: 'YOUR_GCP_PROJECT_NUMBER',
    projectId: 'your-firebase-project-id',
    databaseURL: 'https://your-project.firebaseio.com',
    iosBundleId: 'com.example.currencyConverter.macos',
  );

  /// CẤU HÌNH CHO LINUX
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'YOUR_LINUX_API_KEY_HERE',
    appId: 'YOUR_LINUX_APP_ID_HERE',
    messagingSenderId: 'YOUR_GCP_PROJECT_NUMBER',
    projectId: 'your-firebase-project-id',
    databaseURL: 'https://your-project.firebaseio.com',
    storageBucket: 'your-project.appspot.com',
  );
}
