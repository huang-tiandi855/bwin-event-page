// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:comics_app/common/entities/video_model/video_model.dart';

class AllTagModel {
  String? coverImg;
  String? hotMark;
  String? id;
  String? tagName;
  int? videoCount;

  /// 针对圈子新增字段 1 是普通圈子 2 楼凤 3nut分享 原味店铺 4动漫acg
  int? type;
  List<VideoModel> allVideoInfo;

  AllTagModel({
    this.coverImg,
    this.hotMark,
    this.id,
    this.tagName,
    this.videoCount,
    this.type,
    this.allVideoInfo = const [],
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'coverImg': coverImg,
      'hotMark': hotMark,
      'id': id,
      'tagName': tagName,
      'videoCount': videoCount,
      'type': type,
      'allVideoInfo': allVideoInfo.map((x) => x.toJson()).toList(),
    };
  }

  factory AllTagModel.fromJson(Map<String, dynamic> map) {
    return AllTagModel(
      coverImg: map['coverImg'] as String?,
      hotMark: map['hotMark'] as String?,
      id: map['id'] as String?,
      tagName: map['tagName'] as String?,
      videoCount: map['videoCount'] as int?,
      type: map['type'] as int?,
      allVideoInfo: (map['allVideoInfo'] as List<dynamic>?)
              ?.map((e) => VideoModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
