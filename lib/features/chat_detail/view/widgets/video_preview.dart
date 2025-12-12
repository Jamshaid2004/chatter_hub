import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WhatsAppVideoBubble extends StatefulWidget {
  final String url;
  final bool isSent; // true → right bubble, false → left bubble

  const WhatsAppVideoBubble({
    super.key,
    required this.url,
    required this.isSent,
  });

  @override
  State<WhatsAppVideoBubble> createState() => _WhatsAppVideoBubbleState();
}

class _WhatsAppVideoBubbleState extends State<WhatsAppVideoBubble> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true)
      ..pause();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      debugPrint('Video playing pausing it');
      _controller.pause();
      setState(() => _isPlaying = false);
    } else {
      debugPrint('Video not playing, playing it');
      _controller.play();
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = widget.isSent ? const Color(0xFFF8B8E3) : const Color(0xFFE76B9A);

    return Container(
      width: 230,
      height: 260,
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
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Video
            Positioned.fill(
              child: _controller.value.isInitialized
                  ? GestureDetector(
                      onTap: _togglePlay,
                      child: VideoPlayer(_controller),
                    )
                  : Container(color: Colors.black26),
            ),

            // Overlay (visible when paused)
            if (!_isPlaying)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: 0.4,
                  duration: const Duration(milliseconds: 200),
                  child: Container(color: Colors.black),
                ),
              ),

            // Play button (visible when paused)
            if (!_isPlaying)
              Center(
                child: AnimatedScale(
                  scale: 1,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                    child: GestureDetector(
                      onTap: _togglePlay,
                      child: const Icon(
                        Icons.play_arrow,
                        size: 32,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
