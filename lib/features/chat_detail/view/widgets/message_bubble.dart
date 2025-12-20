import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/enums/message_type.dart';
import 'package:flutter_chatter_hub/features/chat_detail/view/widgets/video_preview.dart';
import 'package:flutter_chatter_hub/features/chats/model/message_model.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';
import 'dart:io';

// Global audio manager to handle multiple players
class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;
  AudioPlayerManager._internal();

  _MessageBubbleState? _currentlyPlaying;

  void play(_MessageBubbleState player) {
    if (_currentlyPlaying != null && _currentlyPlaying != player) {
      _currentlyPlaying!.pauseFromManager();
    }
    _currentlyPlaying = player;
  }

  void stop(_MessageBubbleState player) {
    if (_currentlyPlaying == player) {
      _currentlyPlaying = null;
    }
  }
}

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  FlutterSoundPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isPlayerInitialized = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription? _playerSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == MessageType.audio) {
      _initializeAudioPlayer();
      _loadAudioDuration();
    }
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      _audioPlayer = FlutterSoundPlayer();
      await _audioPlayer!.openPlayer();
      setState(() {
        _isPlayerInitialized = true;
      });
      debugPrint('✅ Audio player initialized for message');
    } catch (e) {
      debugPrint('❌ Error initializing audio player: $e');
      setState(() {
        _isPlayerInitialized = false;
      });
    }
  }

  Future<void> _loadAudioDuration() async {
    if (widget.message.audioUrl == null || widget.message.audioUrl!.isEmpty) {
      return;
    }

    try {
      final file = File(widget.message.audioUrl!);
      if (await file.exists()) {
        final size = await file.length();
        // Rough estimation: AAC is about 2KB per second
        final estimatedSeconds = (size / 2048).round();
        if (mounted) {
          setState(() {
            _totalDuration = Duration(seconds: estimatedSeconds);
          });
        }
        debugPrint('📊 Estimated duration: ${_formatDuration(_totalDuration)}');
      }
    } catch (e) {
      debugPrint('⚠️ Could not estimate duration: $e');
    }
  }

  // Called by AudioPlayerManager to pause this player
  void pauseFromManager() {
    if (_isPlaying && _audioPlayer != null) {
      _audioPlayer!.pausePlayer();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
      debugPrint('⏸️ Audio paused by manager');
    }
  }

  Future<void> _togglePlayPause() async {
    if (!_isPlayerInitialized || _audioPlayer == null) {
      debugPrint('⚠️ Audio player not initialized');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio player not ready')),
        );
      }
      return;
    }

    try {
      if (_isPlaying) {
        // Pause
        await _audioPlayer!.pausePlayer();
        AudioPlayerManager().stop(this);
        setState(() {
          _isPlaying = false;
        });
        debugPrint('⏸️ Audio paused');
      } else {
        // Stop any other playing audio
        AudioPlayerManager().play(this);

        // Play
        setState(() {
          _isLoading = true;
        });

        // If at the end, restart from beginning
        if (_currentPosition >= _totalDuration &&
            _totalDuration > Duration.zero) {
          setState(() {
            _currentPosition = Duration.zero;
          });
        }

        debugPrint('▶️ Starting playback: ${widget.message.audioUrl}');

        await _audioPlayer!.startPlayer(
          fromURI: widget.message.audioUrl,
          codec: Codec.aacADTS,
          whenFinished: () {
            if (mounted) {
              setState(() {
                _isPlaying = false;
                _currentPosition = Duration.zero;
              });
              AudioPlayerManager().stop(this);
              debugPrint('✅ Audio finished');
            }
          },
        );

        // Cancel any existing subscription
        await _playerSubscription?.cancel();

        // Subscribe to player progress - THIS IS CRITICAL for animation
        _playerSubscription = _audioPlayer!.onProgress!.listen(
          (event) {
            if (mounted && _isPlaying) {
              setState(() {
                _currentPosition = event.position;
                // Update total duration from actual playback
                if (event.duration > Duration.zero) {
                  _totalDuration = event.duration;
                }
              });
              debugPrint(
                  '🎵 Progress: ${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}');
            }
          },
          onError: (error) {
            debugPrint('❌ Progress stream error: $error');
          },
          cancelOnError: false,
        );

        setState(() {
          _isPlaying = true;
          _isLoading = false;
        });
        debugPrint('✅ Audio playing - subscription active');
      }
    } catch (e) {
      debugPrint('❌ Error playing/pausing audio: $e');
      setState(() {
        _isLoading = false;
        _isPlaying = false;
      });
      AudioPlayerManager().stop(this);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  Future<void> _seekTo(double value) async {
    if (_audioPlayer == null ||
        !_isPlayerInitialized ||
        _totalDuration == Duration.zero) {
      return;
    }

    try {
      final position = Duration(
          milliseconds: (value * _totalDuration.inMilliseconds).toInt());

      await _audioPlayer!.seekToPlayer(position);

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
      debugPrint('⏩ Seeked to: ${_formatDuration(position)}');
    } catch (e) {
      debugPrint('❌ Error seeking: $e');
    }
  }

  double get _progress {
    if (_totalDuration == Duration.zero) return 0.0;
    final progress =
        (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds)
            .clamp(0.0, 1.0);
    return progress;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    AudioPlayerManager().stop(this);
    if (_audioPlayer != null) {
      _audioPlayer!.closePlayer();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = widget.isMe
        ? const Color(0xFFF8B8E3) // sent
        : const Color(0xFFE76B9A); // received

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: _bubblePadding(),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(1, 2),
            )
          ],
        ),
        child: _buildContent(context),
      ),
    );
  }

  EdgeInsets _bubblePadding() {
    switch (widget.message.type) {
      case MessageType.text:
        return const EdgeInsets.symmetric(vertical: 10, horizontal: 14);
      case MessageType.image:
      case MessageType.video:
        return const EdgeInsets.all(6);
      case MessageType.audio:
        return const EdgeInsets.symmetric(vertical: 8, horizontal: 12);
      default:
        return const EdgeInsets.symmetric(vertical: 10, horizontal: 14);
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.message.type) {
      case MessageType.text:
        return _buildTextBubble();

      case MessageType.image:
        return _buildImageBubble();

      case MessageType.video:
        return WhatsAppVideoBubble(
          url: widget.message.videoUrl!,
          isSent: widget.isMe,
        );

      case MessageType.audio:
        return _buildEnhancedAudioBubble();

      default:
        return _buildTextBubble();
    }
  }

  Widget _buildTextBubble() {
    return Text(
      widget.message.text ?? 'No message',
      style: TextStyle(
        color: widget.isMe ? Colors.black87 : Colors.white,
        fontSize: 15,
      ),
    );
  }

  Widget _buildImageBubble() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        widget.message.imageUrl ?? "",
        width: 220,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 220,
            height: 250,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 220,
            height: 250,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedAudioBubble() {
    // Calculate dynamic width based on duration
    double bubbleWidth = 200; // minimum width
    if (_totalDuration.inSeconds > 0) {
      // Add 10 pixels per second, max 280
      bubbleWidth =
          (200 + (_totalDuration.inSeconds * 10)).clamp(200, 280).toDouble();
    }

    // Calculate available width for waveform (subtract button and padding)
    final waveformWidth =
        bubbleWidth - 60; // 40 (button) + 8 (spacing) + 12 (padding)

    return Container(
      constraints: BoxConstraints(minWidth: bubbleWidth, maxWidth: bubbleWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause Button with Loading
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _togglePlayPause,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.isMe
                      ? Colors.white.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: _isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.isMe ? Colors.black87 : Colors.white,
                        ),
                      )
                    : Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: widget.isMe ? Colors.black87 : Colors.white,
                        size: 24,
                      ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Waveform and Progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom Waveform with Progress
                SizedBox(
                  height: 32,
                  child: Stack(
                    children: [
                      // Background waveform (inactive/gray) - All gray bars
                      Positioned.fill(
                        child: CustomPaint(
                          painter: WaveformPainter(
                            progress: 1.0, // Full background
                            color: Colors.grey.shade400,
                            isBackground: true,
                          ),
                        ),
                      ),
                      // Active waveform (follows progress) - Pink color
                      Positioned.fill(
                        child: CustomPaint(
                          painter: WaveformPainter(
                            progress: _progress,
                            color: const Color(0xFFF48BB8),
                            isBackground: false,
                          ),
                        ),
                      ),
                      // Progress dot indicator - moves with playback
                      if (_totalDuration > Duration.zero)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.linear,
                          left: (_progress * waveformWidth)
                              .clamp(0.0, waveformWidth),
                          top: 12,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _isPlaying
                                  ? Colors.white
                                  : const Color(0xFFF48BB8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _isPlaying
                                      ? Colors.white.withOpacity(0.6)
                                      : const Color(0xFFF48BB8)
                                          .withOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Invisible slider for seeking
                      Positioned.fill(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 32,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 0,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                            activeTrackColor: Colors.transparent,
                            inactiveTrackColor: Colors.transparent,
                            thumbColor: Colors.transparent,
                            overlayColor: widget.isMe
                                ? Colors.black87.withOpacity(0.1)
                                : Colors.white.withOpacity(0.1),
                          ),
                          child: Slider(
                            value: _progress,
                            onChanged: (_totalDuration != Duration.zero)
                                ? (value) {
                                    _seekTo(value);
                                  }
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),

                // Duration text - Only show if we have duration
                if (_totalDuration > Duration.zero)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      _isPlaying || _currentPosition > Duration.zero
                          ? '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}'
                          : _formatDuration(_totalDuration),
                      style: TextStyle(
                        color: widget.isMe ? Colors.black54 : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // Microphone icon
          Icon(
            Icons.mic,
            size: 18,
            color: widget.isMe ? Colors.black54 : Colors.white70,
          ),
        ],
      ),
    );
  }
}

// Custom Waveform Painter
class WaveformPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isBackground;

  WaveformPainter({
    required this.progress,
    required this.color,
    required this.isBackground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Generate waveform bars
    const barCount = 40;
    final barWidth = size.width / barCount;
    final centerY = size.height / 2;

    // Predefined heights for a natural waveform look
    final heights = [
      0.3,
      0.5,
      0.7,
      0.9,
      0.6,
      0.8,
      1.0,
      0.7,
      0.5,
      0.6,
      0.8,
      0.9,
      0.7,
      0.5,
      0.6,
      0.8,
      0.9,
      1.0,
      0.8,
      0.6,
      0.7,
      0.9,
      0.8,
      0.6,
      0.5,
      0.7,
      0.9,
      0.8,
      0.6,
      0.5,
      0.7,
      0.8,
      0.9,
      0.7,
      0.6,
      0.5,
      0.7,
      0.8,
      0.6,
      0.4,
    ];

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      final barProgress = i / barCount;

      // Draw all bars for background, or only bars up to progress for active
      if (isBackground || barProgress <= progress) {
        final height = heights[i % heights.length] * size.height * 0.7;

        canvas.drawLine(
          Offset(x, centerY - height / 2),
          Offset(x, centerY + height / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isBackground != isBackground;
  }
}
