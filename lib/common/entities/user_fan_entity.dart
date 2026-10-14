import 'dart:convert';
import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/user_fan_entity.g.dart';

@JsonSerializable()
class UserFanEntity {

	List<UserFanList>? list;
	bool? hasNext;
  
  UserFanEntity();

  factory UserFanEntity.fromJson(Map<String, dynamic> json) => $UserFanEntityFromJson(json);

  Map<String, dynamic> toJson() => $UserFanEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class UserFanList {

	int? uid;
	String? name;
	String? gender;
	String? portrait;
	bool? hasLocked;
	bool? hasBanned;
	int? vipLevel;
	bool? isVip;
	bool? hasFollow;
	String? via;
	int? fans;
	int? vnum;
	String? summary;
	int? superUser;
	dynamic awards;
	String? createdAt;
  
  UserFanList();

  factory UserFanList.fromJson(Map<String, dynamic> json) => $UserFanListFromJson(json);

  Map<String, dynamic> toJson() => $UserFanListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}