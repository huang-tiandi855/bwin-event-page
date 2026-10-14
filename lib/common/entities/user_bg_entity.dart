import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/user_bg_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class UserBgEntity {

	List<UserBgList>? list;
	int? total;
  
  UserBgEntity();

  factory UserBgEntity.fromJson(Map<String, dynamic> json) => $UserBgEntityFromJson(json);

  Map<String, dynamic> toJson() => $UserBgEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class UserBgList {

	String? id;
	String? resource;
	String? type;
	String? updatedAt;
  
  UserBgList();

  factory UserBgList.fromJson(Map<String, dynamic> json) => $UserBgListFromJson(json);

  Map<String, dynamic> toJson() => $UserBgListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}