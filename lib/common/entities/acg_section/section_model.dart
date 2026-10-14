import 'package:comics_app/common/entities/acg_section/se.dart';

import '../module_detail_model/all_media_info_model.dart';

import 'package:comics_app/common/utils/logger.dart';

class SectionModel {
  SectionModel({
    this.section,
    this.mediaList,
    this.hasNext,
  });

  SectionModel.fromJson(dynamic json) {
    section = json['section'] != null ? Se.fromJson(json['section']) : null;

    if (json['list'] != null) {
      mediaList = [];
      json['list'].forEach((v) {
        mediaList?.add(AllMediaInfoModel.fromJson(v));
      });
    }
    hasNext = json['hasNext'];
  }
  Se? section;
  List<AllMediaInfoModel>? mediaList;
  bool? hasNext;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (section != null) {
      map['Section'] = section?.toJson();
    }
    if (mediaList != null) {
      map['mediaList'] = mediaList?.map((v) => v.toJson()).toList();
    }
    map['hasNext'] = hasNext;
    return map;
  }
}

// class MediaList {
//   MediaList({
//       this.id,
//       this.title,
//       this.horizontalCover,
//       this.verticalCover,
//       this.tags,
//       this.tagNames,
//       this.sellTypeHide,
//       this.summary,
//       this.totalEpisode,
//       this.mediaType,
//       this.kind,
//       this.price,
//       this.direction,
//       this.sellType,
//       this.permission,
//       this.general,
//       this.generalSort,
//       this.choice,
//       this.choiceSort,
//       this.section,
//       this.sectionSort,
//       this.originalSort,
//       this.originalButtonSort,
//       this.isActive,
//       this.countPurchases,
//       this.countBrowse,
//       this.countCollect,
//       this.countLike,
//       this.countComment,
//       this.number,
//       this.updateStatus,
//       this.updatedDesc,
//       this.createdAt,
//       this.updatedAt,});
//
//   MediaList.fromJson(dynamic json) {
//     id = json['id'];
//     title = json['title'];
//     horizontalCover = json['horizontalCover'];
//     verticalCover = json['verticalCover'];
//     tags = json['tags'] != null ? json['tags'].cast<String>() : [];
//     tagNames = json['tagNames'] != null ? json['tagNames'].cast<String>() : [];
//     sellTypeHide = json['sellTypeHide'];
//     summary = json['summary'];
//     totalEpisode = json['totalEpisode'];
//     mediaType = json['mediaType'];
//     kind = json['kind'];
//     price = json['price'];
//     direction = json['direction'];
//     sellType = json['sellType'];
//     permission = json['permission'];
//     general = json['general'];
//     generalSort = json['generalSort'];
//     choice = json['choice'];
//     choiceSort = json['choiceSort'];
//     section = json['section'];
//     sectionSort = json['sectionSort'];
//     originalSort = json['originalSort'];
//     originalButtonSort = json['originalButtonSort'];
//     isActive = json['isActive'];
//     countPurchases = json['countPurchases'];
//     countBrowse = json['countBrowse'];
//     countCollect = json['countCollect'];
//     countLike = json['countLike'];
//     countComment = json['countComment'];
//     number = json['number'];
//     updateStatus = json['updateStatus'];
//     updatedDesc = json['updatedDesc'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//   }
//   String? id;
//   String? title;
//   String? horizontalCover;
//   String? verticalCover;
//   List<String>? tags;
//   List<String>? tagNames;
//   bool? sellTypeHide;
//   String? summary;
//   num? totalEpisode;
//   String? mediaType;
//   num? kind;
//   num? price;
//   num? direction;
//   num? sellType;
//   num? permission;
//   String? general;
//   num? generalSort;
//   String? choice;
//   num? choiceSort;
//   String? section;
//   num? sectionSort;
//   num? originalSort;
//   num? originalButtonSort;
//   bool? isActive;
//   num? countPurchases;
//   num? countBrowse;
//   num? countCollect;
//   num? countLike;
//   num? countComment;
//   num? number;
//   num? updateStatus;
//   String? updatedDesc;
//   String? createdAt;
//   String? updatedAt;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = id;
//     map['title'] = title;
//     map['horizontalCover'] = horizontalCover;
//     map['verticalCover'] = verticalCover;
//     map['tags'] = tags;
//     map['tagNames'] = tagNames;
//     map['sellTypeHide'] = sellTypeHide;
//     map['summary'] = summary;
//     map['totalEpisode'] = totalEpisode;
//     map['mediaType'] = mediaType;
//     map['kind'] = kind;
//     map['price'] = price;
//     map['direction'] = direction;
//     map['sellType'] = sellType;
//     map['permission'] = permission;
//     map['general'] = general;
//     map['generalSort'] = generalSort;
//     map['choice'] = choice;
//     map['choiceSort'] = choiceSort;
//     map['section'] = section;
//     map['sectionSort'] = sectionSort;
//     map['originalSort'] = originalSort;
//     map['originalButtonSort'] = originalButtonSort;
//     map['isActive'] = isActive;
//     map['countPurchases'] = countPurchases;
//     map['countBrowse'] = countBrowse;
//     map['countCollect'] = countCollect;
//     map['countLike'] = countLike;
//     map['countComment'] = countComment;
//     map['number'] = number;
//     map['updateStatus'] = updateStatus;
//     map['updatedDesc'] = updatedDesc;
//     map['createdAt'] = createdAt;
//     map['updatedAt'] = updatedAt;
//     return map;
//   }
//
// }

