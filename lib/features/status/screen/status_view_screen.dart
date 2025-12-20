import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/core/services/db/db_remote_service.dart';
import 'package:flutter_chatter_hub/features/status/model/status_model.dart';

class StatusViewScreen extends StatefulWidget {
  final StatusModel status;
  final bool isMyStatus;

  const StatusViewScreen({
    super.key,
    required this.status,
    required this.isMyStatus,
  });

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _startProgress();
    _markCurrentAsViewed();
  }

  void _startProgress() {
    _progressController.forward().then((_) {
      _nextStatus();
    });
  }

  void _nextStatus() {
    if (_currentIndex < widget.status.statusItems.length - 1) {
      setState(() {
        _currentIndex++;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _progressController.reset();
        _startProgress();
        _markCurrentAsViewed();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStatus() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _progressController.reset();
        _startProgress();
      });
    }
  }

  void _pauseProgress() {
    _progressController.stop();
  }

  void _resumeProgress() {
    _progressController.forward();
  }

  void _markCurrentAsViewed() {
    if (!widget.isMyStatus) {
      final currentItem = widget.status.statusItems[_currentIndex];
      injector<FirebaseFirestoreService>().markStatusItemAsViewed(
        widget.status.statusId,
        currentItem.itemId,
        injector<SharedPref>().getValue('uid')!,
      );
    }
  }

  Future<void> _deleteStatus(String itemId) async {
    try {
      await injector<FirebaseFirestoreService>()
          .deleteStatusItem(widget.status.statusId, itemId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status deleted'),
            backgroundColor: Colors.green,
          ),
        );

        // If this was the last item, go back
        if (widget.status.statusItems.length == 1) {
          Navigator.pop(context);
        } else {
          // Move to next or previous status
          if (_currentIndex >= widget.status.statusItems.length - 1) {
            _previousStatus();
          } else {
            _nextStatus();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog() {
    _pauseProgress();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Status'),
        content: const Text('Are you sure you want to delete this status?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeProgress();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final itemId = widget.status.statusItems[_currentIndex].itemId;
              _deleteStatus(itemId);
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

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 2) {
            _previousStatus();
          } else {
            _nextStatus();
          }
        },
        onLongPressStart: (_) => _pauseProgress(),
        onLongPressEnd: (_) => _resumeProgress(),
        child: Stack(
          children: [
            // Status Image
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.status.statusItems.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final item = widget.status.statusItems[index];
                return Center(
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 50,
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Progress Indicators & Header
            SafeArea(
              child: Column(
                children: [
                  // Progress bars
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: Row(
                      children: List.generate(
                        widget.status.statusItems.length,
                        (index) => Expanded(
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: index < _currentIndex
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  )
                                : index == _currentIndex
                                    ? AnimatedBuilder(
                                        animation: _progressController,
                                        builder: (context, child) {
                                          return LinearProgressIndicator(
                                            value: _progressController.value,
                                            backgroundColor: Colors.transparent,
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          );
                                        },
                                      )
                                    : const SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              widget.status.userProfilePic.isNotEmpty
                                  ? NetworkImage(widget.status.userProfilePic)
                                  : null,
                          child: widget.status.userProfilePic.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.status.userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.status.statusItems[_currentIndex]
                                    .uploadedAt
                                    .toDate()
                                    .toString()
                                    .substring(0, 16),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.isMyStatus)
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            onPressed: _showDeleteDialog,
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Viewing info (for my status)
            if (widget.isMyStatus)
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.status.statusItems[_currentIndex].viewedBy.length} views',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
