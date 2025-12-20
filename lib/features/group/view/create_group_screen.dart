import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/group/view_model/create_group_view_model.dart';
import 'package:flutter_chatter_hub/features/profile_info/model/profile_model.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateGroupViewModel()..init(),
      child: Consumer<CreateGroupViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFFF48BB8),
              title: const Text(
                'Create Group',
                style: TextStyle(
                  color: Color.fromARGB(255, 187, 52, 97),
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color.fromARGB(255, 187, 52, 97),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                // Group Name Input Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Group Icon
                      GestureDetector(
                        onTap: () => viewModel.pickGroupIcon(context),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: const Color(0xFFF48BB8),
                              backgroundImage: viewModel.groupIconPath != null
                                  ? FileImage(viewModel.groupIconPath!)
                                  : null,
                              child: viewModel.groupIconPath == null
                                  ? const Icon(
                                      Icons.group,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 187, 52, 97),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Group Name Input
                      Expanded(
                        child: TextField(
                          controller: viewModel.groupNameController,
                          decoration: InputDecoration(
                            hintText: 'Group name',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          onChanged: (_) => viewModel.notifyListeners(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selected Members Count
                ValueListenableBuilder<List<ProfileModel>>(
                  valueListenable: viewModel.selectedUsers,
                  builder: (context, selected, _) {
                    if (selected.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: const Color(0xFFFDE7F3),
                      child: Row(
                        children: [
                          Text(
                            '${selected.length} member${selected.length > 1 ? 's' : ''} selected',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 187, 52, 97),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (selected.length >= 2)
                            TextButton.icon(
                              onPressed: () => viewModel.createGroup(context),
                              icon: const Icon(
                                Icons.check,
                                color: Color.fromARGB(255, 187, 52, 97),
                              ),
                              label: const Text(
                                'Create',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 187, 52, 97),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                // Selected Members Preview
                ValueListenableBuilder<List<ProfileModel>>(
                  valueListenable: viewModel.selectedUsers,
                  builder: (context, selected, _) {
                    if (selected.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: selected.length,
                        itemBuilder: (context, index) {
                          final user = selected[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage:
                                          user.profilePic!.isNotEmpty
                                              ? NetworkImage(user.profilePic!)
                                              : null,
                                      child: user.profilePic!.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () =>
                                            viewModel.toggleUserSelection(user),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 70, // give it a bit more air
                                  child: Text(
                                    user.userName,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      height: 1.1,
                                    ),
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

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: viewModel.searchController,
                    onChanged: viewModel.searchUsers,
                    decoration: InputDecoration(
                      hintText: 'Search users',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color.fromARGB(255, 187, 52, 97),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Users List
                Expanded(
                  child: StreamBuilder<List<ProfileModel>>(
                    stream: viewModel.listenToUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.pinkAccent,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final users = viewModel.filteredUsers.isNotEmpty
                          ? viewModel.filteredUsers
                          : (snapshot.data ?? []);

                      if (users.isEmpty) {
                        return const Center(
                          child: Text(
                            'No users found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ValueListenableBuilder<List<ProfileModel>>(
                            valueListenable: viewModel.selectedUsers,
                            builder: (context, selected, _) {
                              final isSelected =
                                  selected.any((u) => u.uid == user.uid);

                              return Container(
                                color:
                                    isSelected ? const Color(0xFFFDE7F3) : null,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundImage: user.profilePic!.isNotEmpty
                                        ? NetworkImage(user.profilePic!)
                                        : null,
                                    child: user.profilePic!.isEmpty
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  title: Text(
                                    user.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(user.userName),
                                  trailing: Checkbox(
                                    value: isSelected,
                                    onChanged: (_) =>
                                        viewModel.toggleUserSelection(user),
                                    activeColor:
                                        const Color.fromARGB(255, 187, 52, 97),
                                  ),
                                  onTap: () =>
                                      viewModel.toggleUserSelection(user),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
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
