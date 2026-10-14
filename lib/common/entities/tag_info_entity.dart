import 'dart:convert';
import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/tag_info_entity.g.dart';

@JsonSerializable()
class TagInfoEntity {

	String? id;
	String? name;
	String? coverImg;
	String? backgroundImg;
	String? tagDesc;
	String? description;
	bool? hasCollected;
	int? playCount;
  
  TagInfoEntity();

  factory TagInfoEntity.fromJson(Map<String, dynamic> json) => $TagInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => $TagInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}