class Section {
  Section({
    this.id,
    this.sectionName,
    this.sectionCover,
    this.img,
    this.subModuleID,
    this.status,
    this.sort,
    this.desc,
    this.isFree,
    this.showType,
    this.type,
    this.linkType,
    this.linkUrl,
    this.isDelete,
    this.tags,
    this.tagIds,
    this.direction,
    this.createdAt,
    this.updatedAt,
    this.updatedAct,
  });

  Section.fromJson(dynamic json) {
    l.d("Section=====${json.toString()}");
    id = json['id'];
    sectionName = json['sectionName'];
    sectionCover = json['sectionCover'];
    img = json['img'];
    subModuleID = json['subModuleID'];
    status = json['status'];
    sort = json['sort'];
    desc = json['desc'];
    isFree = json['isFree'];
    showType = json['showType'];
    type = json['type'];
    linkType = json['linkType'];
    linkUrl = json['linkUrl'];
    isDelete = json['isDelete'];
    if (json['tags'] != null) {
      tags = [];
      json['tags'].forEach((v) {
        tags?.add(v);
      });
    }
    tagIds = json['tagIds'];
    direction = json['direction'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    updatedAct = json['updatedAct'];
  }
  String? id;
  String? sectionName;
  String? sectionCover;
  String? img;
  String? subModuleID;
  num? status;
  num? sort;
  String? desc;
  bool? isFree;
  num? showType;
  num? type;
  num? linkType;
  String? linkUrl;
  bool? isDelete;
  List<dynamic>? tags;
  dynamic tagIds;
  num? direction;
  String? createdAt;
  String? updatedAt;
  String? updatedAct;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['sectionName'] = sectionName;
    map['sectionCover'] = sectionCover;
    map['img'] = img;
    map['subModuleID'] = subModuleID;
    map['status'] = status;
    map['sort'] = sort;
    map['desc'] = desc;
    map['isFree'] = isFree;
    map['showType'] = showType;
    map['type'] = type;
    map['linkType'] = linkType;
    map['linkUrl'] = linkUrl;
    map['isDelete'] = isDelete;
    if (tags != null) {
      map['tags'] = tags?.map((v) => v.toJson()).toList();
    }
    map['tagIds'] = tagIds;
    map['direction'] = direction;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['updatedAct'] = updatedAct;
    return map;
  }
}
