import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/add_user/view/widgets/user_list_tile.dart';
import 'package:flutter_chatter_hub/features/add_user/view_model/add_user_view_model.dart';
import 'package:provider/provider.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddUserViewModel()..init(),
      builder: (_, __) => Consumer<AddUserViewModel>(
        builder: (_, viewModel, __) => Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFFF48BB8),
              title: TextField(
                onChanged: (value) => viewModel.searchUsers(value),
                controller: viewModel.searchController,
                style: const TextStyle(
                  color: Color.fromARGB(226, 162, 55, 91),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                cursorColor: const Color.fromARGB(226, 162, 55, 91),
                decoration: InputDecoration(
                  hintText: "Search Users",
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(226, 162, 55, 91),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Color.fromARGB(226, 162, 55, 91), size: 20),
                    onPressed: () {
                      viewModel.searchController.clear();
                      viewModel.searchUsers('');
                    },
                  ),
                ),
              ),
            ),
            body: ValueListenableBuilder(
              valueListenable: viewModel.filteredUsers,
              builder: (__, users, _) => ListView.separated(
                  itemBuilder: (context, index) => UserListTile(user: users[index]),
                  separatorBuilder: (context, index) => const Divider(
                        color: Color.fromARGB(255, 255, 145, 183),
                        indent: 30,
                        endIndent: 30,
                        thickness: 1.5,
                      ),
                  itemCount: users.length),
            )),
      ),
    );
  }
}
