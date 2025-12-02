import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/chats/model/chat_model.dart';
import 'package:flutter_chatter_hub/features/chats/model/message_model.dart';
import 'package:flutter_chatter_hub/features/chats/widgets/sent_message_bubble.dart';
import 'package:flutter_chatter_hub/features/chats/widgets/received_message_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatModel chat;
  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<List<MessageModel>> messagesNotifier =
      ValueNotifier<List<MessageModel>>(
    [
      MessageModel(text: "Hi there!", isSentByMe: false),
      MessageModel(text: "Hello", isSentByMe: true),
    ],
  );

  /// SEND MESSAGE
  void sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final updatedList = List<MessageModel>.from(messagesNotifier.value)
      ..add(MessageModel(text: text, isSentByMe: true));

    messagesNotifier.value = updatedList;

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  
  void _deleteMessage(int index) {
    final updatedList = List<MessageModel>.from(messagesNotifier.value)
      ..removeAt(index);

    messagesNotifier.value = updatedList;
  }

  
  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete message?"),
          content: const Text("Do you want to delete this message?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteMessage(index);
                Navigator.pop(context);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDE7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF48BB8),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(212, 225, 53, 156)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chat.profilePic),
            ),
            const SizedBox(width: 10),
            Text(
              widget.chat.name,
              style: const TextStyle(
                color: Color.fromARGB(255, 187, 52, 97),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            child: IconButton(
              icon: const Icon(Icons.call,
                  color: Color.fromARGB(255, 187, 52, 97), size: 18),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white24,
            child: IconButton(
              icon: const Icon(Icons.videocam,
                  color: Color.fromARGB(255, 187, 52, 97), size: 18),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          
          Expanded(
            child: ValueListenableBuilder<List<MessageModel>>(
              valueListenable: messagesNotifier,
              builder: (context, msgs, _) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final msg = msgs[index];

                    return GestureDetector(
                      onLongPress: () {
                        _showDeleteDialog(index);
                      },
                      child: AnimatedScale(
                        scale: 1,
                        duration: const Duration(milliseconds: 120),
                        child: msg.isSentByMe
                            ? SentMessageBubble(text: msg.text)
                            : ReceivedMessageBubble(text: msg.text),
                      ),
                    );
                  },
                );
              },
            ),
          ),

        
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF3A4C3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined,
                      color: Color.fromARGB(255, 162, 45, 84)),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.attach_file,
                      color: Color.fromARGB(255, 187, 52, 97)),
                  onPressed: () {},
                ),
                const SizedBox(width: 6),
                ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, _, __) {
                    final isEmpty = _controller.text.trim().isEmpty;

                    return GestureDetector(
                      onTap: () {
                        if (!isEmpty) sendMessage();
                      },
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color.fromARGB(255, 187, 52, 97),
                        child: Icon(
                          isEmpty ? Icons.mic : Icons.send,
                          color: const Color.fromARGB(255, 236, 233, 234),
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
