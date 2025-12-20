import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/enums/message_type.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/core/services/db/db_remote_service.dart';
import 'package:flutter_chatter_hub/features/chat_detail/view/widgets/message_bubble.dart';
import 'package:flutter_chatter_hub/features/chat_detail/view_model/chat_detial_view_model.dart';
import 'package:flutter_chatter_hub/features/chats/model/message_model.dart';
import 'package:flutter_chatter_hub/features/home/view_model/home_view_model.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:provider/provider.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final String username, uid;
  final String? pfp;
  const ChatDetailScreen({
    super.key,
    required this.username,
    required this.pfp,
    required this.uid,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
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
      debugPrint('✅ Microphone permission granted');
      return true;
    } else if (status.isPermanentlyDenied) {
      debugPrint('⚠️ Microphone permission permanently denied');
      _showPermissionDialog();
      return false;
    } else {
      debugPrint('❌ Microphone permission denied');
      return false;
    }
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
      debugPrint('❌ Recorder not initialized');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio recorder not ready')),
        );
      }
      return;
    }

    try {
      final hasPermission = await _requestMicrophonePermission();
      if (!hasPermission) return;

      // Generate unique filename with path
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/voice_note_$timestamp.aac';

      debugPrint('🎤 Starting recording to: $filePath');

      await _audioRecorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
      );

      setState(() {
        isRecording = true;
        recordedAudioPath = null;
      });

      _startRecordingTimer();
      debugPrint('✅ Recording started');
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording error: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording({bool sendMessage = true}) async {
    if (!isRecording) return;

    try {
      debugPrint('🛑 Stopping recording...');
      String? path = await _audioRecorder.stopRecorder();

      _stopRecordingTimer();

      setState(() {
        isRecording = false;
        recordedAudioPath = path;
      });

      debugPrint('✅ Recording stopped. Path: $path');
      debugPrint('📊 Recording duration: ${recordingDuration.inSeconds}s');

      // Send the audio message if requested
      if (sendMessage &&
          recordedAudioPath != null &&
          recordedAudioPath!.isNotEmpty) {
        await _sendAudioMessage(recordedAudioPath!);
      } else if (!sendMessage) {
        debugPrint('🗑️ Recording cancelled');
      } else {
        debugPrint('⚠️ No audio path received');
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
          debugPrint('🗑️ Deleted cancelled recording');
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
      debugPrint('📤 Preparing to send audio message...');

      final currentUserId = injector<SharedPref>().getValue('uid');
      final currentUserName = injector<SharedPref>().getValue('name');
      final currentUserPfp = injector<SharedPref>().getValue('profilePic');

      if (currentUserId == null || currentUserId.isEmpty) {
        debugPrint('❌ Current user ID is null or empty');
        return;
      }

      // Generate chat ID
      final chatId = generateChatId(currentUserId, widget.uid);
      debugPrint('💬 Chat ID: $chatId');

      // Create message ID
      final messageId = const Uuid().v4();
      debugPrint('📝 Message ID: $messageId');

      // Get audio file info
      final file = File(audioPath);
      final fileSize = await file.length();
      debugPrint(
          '📊 Audio file size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      // TODO: Upload audio file to Firebase Storage
      // For now, using local path (should be replaced with cloud URL in production)

      final message = MessageModel(
        messageId: messageId,
        senderUserId: currentUserId,
        audioUrl: audioPath, // TODO: Replace with uploaded URL
        type: MessageType.audio,
        timestamp: Timestamp.now(),
      );

      debugPrint('📨 Sending message to Firestore...');

      await injector<FirebaseFirestoreService>().sendMessage(
        currentUserId: currentUserId,
        otherUserId: widget.uid,
        currentUserName: currentUserName ?? 'Unknown',
        otherUserName: widget.username,
        otherUserPfp: widget.pfp,
        chatId: chatId,
        message: message,
        currentUserPfp: currentUserPfp,
      );

      debugPrint('✅ Audio message sent successfully!');

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send voice note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String generateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
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
    debugPrint('User id : ${widget.uid}');
    return ChangeNotifierProvider(
      create: (context) => ChatDetialViewModel(),
      builder: (_, __) => Consumer<ChatDetialViewModel>(
        builder: (_, viewModel, __) => Scaffold(
          backgroundColor: const Color(0xFFFDE7F3),
          appBar: AppBar(
            toolbarHeight: 80,
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
                  radius: 22,
                  backgroundImage:
                      widget.pfp != null ? NetworkImage(widget.pfp!) : null,
                  child: widget.pfp == null
                      ? const Icon(Icons.person, size: 26, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.username,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 187, 52, 97),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            // Replace the actions section in your AppBar with this:

            actions: [
              // Signaling status indicator
              ValueListenableBuilder<bool>(
                valueListenable:
                    HomeViewModel.getInstance().isSignalingConnected,
                builder: (context, isConnected, _) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: isConnected
                              ? [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  final homeVM = HomeViewModel.getInstance();
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.pinkAccent,
                    builder: (_) => ValueListenableBuilder<bool>(
                      valueListenable: homeVM.isSignalingConnected,
                      builder: (context, isConnected, _) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Connection status warning
                              if (!isConnected)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded,
                                          color: Colors.orange.shade700),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Call service connecting...\nPlease wait a moment.',
                                          style: TextStyle(
                                            color: Colors.orange.shade900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Voice Call Option
                              Opacity(
                                opacity: isConnected ? 1.0 : 0.5,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Flexible(
                                      fit: FlexFit.loose,
                                      child: Text(
                                        'Voice Call',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    AbsorbPointer(
                                      absorbing: !isConnected,
                                      child: _invitationButton(
                                        icon: Icons.call,
                                        label: 'Audio',
                                        isVideoCall: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Video Call Option
                              Opacity(
                                opacity: isConnected ? 1.0 : 0.5,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Flexible(
                                      fit: FlexFit.loose,
                                      child: Text(
                                        'Video Call',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    AbsorbPointer(
                                      absorbing: !isConnected,
                                      child: _invitationButton(
                                        icon: Icons.video_call,
                                        label: 'Video',
                                        isVideoCall: true,
                                      ),
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
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<MessageModel>>(
                  stream: viewModel.listenToMessages(widget.uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
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
                        WidgetsBinding.instance.addPostFrameCallback((_) =>
                            viewModel.scrollController.jumpTo(viewModel
                                .scrollController.position.maxScrollExtent));
                        final msg = messages[index];
                        final userId = injector<SharedPref>().getValue('uid');

                        return GestureDetector(
                          onLongPress: () => _showDeleteDialog(index, msg),
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

              // Enhanced recording indicator
              if (isRecording)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      // Pulsing red dot
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

                      // Recording text
                      const Text(
                        'Recording',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Duration
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
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

                      // // Slide to cancel hint
                      // Expanded(
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //       Icon(
                      //         Icons.arrow_back,
                      //         color: Colors.white.withOpacity(0.7),
                      //         size: 18,
                      //       ),
                      //       const SizedBox(width: 4),
                      //       Text(
                      //         'Slide to cancel',
                      //         style: TextStyle(
                      //           color: Colors.white.withOpacity(0.7),
                      //           fontSize: 12,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      const SizedBox(width: 8),

                      // Cancel button
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                              otherUserId: widget.uid,
                              otherUserName: widget.username,
                              otherUserPfp: widget.pfp,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.attach_file,
                          color: Color.fromARGB(255, 187, 52, 97)),
                      onPressed: () => viewModel.pickMedia(
                          widget.uid, widget.username, widget.pfp),
                    ),
                    const SizedBox(width: 6),
                    ValueListenableBuilder(
                      valueListenable: viewModel.isEmpty,
                      builder: (context, isEmpty, __) {
                        return GestureDetector(
                          onTap: () {
                            if (!isEmpty) {
                              viewModel.sendTextMessage(
                                otherUserId: widget.uid,
                                otherUserName: widget.username,
                                otherUserPfp: widget.pfp,
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
                                color: const Color.fromARGB(255, 236, 233, 234),
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
    log('Target User ID for call invitation: $targetUserID');
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

  void _showDeleteDialog(int messageIndex, MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              debugPrint('Delete message: ${message.messageId}');
              // TODO: Implement message deletion
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
