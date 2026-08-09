import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController controller =
      TextEditingController();
  final ScrollController scrollController =
    ScrollController();    

  List<Map<String, String>> messages = [];
  bool isLoading = false;
  late stt.SpeechToText speech;
bool isListening = false;

 @override
void initState() {
  super.initState();

  speech = stt.SpeechToText();

  loadMessages();
}

  Future<void> saveMessages() async {
  final prefs = await SharedPreferences.getInstance();

  List<String> messagesJson =
      messages.map((e) => jsonEncode(e)).toList();

  await prefs.setStringList(
    'chat_history',
    messagesJson,
  );
}

Future<void> loadMessages() async {
  final prefs = await SharedPreferences.getInstance();

  List<String>? messagesJson =
      prefs.getStringList('chat_history');

  if (messagesJson != null) {
    setState(() {
      messages = messagesJson
          .map(
            (e) => Map<String, String>.from(
              jsonDecode(e),
            ),
          )
          .toList();
    });
  }
} 


Future<void> exportPdf(String text) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "StudyMate AI Response",
            style: pw.TextStyle(fontSize: 22),
          ),
          pw.SizedBox(height: 20),
          pw.Text(text),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) async => pdf.save(),
  );
}


  
Future<void> askAI() async {
  if (isListening) {
  await speech.stop();

  setState(() {
    isListening = false;
  });
}
  if (controller.text.trim().isEmpty) {
  return;
}
  final userMessage = controller.text;

  setState(() {
  messages.add({
    "role": "user",
    "text": userMessage,
  });

  messages.add({
    "role": "ai",
    "text": "Thinking...",
  });

  saveMessages();
  controller.clear();
});
  scrollToBottom();

  try {
    final responseApi = await http.post(
  Uri.parse(
  'https://luminous-druid-6278f0.netlify.app/.netlify/functions/chat',
),
  headers: {
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    "messages": messages
        .where((msg) => msg["text"] != "Thinking...")
        .map(
          (msg) => {
            "role":
                msg["role"] == "ai"
                    ? "assistant"
                    : "user",
            "content": msg["text"],
          },
        )
        .toList(),
  }),
);

    final data = jsonDecode(responseApi.body);

print(data); // see actual response in terminal

if (data["choices"] != null) {
  setState(() {
    messages.removeLast();

    messages.add({
      "role": "ai",
      "text": data["choices"][0]["message"]["content"],
    });

    saveMessages();
    isLoading = false;
  });

  scrollToBottom();
} else {
  setState(() {
    messages.add({
      "role": "ai",
      "text": "API Error: ${data.toString()}",
    });
    isLoading = false;
  });
}
  } catch (e) {
    setState(() {
     messages.add({
  "role": "ai",
  "text": "Error: $e",
});

isLoading = false;
      
    });
  }
}

void scrollToBottom() {
  Future.delayed(
    const Duration(milliseconds: 100),
    () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    },
  );
}

Future<void> startListening() async {
  if (isListening) {
  await speech.stop();
}
  bool available = await speech.initialize();

  if (available) {
    await speech.stop();
    controller.clear();

    setState(() {
      isListening = true;
    });

   speech.listen(
 
  onResult: (result) {
    setState(() {
      controller.text = result.recognizedWords;
    });

    if (result.finalResult) {
      speech.stop();

      setState(() {
        isListening = false;
      });
    }
  },
);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text("StudyMate AI"),
  actions: [
    IconButton(
  icon: const Icon(Icons.add_comment),
  tooltip: "New Chat",
  onPressed: () async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Chat"),
        content: const Text(
          "Start a new conversation?",
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        messages.clear();
      });
    }
  },
),
  ],
),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
         
           children: [

  Expanded(
   child: ListView.builder(
            controller: scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              bool isUser =
                  messages[index]["role"] == "user";

              return Align(
                alignment: isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context)
                                .size
                                .width *
                            0.90,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Colors.blue
                        : Colors.grey.shade800,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      isUser
                          ? Text(
                              messages[index]["text"] ??
                                  "",
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            )
                          : MarkdownBody(
                              data:
                                  messages[index]
                                          ["text"] ??
                                      "",
                              styleSheet:
                                  MarkdownStyleSheet(
                                p:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),

                      if (!isUser)
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: messages[
                                            index]
                                        ["text"] ??
                                    "",
                              ),
                            );
                          },
                        ),

                        IconButton(
  icon: const Icon(
    Icons.picture_as_pdf,
    color: Colors.red,
  ),
  onPressed: () {
    exportPdf(
      messages[index]["text"] ?? "",
    );
  },
),
                    ],
                  ),
                ),
              );
            },
          ),
  ),

  const SizedBox(height: 10),

  Row(
    children: [
      Expanded(
        child: TextField(
          controller: controller,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              askAI();
            }
          },
          decoration: const InputDecoration(
            hintText: "Ask anything...",
            border: OutlineInputBorder(),
          ),
        ),
      ),

      IconButton(
  icon: const Icon(Icons.clear),
  onPressed: () {
    controller.clear();
  },
),

      const SizedBox(width: 8),

     IconButton(
  icon: Icon(
    isListening ? Icons.mic : Icons.mic_none,
  ),
  onPressed: () async {
  if (isListening) {
    await speech.stop();

    setState(() {
      isListening = false;
    });
  } else {
    startListening();
  }
},
),

IconButton(
  icon: const Icon(Icons.send),
  onPressed: askAI,
),
    ],
  ),
],
          
        ),
      ),
    );
  }
}