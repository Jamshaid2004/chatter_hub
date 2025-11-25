class CallModel {
  final String name;
  final String profilePic;
  final String time;
  final bool isIncoming; 
  final bool isMissed;
  final int count; // number of calls 

  CallModel({
    required this.name,
    required this.profilePic,
    required this.time,
    this.isIncoming = true,
    this.isMissed = false,
    this.count = 1,
  });
}
