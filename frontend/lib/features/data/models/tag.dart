import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable()
class Tag {
  int id;
  String name;

  Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);

  @override
  bool operator ==(Object other) {
    if (other is! Tag) return false;

    return id == other.id && name == other.name;
  }

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => "Tag(id=$id, name=$name)";
}
