import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/features/status/model/status_model.dart';
import 'package:flutter_chatter_hub/features/status/model/status_view_model.dart';
import 'package:flutter_chatter_hub/features/status/screen/status_view_screen.dart';

class UserStatusTile extends StatelessWidget {
  final StatusModel status;
  final StatusViewModel viewModel;

  const UserStatusTile({
    super.key,
    required this.status,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = injector<SharedPref>().getValue('uid') ?? '';
    final isViewed = status.isViewedByUser(currentUserId);
    final unviewedCount = status.getUnviewedCount(currentUserId);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StatusViewScreen(
              status: status,
              isMyStatus: false,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isViewed
                          ? Colors.grey
                          : const Color.fromARGB(255, 187, 52, 97),
                      width: 2.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: status.userProfilePic.isNotEmpty
                        ? NetworkImage(status.userProfilePic)
                        : null,
                    child: status.userProfilePic.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                ),
                if (!isViewed && unviewedCount > 0)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 187, 52, 97),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unviewedCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.timeAgo,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
