import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/core/services/db/db_local_service.dart';
import 'package:flutter_chatter_hub/features/status/model/status_model.dart';
import 'package:flutter_chatter_hub/features/status/screen/status_view_screen.dart';

class MyStatusTile extends StatelessWidget {
  final StatusModel? myStatus;
  final VoidCallback onTap;

  const MyStatusTile({
    super.key,
    this.myStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasStatus = myStatus != null &&
        myStatus!.statusItems.isNotEmpty &&
        !myStatus!.isExpired;

    final userProfilePic = injector<SharedPref>().getValue('profilePic') ?? '';
    final userName = injector<SharedPref>().getValue('name') ?? 'My Status';

    return InkWell(
      onTap: () {
        if (hasStatus) {
          // View my status
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StatusViewScreen(
                status: myStatus!,
                isMyStatus: true,
              ),
            ),
          );
        } else {
          // Upload new status
          onTap();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color.fromARGB(50, 187, 52, 97),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasStatus
                          ? const Color.fromARGB(255, 187, 52, 97)
                          : Colors.grey,
                      width: 2.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: userProfilePic.isNotEmpty
                        ? NetworkImage(userProfilePic)
                        : null,
                    child: userProfilePic.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 187, 52, 97),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasStatus ? Icons.visibility : Icons.add,
                      color: Colors.white,
                      size: 16,
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
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasStatus
                        ? 'Tap to view • ${myStatus!.timeAgo}'
                        : 'Tap to add status',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (hasStatus)
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
