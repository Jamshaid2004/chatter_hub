// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ProfileModel {
  final String uid;
  final String userName;
  final String? profilePic;
  final String phoneNumber;
  ProfileModel({
    required this.uid,
    required this.userName,
    this.profilePic,
    required this.phoneNumber,
  });

  ProfileModel copyWith({
    String? uid,
    String? userName,
    String? profilePic,
    String? phoneNumber,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      userName: userName ?? this.userName,
      profilePic: profilePic ?? this.profilePic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'userName': userName,
      'profilePic': profilePic,
      'phoneNumber': phoneNumber,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      uid: map['uid'] as String,
      userName: map['userName'] as String,
      profilePic: map['profilePic'] != null ? map['profilePic'] as String : null,
      phoneNumber: map['phoneNumber'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileModel.fromJson(String source) => ProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProfileModel(uid: $uid, userName: $userName, profilePic: $profilePic, phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(covariant ProfileModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid && other.userName == userName && other.profilePic == profilePic && other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ userName.hashCode ^ profilePic.hashCode ^ phoneNumber.hashCode;
  }
}
