import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'firebase_options.dart';

const String apiKey = 'YOUR_GEMINI_API_KEY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geminiと私',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  File? _selectedFile;

  final model = GenerativeModel(
    model: 'gemini-3.5-flash',
    apiKey: apiKey,
    systemInstruction: Content.text(
      "あなたは投資家の専属パートナーです。常に『批判的思考』と『深層分析』モードで応答せよ。"
      "画像や資料が送られた場合、それを詳細に分析し、市場の歪みや投資機会を論理的に指摘せよ。"
    ),
  );

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() { _selectedFile = File(result.files.single.path!); });
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty && _selectedFile == null) return;

    String userMessage = _controller.text;
    List<Part> parts = [TextPart(userMessage)];

    if (_selectedFile != null) {
      final bytes = await _selectedFile!.readAsBytes();
      final mimeType = lookupMimeType(_selectedFile!.path) ?? 'image/jpeg';
      parts.add(DataPart(mimeType, bytes));
      setState(() => _selectedFile = null); // 送信後はクリア
    }

    _controller.clear();

    await FirebaseFirestore.instance.collection('stock_logs').add({
      'role': 'user', 'message': userMessage, 'createdAt': FieldValue.serverTimestamp(),
    });

    var historySnapshot = await FirebaseFirestore.instance
        .collection('stock_logs').orderBy('createdAt', descending: false).get();

    List<Content> history = historySnapshot.docs.map((doc) => 
      doc['role'] == 'user' ? Content.text(doc['message']) : Content.model([TextPart(doc['message'])])
    ).toList();

    final chat = model.startChat(history: history);
    final response = await chat.sendMessage(Content.multi(parts));

    await FirebaseFirestore.instance.collection('stock_logs').add({
      'role': 'model', 'message': response.text!, 'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Geminiと私"), backgroundColor: Colors.white, elevation: 1),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('stock_logs').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    bool isUser = doc['role'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(color: isUser ? Color(0xFFE3F2FD) : Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20)),
                        child: Text(doc['message'], style: TextStyle(fontSize: 16)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_selectedFile != null) Container(padding: EdgeInsets.all(8), color: Colors.blue.shade50, child: Text("画像を選択済み")),
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.attach_file), onPressed: _pickFile),
                Expanded(
                  child: TextField(controller: _controller, decoration: InputDecoration(hintText: "銘柄分析や資料を添付...", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none))),
                ),
                IconButton(icon: Icon(Icons.send, color: Colors.blue), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}