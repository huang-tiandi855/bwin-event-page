// To parse this JSON data, do
//
//     final featureEntity = featureEntityFromJson(jsonString);

import 'dart:convert';

import 'module_detail_model/all_section_model.dart';

FeatureEntity featureEntityFromJson(String str) => FeatureEntity.fromJson(json.decode(str));

String featureEntityToJson(FeatureEntity data) => json.encode(data.toJson());

class FeatureEntity {
  FeatureEntity({
    this.code,
    this.data,
    this.hash,
    this.msg,
    this.time,
    this.tip,
  });

  int? code;
  Data? data;
  bool? hash;
  String? msg;
  DateTime? time;
  String? tip;

  factory FeatureEntity.fromJson(Map<String, dynamic> json) => FeatureEntity(
        code: json["code"],
        data: Data.fromJson(json["data"]),
        hash: json["hash"],
        msg: json["msg"],
        time: DateTime.parse(json["time"]),
        tip: json["tip"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "data": data!.toJson(),
        "hash": hash,
        "msg": msg,
        "time": time!.toIso8601String(),
        "tip": tip,
      };
}

class Data {
  Data({
    this.list,
    required this.hasNext,
  });

  List<ListElement>? list;
  bool hasNext;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        list: List<ListElement>.from(json["list"].map((x) => ListElement.fromJson(x))),
        hasNext: json["hasNext"],
      );

  Map<String, dynamic> toJson() => {
        "list": List<dynamic>.from(list!.map((x) => x.toJson())),
        "hasNext": hasNext,
      };
}

class ListElement extends AllSectionModel{
  ListElement({
    this.id,
    this.name,
    this.img,
    this.zone,
    this.desc,
    this.sortNum,
    this.direction,
    this.active,
    this.createdAt,
    this.updatedAt,
    this.mediaList,
    required this.hasNext,
  });

  String? id;
  String? name;
  String? img;
  String? zone;
  String? desc;
  int? sortNum;
  int? direction;
  bool? active;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<MediaList>? mediaList;
  bool hasNext;

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["id"],
        name: json["name"],
        img: json["img"],
        zone: json["zone"],
        desc: json["desc"],
        sortNum: json["sortNum"],
        direction: json["direction"],
        active: json["active"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        mediaList: List<MediaList>.from((json["MediaList"] ?? []).map((x) => MediaList.fromJson(x))),
        hasNext: json["hasNext"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "img": img,
        "zone": zone,
        "desc": desc,
        "sortNum": sortNum,
        "direction": direction,
        "active": active,
        "createdAt": createdAt!.toIso8601String(),
        "updatedAt": updatedAt!.toIso8601String(),
        "MediaList": List<dynamic>.from(mediaList!.map((x) => x.toJson())),
        "hasNext": hasNext,
      };
}

class MediaList {
  MediaList({
    this.id,
    this.title,
    this.horizontalCover,
    this.verticalCover,
    this.tags,
    this.tagNames,
    this.summary,
    this.totalEpisode,
    /**
     * MediaTypeVideo    = "video"     //视频
        MediaTypeVideoAdv = "video_adv" //视频广告
        MediaTypeImage    = "image"     //图片
        MediaTypeText     = "text"      //文本
     *
     * ***/
    this.mediaType,

    /**
     * const (
        //动漫
        MediaKindCartoon = iota
        //漫画
        MediaKindComics
        //角色扮演
        MediaKindCosPlay
        //真人
        MediaKindRealPerson
        //小说
        MediaKindRealFiction
        //写真
        MediaKindRealPhoto
        //禁播
        MediaKindRealBanned
        )
     *
     *
     * Kind
     * commod.MediaKind
     * bson:"kind" json:"kind"
     * //种类(动漫 漫画 小说 cos 禁播)
     *
     * ****/
    this.kind,
    this.price,
    this.direction,
    this.sellType,
    this.permission,
    this.general,
    this.generalSort,
    this.choice,
    this.choiceSort,
    this.isActive,
    this.countPurchases,
    this.countBrowse,
    this.countCollect,
    this.countLike,
    this.number,
    this.createdAt,
    this.updatedAt,
    this.updateStatus,
    this.updatedDesc,
  });

  String? id;
  String? title;
  String? horizontalCover;
  String? verticalCover;
  List<String>? tags;
  List<String>? tagNames;
  String? summary;
  int? totalEpisode;
  String? mediaType;
  /// const (
  ///   //动漫
  ///   MediaKindCartoon = iota
  ///   //漫画
  ///   MediaKindComics
  ///   //角色扮演
  ///   MediaKindCosPlay
  ///   //真人
  ///   MediaKindRealPerson
  ///   //小说
  ///   MediaKindRealFiction
  ///   //写真
  ///   MediaKindRealPhoto
  ///   //禁播
  ///   MediaKindRealBanned
  /// )
  int? kind;
  int? price;
  int? direction;
  int? sellType;
  int? permission;
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
  DateTime? createdAt;
  DateTime? updatedAt;

  int? updateStatus;
  String? updatedDesc;

  factory MediaList.fromJson(Map<String, dynamic> json) => MediaList(
        id: json["id"],
        title: json["title"],
        horizontalCover: json["horizontalCover"],
        verticalCover: json["verticalCover"],
        tags: List<String>.from((json["tags"] ?? []).map((x) => x)),
        tagNames: List<String>.from((json["tagNames"] ?? []).map((x) => x)),
        summary: json["summary"],
        totalEpisode: json["totalEpisode"],
        mediaType: json["mediaType"],
        kind: json["kind"],
        price: json["price"],
        direction: json["direction"],
        sellType: json["sellType"],
        permission: json["permission"],
        general: json["general"],
        generalSort: json["generalSort"],
        choice: json["choice"],
        choiceSort: json["choiceSort"],
        isActive: json["isActive"],
        countPurchases: json["countPurchases"],
        countBrowse: json["countBrowse"],
        countCollect: json["countCollect"],
        countLike: json["countLike"],
        number: json["number"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        updateStatus: json["updateStatus"],
        updatedDesc: json["updatedDesc"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "horizontalCover": horizontalCover,
        "verticalCover": verticalCover,
        "tags": List<dynamic>.from(tags!.map((x) => x)),
        "tagNames": List<dynamic>.from(tagNames!.map((x) => x)),
        "summary": summary,
        "totalEpisode": totalEpisode,
        "mediaType": mediaType,
        "kind": kind,
        "price": price,
        "direction": direction,
        "sellType": sellType,
        "permission": permission,
        "general": general,
        "generalSort": generalSort,
        "choice": choice,
        "choiceSort": choiceSort,
        "isActive": isActive,
        "countPurchases": countPurchases,
        "countBrowse": countBrowse,
        "countCollect": countCollect,
        "countLike": countLike,
        "number": number,
        "createdAt": createdAt!.toIso8601String(),
        "updatedAt": updatedAt!.toIso8601String(),
        "updateStatus": updateStatus,
        "updatedDesc": updatedDesc,
      };
}
