// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String?,
  avatarId: (json['avatar_id'] as num?)?.toInt(),
  role: json['role'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'avatar_id': instance.avatarId,
  'role': instance.role,
};

UserPatch _$UserPatchFromJson(Map<String, dynamic> json) => UserPatch(
  username: json['username'] as String?,
  password: json['password'] as String?,
  email: json['email'] as String?,
  avatarId: (json['avatar_id'] as num?)?.toInt(),
  role: json['role'] as String?,
);

Map<String, dynamic> _$UserPatchToJson(UserPatch instance) => <String, dynamic>{
  'username': ?instance.username,
  'password': ?instance.password,
  'email': ?instance.email,
  'avatar_id': ?instance.avatarId,
  'role': ?instance.role,
};
