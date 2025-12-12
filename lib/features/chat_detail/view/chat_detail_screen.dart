import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/features/chat_detail/view/widgets/message_bubble.dart';
import 'package:flutter_chatter_hub/features/chat_detail/view_model/chat_detial_view_model.dart';
import 'package:flutter_chatter_hub/features/chats/model/message_model.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ChatDetailScreen extends StatefulWidget {
  final String username, uid;
  final String? pfp;
  const ChatDetailScreen({super.key, required this.username, required this.pfp, required this.uid});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
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
    debugPrint('User id : ${widget.uid}');
    return ChangeNotifierProvider(
      create: (context) => ChatDetialViewModel(),
      builder: (_, __) => Consumer<ChatDetialViewModel>(
        builder: (_, viewModel, __) => Scaffold(
          backgroundColor: const Color(0xFFFDE7F3),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: AppBar(
              backgroundColor: const Color(0xFFF48BB8),
              elevation: 2,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color.fromARGB(212, 225, 53, 156)),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: widget.pfp != null ? NetworkImage(widget.pfp!) : null,
                    child: widget.pfp == null ? const Icon(Icons.person, size: 30, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.username,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 187, 52, 97),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: Row(
                      children: [
                        const Spacer(),
                        Expanded(
                          child: _invitationButton(icon: Icons.call, label: 'Audio call', isVideoCall: false),
                        ),
                        Expanded(
                          child: _invitationButton(icon: Icons.video_call, label: 'Video call', isVideoCall: true),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<MessageModel>>(
                  stream: viewModel.listenToMessages(widget.uid),
                  builder: (context, snapshot) {
                    if ((!snapshot.hasData)) {
                      return const SizedBox();
                    }
                    final messages = snapshot.data!;
                    return ListView.builder(
                      controller: viewModel.scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        WidgetsBinding.instance.addPostFrameCallback(
                            (_) => viewModel.scrollController.jumpTo(viewModel.scrollController.position.maxScrollExtent));
                        final msg = messages[index];
                        final userId = injector<SharedPref>().getValue('uid');

                        return GestureDetector(
                          onLongPress: () {
                            _showDeleteDialog(index);
                          },
                          child: AnimatedScale(
                            scale: 1,
                            duration: const Duration(milliseconds: 120),
                            child: MessageBubble(
                              message: msg,
                              isMe: msg.senderUserId == userId,
                            ),
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
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          controller: viewModel.messageController,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              viewModel.isEmpty.value = true;
                            } else {
                              viewModel.isEmpty.value = false;
                            }
                          },
                          textInputAction: TextInputAction.send,
                          decoration: const InputDecoration(
                            hintText: "Type a message",
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Color.fromARGB(255, 187, 52, 97)),
                      onPressed: () => viewModel.pickMedia(widget.uid, widget.username, widget.pfp),
                    ),
                    const SizedBox(width: 6),
                    ValueListenableBuilder(
                      valueListenable: viewModel.isEmpty,
                      builder: (context, isEmpty, __) {
                        return GestureDetector(
                          onTap: () {
                            if (!isEmpty) {
                              viewModel.sendTextMessage(otherUserId: widget.uid, otherUserName: widget.username, otherUserPfp: widget.pfp);
                            }
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
        ),
      ),
    );
  }

  Widget _invitationButton({
    required IconData icon,
    required String label,
    required bool isVideoCall,
  }) {
    final targetUserID = widget.uid;

    return Material(
      color: Colors.transparent,
      child: ZegoSendCallInvitationButton(
        isVideoCall: isVideoCall,
        resourceID: "zego_uikit_call",
        invitees: [
          ZegoUIKitUser(
            id: targetUserID,
            name: widget.username,
          ),
        ],
        icon: ButtonIcon(
          icon: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
