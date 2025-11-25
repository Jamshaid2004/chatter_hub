class ChatModel {
  
  final String name;
  final String lastMessage;
  final String time;
  final String profilePic;
  final bool isGroup;

  ChatModel({
    
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.profilePic,
    this.isGroup = false,
  });
}