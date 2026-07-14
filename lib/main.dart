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
    if (_controller.text.isEmpty) return;
    await FirebaseFirestore.instance.collection('logs').add({
      'text': _controller.text,
      'createdAt': Timestamp.now(),
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("投資思考ログ")),
      body: Column(
        children: [
          TextField(controller: _controller, decoration: InputDecoration(hintText: "今の思考を記録...")),
          ElevatedButton(onPressed: _saveLog, child: Text("保存する")),
        ],
      ),
    );
  }
}