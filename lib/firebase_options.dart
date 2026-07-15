// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyDsECe4Jrl7R9GBT2LQxEApP0LpMNiuN7k",
      authDomain: "investment-9bb3b.firebaseapp.com",
      projectId: "investment-9bb3b",
      storageBucket: "investment-9bb3b.firebasestorage.app",
      messagingSenderId: "192324915373",
      appId: "1:192324915373:web:9e0a95fb17cf4cfacfb624"
    );
  }
}