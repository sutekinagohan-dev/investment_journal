import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyAVAM8wY5LYP7Rgz9vbSiTyjXsX-cn50',
      authDomain: 'investment-2ee02.firebaseapp.com',
      projectId: 'investment-2ee02',
      storageBucket: 'investment-2ee02.firebasestorage.app',
      messagingSenderId: '519654912144',
      appId: '1:519654912144:web:4e284411320ce06eebe815',
      measurementId: 'G-WBKQJNWSKW',
    );
  }
}