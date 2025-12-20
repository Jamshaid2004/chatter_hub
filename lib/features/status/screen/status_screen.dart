import 'package:flutter/material.dart';
import 'package:flutter_chatter_hub/features/status/model/status_model.dart';
import 'package:flutter_chatter_hub/features/status/model/status_view_model.dart';

import 'package:flutter_chatter_hub/features/status/widgets/my_status_tile.dart';
import 'package:flutter_chatter_hub/features/status/widgets/user_status_tile.dart';
import 'package:provider/provider.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StatusViewModel(),
      child: Consumer<StatusViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFFF48BB8),
              title: const Text(
                "Status",
                style: TextStyle(
                  color: Color.fromARGB(255, 187, 52, 97),
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(
                color: Color.fromARGB(255, 187, 52, 97),
              ),
            ),
            body: Column(
              children: [
                // My Status Section - Always visible, loads independently
                StreamBuilder<List<StatusModel>>(
                  stream: viewModel.listenToStatuses(),
                  builder: (context, snapshot) {
                    // Show my status immediately, even if loading
                    return MyStatusTile(
                      myStatus: viewModel.myStatus,
                      onTap: () => viewModel.uploadStatus(context),
                    );
                  },
                ),

                // Other Users' Statuses Section
                Expanded(
                  child: StreamBuilder<List<StatusModel>>(
                    stream: viewModel.listenToStatuses(),
                    builder: (context, snapshot) {
                      // Show loading only for other statuses
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.pinkAccent,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading statuses',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${snapshot.error}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      final otherStatuses = snapshot.data ?? [];

                      return Column(
                        children: [
                          // Recent Updates Header
                          if (otherStatuses.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Recent Updates",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 187, 52, 97),
                                  ),
                                ),
                              ),
                            ),

                          // Other Users' Statuses List
                          Expanded(
                            child: otherStatuses.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.update,
                                          size: 60,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No status updates yet',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Status updates from your contacts will appear here',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: otherStatuses.length,
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final status = otherStatuses[index];
                                      return UserStatusTile(
                                        status: status,
                                        viewModel: viewModel,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Uploading indicator - Shows at bottom when uploading
                ValueListenableBuilder<bool>(
                  valueListenable: viewModel.isUploading,
                  builder: (context, isUploading, _) {
                    if (!isUploading) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 187, 52, 97),
                            Color.fromARGB(255, 230, 136, 167),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Uploading status...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
