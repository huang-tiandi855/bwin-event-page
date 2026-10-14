import 'dart:convert';
import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/media_list_entity.g.dart';

@JsonSerializable()
class MediaListEntity {

	@JSONField(name: "MediaList")
	List<MediaListMediaList>? mediaList;
	bool? hasNext;
  
  MediaListEntity();

  factory MediaListEntity.fromJson(Map<String, dynamic> json) => $MediaListEntityFromJson(json);

  Map<String, dynamic> toJson() => $MediaListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class MediaListMediaList {

	String? id;
	String? title;
	String? horizontalCover;
	String? verticalCover;
	List<String>? tags;
	List<String>? tagNames;
	String? summary;
	int? totalEpisode;
	String? mediaType;
	int? kind;
	int? price;
	int? permission;
	int? direction;
	int? sellType;
	String? general;
	int? generalSort;
	String? choice;
	int? choiceSort;
	bool? isActive;
	int? countPurchases;
	int? countBrowse;
	int? countCollect;
	int? countLike;
	int? number;
	String? createdAt;
	String? updatedAt;

	int? updateStatus;
	String? updatedDesc;
  
  MediaListMediaList();

  factory MediaListMediaList.fromJson(Map<String, dynamic> json) => $MediaListMediaListFromJson(json);

  Map<String, dynamic> toJson() => $MediaListMediaListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}