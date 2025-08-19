import 'package:daylit/util/Daylit_Social.dart';

import '../util/DateTime_Utils.dart';

// 수정된 UserModel
class UserModel {
  final String uid;
  final String? id;
  final Social socialType;
  final String? profileUrl;
  final String email;
  final DateTime? lastLogin;
  final String? gender;
  final int level;
  final DateTime createAt;

  UserModel({
    required this.uid,
    this.id,
    required this.socialType,
    required this.email,
    this.lastLogin,
    this.gender,
    this.profileUrl,
    required this.createAt,
    required this.level
  });

  // fromJson - UTC 문자열을 로컬 시간으로 변환
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        uid: json['uid'] ?? '',
        id: json['id'],
        socialType: toSocial(json['socialType']),
        email: json['email'] ?? '',
        lastLogin: DateTimeUtils.fromUtcString(json['lastLogin']),
        gender: json['gender'],
        createAt: DateTimeUtils.fromUtcString(json['createAt']) ?? DateTime.now(),
        level: json['level'] ?? 1,
        profileUrl: json['profileUrl']
    );
  }

  // toMap - 로컬 시간을 UTC 문자열로 변환
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'id': id,
      'socialType': socialType.value,
      'email': email,
      'lastLogin': lastLogin != null ? DateTimeUtils.toUtcString(lastLogin!) : null,
      'gender': gender,
      'createAt': DateTimeUtils.toUtcString(createAt),
      'level': level,
      'profileUrl' : profileUrl
    };
  }

  // 나머지 메서드들...
  factory UserModel.empty() {
    return UserModel(
        uid: '',
        socialType: Social.kakao,
        email: '',
        createAt: DateTime.now(),
        level: 1,
        profileUrl: null
    );
  }

  UserModel copyWith({
    String? uid,
    String? id,
    Social? socialType,
    String? email,
    DateTime? lastLogin,
    String? gender,
    int? level,
    DateTime? createAt,
    String? profileUrl
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      socialType: socialType ?? this.socialType,
      email: email ?? this.email,
      lastLogin: lastLogin ?? this.lastLogin,
      gender: gender ?? this.gender,
      level: level ?? this.level,
      createAt: createAt ?? this.createAt,
      profileUrl: profileUrl
    );
  }

  // 유틸리티 메서드들
  bool get isEmpty => uid.isEmpty;
  bool get isLoggedIn => uid.isNotEmpty;
  bool get hasNickname => id != null && id!.isNotEmpty;
  bool get hasGender => gender != null && gender!.isNotEmpty;
  int get daysSinceJoined => DateTime.now().difference(createAt).inDays;
  int get daysSinceLastLogin => lastLogin != null ? DateTime.now().difference(lastLogin!).inDays : -1;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'UserModel{uid: $uid, id: $id, email: $email, level: $level}';
  }

  static Social toSocial(String? type) {
    switch (type) {
      case 'kakao':
        return Social.kakao;
      case 'google':
        return Social.google;
      case 'apple':
        return Social.apple;
      case 'discord':
        return Social.discord;
      default:
        return Social.kakao;
    }
  }
}