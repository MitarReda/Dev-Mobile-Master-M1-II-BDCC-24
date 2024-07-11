import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<String> getChatGptResponse(String input) async {
  
  final endpoint = Uri.https("api.openai.com", "/v1/chat/completions");

  final response = await http.post(endpoint, headers: {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  }, body: json.encode({
                              "model": "gpt-3",
                              "messages": [
                                {"role": "user", "content": "$input"}
                              ],
                              "temperature": 0.7
                            }));

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    return data['choices'][0]['text'].toString();
  } else {
    throw Exception('Failed to load response');
  }
}

class ChatPage extends StatefulWidget {
  ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
 
  final TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      String userInput = _controller.text;
      _controller.clear();
      setState(() {
        messages.add('You: $userInput');
      });
      try {
        String botResponse = await getChatGptResponse(userInput);
        setState(() {
          messages.add('ChatGPT: $botResponse');
        });
      } catch (e) {
        setState(() {
          messages.add('ChatGPT: Error fetching response');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Chatbot with ChatGPT'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Send a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
