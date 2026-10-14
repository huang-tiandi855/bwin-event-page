import 'dart:convert';
import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/media_info_entity.g.dart';

@JsonSerializable()
class MediaInfoEntity {
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
  int? permission;
  String? createdAt;
  String? updatedAt;
  List<MediaInfoContents>? contents;
  bool? hasLiked;
  bool? hasPaid;
  bool? hasCollected;

  int? countComment;
  int? collects;

  MediaInfoEntity();

  factory MediaInfoEntity.fromJson(Map<String, dynamic> json) =>
      $MediaInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => $MediaInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class MediaInfoContents {
  String? id;
  String? mediaID;
  int? episodeNumber;
  int? listenPermission;
  int? price;
  String? name;
  String? text;
  String? md5;
  String? videoUrl;
  List? urlSet;
  int? height;
  int? weight;
  int? mediaSize;
  int? playTime;
  int? status;
  bool? isActive;
  bool? hasPaid;

  MediaInfoContents();

  factory MediaInfoContents.fromJson(Map<String, dynamic> json) =>
      $MediaInfoContentsFromJson(json);

  Map<String, dynamic> toJson() => $MediaInfoContentsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
