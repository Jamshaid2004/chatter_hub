import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/enums/message_type.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/core/services/db/db_remote_service.dart';
import 'package:flutter_chatter_hub/features/chat_detail/view/widgets/message_bubble.dart';
import 'package:flutter_chatter_hub/features/chats/model/message_model.dart';
import 'package:flutter_chatter_hub/features/group/view_model/group_chat_view_model.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? groupIcon;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupIcon,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen>
    with SingleTickerProviderStateMixin {
  late FlutterSoundRecorder _audioRecorder;
  bool isRecording = false;
  String? recordedAudioPath;
  bool isRecorderInitialized = false;
  Duration recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeRecorder() async {
    _audioRecorder = FlutterSoundRecorder();

    try {
      await _audioRecorder.openRecorder();
      isRecorderInitialized = true;
      debugPrint('✅ Audio recorder initialized');
    } catch (e) {
      debugPrint('❌ Error initializing recorder: $e');
      isRecorderInitialized = false;
    }
  }

  void _startRecordingTimer() {
    recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          recordingDuration = Duration(seconds: timer.tick);
        });
      }
    });
    _pulseController.repeat(reverse: true);
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _pulseController.stop();
    _pulseController.reset();
  }

  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      return false;
    }
    return false;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'Please enable microphone permission in settings to record voice notes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    if (!isRecorderInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio recorder not ready')),
      );
      return;
    }

    try {
      final hasPermission = await _requestMicrophonePermission();
      if (!hasPermission) return;

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/voice_note_$timestamp.aac';

      await _audioRecorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );

      setState(() {
        isRecording = true;
        recordedAudioPath = null;
      });

      _startRecordingTimer();
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
    }
  }

  Future<void> _stopRecording({bool sendMessage = true}) async {
    if (!isRecording) return;

    try {
      String? path = await _audioRecorder.stopRecorder();
      _stopRecordingTimer();

      setState(() {
        isRecording = false;
        recordedAudioPath = path;
      });

      if (sendMessage &&
          recordedAudioPath != null &&
          recordedAudioPath!.isNotEmpty) {
        await _sendAudioMessage(recordedAudioPath!);
      }
    } catch (e) {
      debugPrint('❌ Error stopping recording: $e');
      setState(() {
        isRecording = false;
      });
      _stopRecordingTimer();
    }
  }

  Future<void> _cancelRecording() async {
    await _stopRecording(sendMessage: false);

    if (recordedAudioPath != null) {
      try {
        final file = File(recordedAudioPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('❌ Error deleting file: $e');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording cancelled'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _sendAudioMessage(String audioPath) async {
    try {
      final currentUserId = injector<SharedPref>().getValue('uid');
      final currentUserName = injector<SharedPref>().getValue('name');

      if (currentUserId == null || currentUserId.isEmpty) {
        debugPrint('❌ Current user ID is null or empty');
        return;
      }

      final messageId = const Uuid().v4();
      final message = MessageModel(
        messageId: messageId,
        senderUserId: currentUserId,
        audioUrl: audioPath,
        type: MessageType.audio,
        timestamp: Timestamp.now(),
      );

      await injector<FirebaseFirestoreService>().sendGroupMessage(
        groupId: widget.groupId,
        senderUserId: currentUserId,
        senderUserName: currentUserName ?? 'Unknown',
        message: message,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Voice note sent'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending audio message: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _stopRecordingTimer();
    _pulseController.dispose();
    if (isRecorderInitialized) {
      _audioRecorder.closeRecorder();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupChatViewModel(),
      child: Consumer<GroupChatViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFFDE7F3),
            appBar: AppBar(
              toolbarHeight: 80,
              backgroundColor: const Color(0xFFF48BB8),
              elevation: 2,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color.fromARGB(212, 225, 53, 156),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color.fromARGB(255, 187, 52, 97),
                    backgroundImage: widget.groupIcon != null
                        ? NetworkImage(widget.groupIcon!)
                        : null,
                    child: widget.groupIcon == null
                        ? const Icon(
                            Icons.group,
                            size: 26,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.groupName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 187, 52, 97),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Show group info
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<MessageModel>>(
                    stream: viewModel.listenToGroupMessages(widget.groupId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final messages = snapshot.data!;

                      if (messages.isEmpty) {
                        return const Center(
                          child: Text(
                            'No messages yet.\nSay hi! 👋',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: viewModel.scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => viewModel.scrollController.jumpTo(
                              viewModel
                                  .scrollController.position.maxScrollExtent,
                            ),
                          );

                          final msg = messages[index];
                          final userId = injector<SharedPref>().getValue('uid');

                          return MessageBubble(
                            message: msg,
                            isMe: msg.senderUserId == userId,
                          );
                        },
                      );
                    },
                  ),
                ),

                // Recording indicator
                if (isRecording)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade400,
                          Colors.red.shade600,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 4,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Recording',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formatDuration(recordingDuration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _cancelRecording,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Input area
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3A4C3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, -2),
                      ),
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
                            onSubmitted: (_) {
                              viewModel.sendTextMessage(
                                groupId: widget.groupId,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(
                          Icons.attach_file,
                          color: Color.fromARGB(255, 187, 52, 97),
                        ),
                        onPressed: () => viewModel.pickMedia(widget.groupId),
                      ),
                      const SizedBox(width: 6),
                      ValueListenableBuilder(
                        valueListenable: viewModel.isEmpty,
                        builder: (context, isEmpty, __) {
                          return GestureDetector(
                            onTap: () {
                              if (!isEmpty) {
                                viewModel.sendTextMessage(
                                  groupId: widget.groupId,
                                );
                              } else {
                                if (isRecording) {
                                  _stopRecording();
                                } else {
                                  _startRecording();
                                }
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: isRecording
                                    ? Colors.red
                                    : const Color.fromARGB(255, 187, 52, 97),
                                child: Icon(
                                  isEmpty
                                      ? (isRecording ? Icons.stop : Icons.mic)
                                      : Icons.send,
                                  color:
                                      const Color.fromARGB(255, 236, 233, 234),
                                  size: 22,
                                ),
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
        },
      ),
    );
  }
}
