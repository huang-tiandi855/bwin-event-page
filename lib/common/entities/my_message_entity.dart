import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/my_message_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class MyMessageEntity {

	bool? hasNext;
	List<MyMessageList>? list;
  
  MyMessageEntity();

  factory MyMessageEntity.fromJson(Map<String, dynamic> json) => $MyMessageEntityFromJson(json);

  Map<String, dynamic> toJson() => $MyMessageEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class MyMessageList {

	String? id;
	int? sendUid;
	String? sendName;
	String? sendAvatar;
	String? sendGender;
	@JSONField(name: "SuperUser")
	int? superUser;
	dynamic awards;
	String? msgType;
	String? content;
	bool? isRead;
	String? objId;
	String? objName;
	String? createdAt;
	String? vipExpireDate;
	int? vipLevel;
  
  MyMessageList();

  factory MyMessageList.fromJson(Map<String, dynamic> json) => $MyMessageListFromJson(json);

  Map<String, dynamic> toJson() => $MyMessageListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}