import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];

  // FastAPI server URL
  final String apiUrl = "http://10.0.2.2:8000/ask/";

  // Send a request to the FastAPI server
  Future<String> _getBotResponse(String question) async {
    // Example context; replace it with dynamic content if needed
    String context = "A broker is an individual or firm that acts as an intermediary between an investor and a"
        " securities exchange.Bad stock may refer to securities that are underperforming or losing value in the market."
        " Brokers may suggest selling such stocks, holding them for potential recovery, or reallocating investments.";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question,
          'context': context,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Server Response: $responseData");
        return responseData['answer'] ?? "Cevap alınamadı.";
      } else {
        print("Hata: ${response.statusCode} - ${response.body}");
        return "Hata: Sunucudan geçerli bir yanıt alınamadı.";
      }
    } catch (e) {
      print("API çağrısı sırasında hata: $e");
      return "API çağrısı başarısız oldu.";
    }
  }

  // Send user message and get bot response
  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      String userMessage = _controller.text;

      _messages.add({
        'sender': 'user',
        'message': userMessage,
      });

      _controller.clear();
    });

    // Get response from the FastAPI server
    String botResponse = await _getBotResponse(_controller.text);

    setState(() {
      _messages.add({
        'sender': 'bot',
        'message': botResponse,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Chatbot'),
        elevation: 4.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Mesajınızı yazın...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, String> message) {
    bool isUserMessage = message['sender'] == 'user';

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message['message']!,
          style: TextStyle(
            color: isUserMessage ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
