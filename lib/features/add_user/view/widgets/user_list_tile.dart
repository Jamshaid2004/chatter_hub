import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/config/router.dart';
import 'package:flutter_chatter_hub/core/constants/app_routes_name.dart';
import 'package:flutter_chatter_hub/core/injector/injector.dart';
import 'package:flutter_chatter_hub/features/profile_info/model/profile_model.dart';
import 'package:go_router/go_router.dart';

class UserListTile extends StatelessWidget {
  const UserListTile({super.key, required this.user});
  final ProfileModel user;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context.push(injector<AppRoutesName>().chatDetailScreen,
            extra: ChatDetailScreenInputParams(pfp: user.profilePic, name: user.userName, userId: user.uid));
      },
      leading: CircleAvatar(
        backgroundImage: user.profilePic != null ? NetworkImage(user.profilePic!) : null,
        backgroundColor: Colors.grey[300],
        child: user.profilePic == null ? const Icon(Icons.person, size: 30, color: Colors.white) : null,
      ),
      title: Text(
        user.userName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
