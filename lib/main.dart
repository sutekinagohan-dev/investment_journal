import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ← ここで const を使うから...

  @override
  Widget build(BuildContext context) { // ← この build メソッドがないと画面が描けないの！
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Firebase 接続完了！")),
      ),
    );
  }
}