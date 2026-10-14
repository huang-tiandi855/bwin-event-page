// To parse this JSON data, do
//
//     final mediaPayModel = mediaPayModelFromJson(jsonString);

import 'dart:convert';

MediaPayModel mediaPayModelFromJson(String str) =>
    MediaPayModel.fromJson(json.decode(str));

String mediaPayModelToJson(MediaPayModel data) => json.encode(data.toJson());

class MediaPayModel {
  Record? record;
  Video? video;
  dynamic posting;
  List<String>? tags;

  MediaPayModel({
    this.record,
    this.video,
    this.posting,
    this.tags,
  });

  factory MediaPayModel.fromJson(Map<String, dynamic> json) => MediaPayModel(
        record: json["record"] == null ? null : Record.fromJson(json["record"]),
        video: json["video"] == null ? null : Video.fromJson(json["video"]),
        posting: json["posting"],
        tags: json["tags"] == null
            ? []
            : List<String>.from(json["tags"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "record": record?.toJson(),
        "video": video?.toJson(),
        "posting": posting,
        "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
      };
}

class Record {
  int? id;
  int? uid;
  double? gold;
  int? pid;
  int? costType;
  int? createDate;
  dynamic code;

  Record({
    this.id,
    this.uid,
    this.gold,
    this.pid,
    this.costType,
    this.createDate,
    this.code,
  });

  factory Record.fromJson(Map<String, dynamic> json) => Record(
        id: json["id"],
        uid: json["uid"],
        gold: (json["gold"] as num?)?.toDouble(),
        pid: json["pid"],
        costType: json["costType"],
        createDate: json["createDate"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "uid": uid,
        "gold": gold,
        "pid": pid,
        "costType": costType,
        "createDate": createDate,
        "code": code,
      };
}

class Video {
  int? id;
  int? groupId;
  int? createDateTime;
  int? status;
  int? recommend;
  int? priority;
  dynamic tags;
  int? likeNumber;
  int? readNumber;
  dynamic fromSiteId;
  dynamic fromGroupId;
  String? vodId;
  String? vodName;
  dynamic vodType;
  String? vodPic;
  dynamic vodPicThumb;
  dynamic vodPicSlide;
  dynamic vodPlayUrl;
  String? vodFullPlayUrl;
  String? vodPicInfo;
  dynamic vodIntro;
  dynamic vodActor;
  dynamic vodSubtitle;
  dynamic vodTime;
  dynamic vodSerialNumber;
  dynamic vodTag;
  dynamic vodClass;
  int? vodDuration;
  dynamic vodArea;
  dynamic vodLang;
  dynamic vodYear;
  dynamic vodVersion;
  dynamic vodMosaic;
  dynamic vodCaptions;
  dynamic magnetHash;
  dynamic magnetSha;
  dynamic magnetSize;
  dynamic actor;
  dynamic vodTagName;
  bool? isVip;
  int? gold;
  bool? isSync;
  int? syncTime;
  int? videoType;
  int? playNum;
  bool? original;
  bool? selfie;
  dynamic remark;
  dynamic admin;
  int? uid;
  dynamic scroll;
  dynamic gif;
  dynamic mp4;
  dynamic preview;
  dynamic upDate;
  dynamic upRecommend;
  dynamic notifyRecommend;
  int? collectNum;
  int? collects;
  int? likeNum;
  int? mthReadNum;
  int? wkReadNum;
  String? title;

  Video({
    this.id,
    this.groupId,
    this.createDateTime,
    this.status,
    this.recommend,
    this.priority,
    this.tags,
    this.likeNumber,
    this.readNumber,
    this.fromSiteId,
    this.fromGroupId,
    this.vodId,
    this.vodName,
    this.vodType,
    this.vodPic,
    this.vodPicThumb,
    this.vodPicSlide,
    this.vodPlayUrl,
    this.vodFullPlayUrl,
    this.vodPicInfo,
    this.vodIntro,
    this.vodActor,
    this.vodSubtitle,
    this.vodTime,
    this.vodSerialNumber,
    this.vodTag,
    this.vodClass,
    this.vodDuration,
    this.vodArea,
    this.vodLang,
    this.vodYear,
    this.vodVersion,
    this.vodMosaic,
    this.vodCaptions,
    this.magnetHash,
    this.magnetSha,
    this.magnetSize,
    this.actor,
    this.vodTagName,
    this.isVip,
    this.gold,
    this.isSync,
    this.syncTime,
    this.videoType,
    this.playNum,
    this.original,
    this.selfie,
    this.remark,
    this.admin,
    this.uid,
    this.scroll,
    this.gif,
    this.mp4,
    this.preview,
    this.upDate,
    this.upRecommend,
    this.notifyRecommend,
    this.collectNum,
    this.collects,
    this.likeNum,
    this.mthReadNum,
    this.wkReadNum,
    this.title,
  });

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        id: json["id"],
        groupId: json["groupId"],
        createDateTime: json["createDateTime"],
        status: json["status"],
        recommend: json["recommend"],
        priority: json["priority"],
        tags: json["tags"],
        likeNumber: json["likeNumber"],
        readNumber: json["readNumber"],
        fromSiteId: json["fromSiteId"],
        fromGroupId: json["fromGroupId"],
        vodId: json["vodId"],
        vodName: json["vodName"],
        vodType: json["vodType"],
        vodPic: json["vodPic"],
        vodPicThumb: json["vodPicThumb"],
        vodPicSlide: json["vodPicSlide"],
        vodPlayUrl: json["vodPlayUrl"],
        vodFullPlayUrl: json["vodFullPlayUrl"],
        vodPicInfo: json["vodPicInfo"],
        vodIntro: json["vodIntro"],
        vodActor: json["vodActor"],
        vodSubtitle: json["vodSubtitle"],
        vodTime: json["vodTime"],
        vodSerialNumber: json["vodSerialNumber"],
        vodTag: json["vodTag"],
        vodClass: json["vodClass"],
        vodDuration: json["vodDuration"],
        vodArea: json["vodArea"],
        vodLang: json["vodLang"],
        vodYear: json["vodYear"],
        vodVersion: json["vodVersion"],
        vodMosaic: json["vodMosaic"],
        vodCaptions: json["vodCaptions"],
        magnetHash: json["magnetHash"],
        magnetSha: json["magnetSha"],
        magnetSize: json["magnetSize"],
        actor: json["actor"],
        vodTagName: json["vodTagName"],
        isVip: json["isVip"],
        gold: json["gold"],
        isSync: json["isSync"],
        syncTime: json["syncTime"],
        videoType: json["videoType"],
        playNum: json["playNum"],
        original: json["original"],
        selfie: json["selfie"],
        remark: json["remark"],
        admin: json["admin"],
        uid: json["uid"],
        scroll: json["scroll"],
        gif: json["gif"],
        mp4: json["mp4"],
        preview: json["preview"],
        upDate: json["upDate"],
        upRecommend: json["upRecommend"],
        notifyRecommend: json["notifyRecommend"],
        collectNum: json["collectNum"],
        collects: json["collects"],
        likeNum: json["likeNum"],
        mthReadNum: json["mthReadNum"],
        wkReadNum: json["wkReadNum"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "groupId": groupId,
        "createDateTime": createDateTime,
        "status": status,
        "recommend": recommend,
        "priority": priority,
        "tags": tags,
        "likeNumber": likeNumber,
        "readNumber": readNumber,
        "fromSiteId": fromSiteId,
        "fromGroupId": fromGroupId,
        "vodId": vodId,
        "vodName": vodName,
        "vodType": vodType,
        "vodPic": vodPic,
        "vodPicThumb": vodPicThumb,
        "vodPicSlide": vodPicSlide,
        "vodPlayUrl": vodPlayUrl,
        "vodFullPlayUrl": vodFullPlayUrl,
        "vodPicInfo": vodPicInfo,
        "vodIntro": vodIntro,
        "vodActor": vodActor,
        "vodSubtitle": vodSubtitle,
        "vodTime": vodTime,
        "vodSerialNumber": vodSerialNumber,
        "vodTag": vodTag,
        "vodClass": vodClass,
        "vodDuration": vodDuration,
        "vodArea": vodArea,
        "vodLang": vodLang,
        "vodYear": vodYear,
        "vodVersion": vodVersion,
        "vodMosaic": vodMosaic,
        "vodCaptions": vodCaptions,
        "magnetHash": magnetHash,
        "magnetSha": magnetSha,
        "magnetSize": magnetSize,
        "actor": actor,
        "vodTagName": vodTagName,
        "isVip": isVip,
        "gold": gold,
        "isSync": isSync,
        "syncTime": syncTime,
        "videoType": videoType,
        "playNum": playNum,
        "original": original,
        "selfie": selfie,
        "remark": remark,
        "admin": admin,
        "uid": uid,
        "scroll": scroll,
        "gif": gif,
        "mp4": mp4,
        "preview": preview,
        "upDate": upDate,
        "upRecommend": upRecommend,
        "notifyRecommend": notifyRecommend,
        "collectNum": collectNum,
        "collects": collects,
        "likeNum": likeNum,
        "mthReadNum": mthReadNum,
        "wkReadNum": wkReadNum,
        "title": title,
      };
}
