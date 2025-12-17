// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usernote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserNote _$UserNoteFromJson(Map<String, dynamic> json) => UserNote(
  userId: (json['user_id'] as num).toInt(),
  text: json['text'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserNoteToJson(UserNote instance) => <String, dynamic>{
  'user_id': instance.userId,
  'text': instance.text,
};
