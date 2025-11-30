import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/chats/model/chat_model.dart';
import 'package:flutter_chatter_hub/features/chats/model/message_model.dart';
import 'package:flutter_chatter_hub/features/chats/widgets/received_message_bubble.dart';
import 'package:flutter_chatter_hub/features/chats/widgets/sent_message_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatModel chat;
  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();

  List<MessageModel> messages = [
    MessageModel(text: "Hi there!", isSentByMe: false),
    MessageModel(text: "Hello", isSentByMe: true),
  ];

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    messages.add(
      MessageModel(
        text: _controller.text.trim(),
        isSentByMe: true,
      ),
    );

    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 243, 126, 165),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chat.profilePic),
            ),
            const SizedBox(width: 10),
            Text(widget.chat.name),
          ],
        ),
      ),
      body: Column(
        children: [
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return msg.isSentByMe
                    ? SentMessageBubble(text: msg.text)
                    : ReceivedMessageBubble(text: msg.text);
              },
            ),
          ),

          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: const Color.fromARGB(255, 249, 210, 244),
            child: Row(
              children: [
                
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                  onPressed: () {
                    // Emoji implementation
                  },
                ),

                
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Type a message",
                              border: InputBorder.none,
                            ),
                            onChanged: (_) {
                              setState(() {}); 
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.attach_file, color: Colors.grey),
                          onPressed: () {
                            //   attachment option
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                
                GestureDetector(
                  onTap: () {
                    if (_controller.text.trim().isNotEmpty) {
                      sendMessage();
                    } else {
                      //voice recording
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFEFAEC3),
                    radius: 25,
                    child: Icon(
                      _controller.text.trim().isEmpty ? Icons.mic : Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}