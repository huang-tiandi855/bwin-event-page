import 'dart:convert';
import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/comment_info_entity.g.dart';

@JsonSerializable()
class CommentInfoEntity {

	int? total;
	bool? hasNext;
	List<CommentInfoList>? list;
  
  CommentInfoEntity();

  factory CommentInfoEntity.fromJson(Map<String, dynamic> json) => $CommentInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => $CommentInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class CommentInfoList {

	String? id;
	String? objID;
	String? cid;
	int? userID;
	String? userName;
	String? userPortrait;
	int? toUserID;
	String? toUserName;
	String? content;
	int? likeCount;
	bool? isLike;
	bool? isAuthor;
	bool? isFollow;
	bool? isDelete;
	String? gender;
	int? status;
	String? city;
	String? createdAt;
	int? age;
	int? level;
	int? vipLevel;
	dynamic awards;
	int? superUser;
	String? vipExpireDate;
  
  CommentInfoList();

  factory CommentInfoList.fromJson(Map<String, dynamic> json) => $CommentInfoListFromJson(json);

  Map<String, dynamic> toJson() => $CommentInfoListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}