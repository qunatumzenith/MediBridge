import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messageController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      'Hello! I\'m your health assistant. How can I help you today?',
    );
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: text,
          isUser: false,
        ),
      );
    });
  }

  Future<void> _handleSubmitted(String text) async {
    _messageController.clear();

    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );
      _isLoading = true;
    });

    try {
      // Simple keyword-based responses
      final lowerText = text.toLowerCase();
      String response;

      if (lowerText.contains('headache')) {
        response = 'For headaches, I recommend:\n'
            '1. Rest in a quiet, dark room\n'
            '2. Stay hydrated\n'
            '3. Try over-the-counter pain relievers\n'
            '4. Apply a cold or warm compress\n\n'
            'If symptoms persist, please consult a doctor.';
      } else if (lowerText.contains('fever')) {
        response = 'For fever management:\n'
            '1. Take rest\n'
            '2. Stay hydrated\n'
            '3. Take paracetamol if temperature is high\n'
            '4. Use a cool compress\n\n'
            'If fever persists for more than 3 days, consult a doctor.';
      } else if (lowerText.contains('cold') || lowerText.contains('cough')) {
        response = 'For cold and cough:\n'
            '1. Get plenty of rest\n'
            '2. Stay hydrated\n'
            '3. Try honey and warm water\n'
            '4. Use steam inhalation\n\n'
            'Visit a doctor if symptoms worsen or persist.';
      } else if (lowerText.contains('stomach') || lowerText.contains('digestion')) {
        response = 'For stomach issues:\n'
            '1. Eat light, easily digestible food\n'
            '2. Stay hydrated\n'
            '3. Avoid spicy and oily food\n'
            '4. Try probiotics\n\n'
            'Consult a doctor if pain is severe or persistent.';
      } else {
        response = 'I\'m sorry, I can only provide basic health advice. '
            'For specific medical concerns, please consult a healthcare professional. '
            'Would you like me to help you book an appointment with a doctor?';
      }

      // Save the conversation
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('chat_history')
          .add({
        'message': text,
        'response': response,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              text: response,
              isUser: false,
            ),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot'),
      ),
      body: Column(
        children: [
          Image.asset(
            'images/chatbot.webp',
            height: 100,
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _messages[index],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type your health concern...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              onSubmitted: _isLoading ? null : _handleSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading
                ? null
                : () => _handleSubmitted(_messageController.text),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(
                  Icons.health_and_safety,
                  color: Colors.white,
                ),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}