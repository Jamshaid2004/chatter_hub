import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  final String statusId;
  final String userId;
  final String userName;
  final String userProfilePic;
  final List<StatusItemModel> statusItems;
  final Timestamp createdAt;

  StatusModel({
    required this.statusId,
    required this.userId,
    required this.userName,
    required this.userProfilePic,
    required this.statusItems,
    required this.createdAt,
  });

  factory StatusModel.fromMap(Map<String, dynamic> map) {
    return StatusModel(
      statusId: map['statusId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userProfilePic: map['userProfilePic'] ?? '',
      statusItems: (map['statusItems'] as List<dynamic>?)
              ?.map((item) =>
                  StatusItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'statusId': statusId,
      'userId': userId,
      'userName': userName,
      'userProfilePic': userProfilePic,
      'statusItems': statusItems.map((item) => item.toMap()).toList(),
      'createdAt': createdAt,
    };
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final statusTime = createdAt.toDate();
    final difference = now.difference(statusTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Check if status is expired (older than 24 hours)
  bool get isExpired {
    final now = DateTime.now();
    final statusTime = createdAt.toDate();
    final difference = now.difference(statusTime);
    return difference.inHours >= 24;
  }

  // Get count of unviewed status items for a user
  int getUnviewedCount(String currentUserId) {
    return statusItems
        .where((item) => !item.viewedBy.contains(currentUserId))
        .length;
  }

  // Check if all items are viewed by user
  bool isViewedByUser(String userId) {
    return statusItems.every((item) => item.viewedBy.contains(userId));
  }
}

class StatusItemModel {
  final String itemId;
  final String imageUrl;
  final Timestamp uploadedAt;
  final List<String> viewedBy;

  StatusItemModel({
    required this.itemId,
    required this.imageUrl,
    required this.uploadedAt,
    this.viewedBy = const [],
  });

  factory StatusItemModel.fromMap(Map<String, dynamic> map) {
    return StatusItemModel(
      itemId: map['itemId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      uploadedAt: map['uploadedAt'] ?? Timestamp.now(),
      viewedBy: List<String>.from(map['viewedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'imageUrl': imageUrl,
      'uploadedAt': uploadedAt,
      'viewedBy': viewedBy,
    };
  }
}
