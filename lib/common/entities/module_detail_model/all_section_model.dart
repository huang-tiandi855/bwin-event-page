// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';

import 'all_media_info_model.dart';
import 'all_media_rank_model.dart';
import 'all_tag_model.dart';

class AllSectionModel {
  List<AllMediaInfoModel> allMediaInfo;
  List<AllTagModel> allTags;
  List<VideoModel> allVideoInfo;
  List<AllMediaRankModel> allRankInfo;
  List<AdsInfoList>? adsInfoArr;

  bool get isNotEmpty {
    return allMediaInfo.isNotEmpty == true || allTags.isNotEmpty == true || allVideoInfo.isNotEmpty == true;
  }

  int? disVoteCount;
  bool? isFree;

  /// 1:外部链接
  ///
  /// 2:内部链接
  int? linkType;
  String? linkUrl;
  List<String>? lotteryRecords;
  String? sectionCover;
  String? sectionId;
  String? sectionName;
  String? sectionDesc;

  int? showType;
  int? type;
  int? voteCount;

  bool isAd;

  bool isAdsArr() {
    return adsInfoArr != null;
  }

  @override
  String toString() {
    return 'AllSectionModel{allMediaInfo: $allMediaInfo, allTags: $allTags, allVideoInfo: $allVideoInfo, allRankInfo: $allRankInfo, adsInfoArr: $adsInfoArr, disVoteCount: $disVoteCount, isFree: $isFree, linkType: $linkType, linkUrl: $linkUrl, lotteryRecords: $lotteryRecords, sectionCover: $sectionCover, sectionId: $sectionId, sectionName: $sectionName, sectionDesc: $sectionDesc, showType: $showType, type: $type, voteCount: $voteCount, isAd: $isAd}';
  }

  AllSectionModel({
    this.allMediaInfo = const [],
    this.allTags = const [],
    this.allVideoInfo = const [],
    this.disVoteCount,
    this.isFree,
    this.linkType,
    this.linkUrl,
    this.sectionCover,
    this.sectionId,
    this.sectionName,
    this.sectionDesc,
    this.showType,
    this.type,
    this.voteCount,
    this.lotteryRecords,
    this.adsInfoArr,
    this.allRankInfo = const [],
    this.isAd = false,
  });

  factory AllSectionModel.ad({
    required String? sectionId,
    required String? sectionCover,
    required String? sectionName,
    required String? linkUrl,
  }) {
    return AllSectionModel(
      isAd: true,
      sectionId: sectionId,
      sectionCover: sectionCover,
      sectionName: sectionName,
      linkUrl: linkUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'allMediaInfo': allMediaInfo.map((x) => x.toJson()).toList(),
      'allTags': allTags.map((x) => x.toJson()).toList(),
      'allVideoInfo': allVideoInfo.map((x) => x.toJson()).toList(),
      'disVoteCount': disVoteCount,
      'isFree': isFree,
      'linkType': linkType,
      'linkUrl': linkUrl,
      'lotteryRecords': lotteryRecords,
      'sectionCover': sectionCover,
      'sectionId': sectionId,
      'sectionName': sectionName,
      'sectionDesc': sectionDesc,
      'showType': showType,
      'type': type,
      'voteCount': voteCount,
      'allRankings': allRankInfo.map((e) => e.toJson()).toList()
    };
  }

  factory AllSectionModel.fromJson(Map<String, dynamic> map) {
    return AllSectionModel(
      allMediaInfo: (map['allMediaInfo'] as List<dynamic>?)?.map((e) => AllMediaInfoModel.fromJson(e)).toList() ?? [],
      allTags: (map['allTags'] as List<dynamic>?)?.map((e) => AllTagModel.fromJson(e)).toList() ?? [],
      allVideoInfo: (map['allVideoInfo'] as List<dynamic>?)?.map((e) => VideoModel.fromJson(e)).toList() ?? [],
      disVoteCount: map['disVoteCount'] as int?,
      isFree: map['isFree'] as bool?,
      linkType: map['linkType'] as int?,
      linkUrl: map['linkUrl'] as String?,
      lotteryRecords: map['lotteryRecords'] != null ? List<String>.from((map['lotteryRecords'] as List)) : null,
      sectionCover: map['sectionCover'] as String?,
      sectionId: map['sectionID'] as String?,
      sectionName: map['sectionName'] as String?,
      sectionDesc: map['sectionDesc'] as String?,
      showType: map['showType'] as int?,
      type: map['type'] as int?,
      voteCount: map['voteCount'] as int?,
      allRankInfo: (map['allRankings'] as List<dynamic>?)?.map((e) => AllMediaRankModel.fromJson(e)).toList() ?? [],
    );
  }
}
