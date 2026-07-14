import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LogScreen());
  }
}

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final TextEditingController _controller = TextEditingController();

  void _saveLog() async {
  print("【ボタン押された！】"); // これを一番上に入れる
  if (_controller.text.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('logs').add({
        'text': _controller.text,
        'createdAt': Timestamp.now(),
      });
      _controller.clear();
      print("【成功】データベースに保存されました！"); // これを追加
    } catch (e) {
      print("【エラー】保存に失敗しました：$e"); // これを追加
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("投資思考ログ")),
      body: Column(
        children: [
          TTextField(controller: _controller, decoration: InputDecoration(hintText: "今の思考を記録...")),
          ElevatedButton(
            onPressed: () {
              print("【ボタン押された！】確認用");
              _saveLog();
            }, 
            child: Text("保存する")
        ],
      ),
    );
  }
}