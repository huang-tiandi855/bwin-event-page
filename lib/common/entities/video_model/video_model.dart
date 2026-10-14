import 'dart:math';

import 'vid_status_model.dart';

import 'publisher_model.dart';
import 'tags_model.dart';
import 'watch_model.dart';

export 'video_model_extension.dart';

List<double> waterfallHeight = [153, 119];

class VideoModel {
  String? id;
  String? newsType;
  String? title;
  String? content;
  String? sourceUrl;
  int? playTime;
  String? cover;
  String? verticalCover;

  bool get isVerticalCover => (verticalCover?.isEmpty ?? true) ? false : true;

  String? get autoCover => !isVerticalCover ? cover : verticalCover;

  List<String> seriesCover;
  int? playCount;
  int? imgCount;
  int? likeCount;
  int? disLikeCount;
  int? pageViewCount;
  int? commentCount;
  int? coins;
  int? size;
  String? resolution;
  double? ratio;
  int? status;
  String? reason;
  int? freeTime;
  DateTime? createdAt;
  DateTime? reviewAt;
  bool? isTopping;
  bool? isPopping;
  bool? isRecommend;
  bool? isChoosen;
  String? rewarded;
  int? purchaseCount;
  bool? freeArea;
  int? grade;
  int? countGrade;
  int? originCoins;
  int? totalWorks;
  bool? chosen;
  List<TagsModel> tags;
  PublisherModel? publisher;
  VidStatusModel? vidStatus;
  WatchModel? watch;
  String? seedId;
  String? seedLink;
  int? seedCoin;
  int? seedSize;
  String? seedTime;
  String? relatedTitle;
  String? relatedCover;
  String? codelessLink;
  int? bountyPoint;
  int? collectCount;
  String? chineseLink;
  String? previewUrl;
  int? kind = 0;
  int? zone = 0;
  bool isAd;
  String? adUrl;

  double? get waterfallImageHeight {
    return waterfallHeight[Random().nextInt(waterfallHeight.length)];
  }



  List<String> get tagNames => tags.map((e) => e.name ?? "").toList();

  // 0: vip, 1: 金豆, 2: 免费
  int get permission {
    if (freeArea == true) {
      return 2;
    } else {
      return (originCoins ?? 0) == 0 ? 0 : 1;
    }
  }

  // String get type {
  //   switch (newsType) {
  //     case "SP":
  //       return "video";
  //     case "COVER":
  //       return "image";
  //     case "MOVIE":
  //       return "movie";
  //     default:
  //       return "video";
  //   }
  // }

  VideoModel({
    this.id,
    this.newsType,
    this.title,
    this.content,
    this.sourceUrl,
    this.playTime,
    this.cover,
    this.verticalCover,
    this.seriesCover = const [],
    this.playCount,
    this.likeCount,
    this.imgCount,
    this.disLikeCount,
    this.pageViewCount,
    this.commentCount,
    this.coins,
    this.size,
    this.resolution,
    this.ratio,
    this.status,
    this.reason,
    this.freeTime,
    this.createdAt,
    this.reviewAt,
    this.isTopping,
    this.isPopping,
    this.isRecommend,
    this.isChoosen,
    this.rewarded,
    this.purchaseCount,
    this.freeArea,
    this.grade,
    this.countGrade,
    this.originCoins,
    this.totalWorks,
    this.chosen,
    this.tags = const [],
    this.publisher,
    this.vidStatus,
    this.watch,
    this.seedId,
    this.seedLink,
    this.seedCoin,
    this.seedSize,
    this.seedTime,
    this.relatedTitle,
    this.relatedCover,
    this.codelessLink,
    this.bountyPoint,
    this.collectCount,
    this.chineseLink,
    this.previewUrl,
    this.isAd = false,
    this.adUrl,
  });

  @override
  String toString() {
    return 'VideoModel(id: $id, newsType: $newsType, title: $title, sourceUrl: $sourceUrl, playTime: $playTime, cover: $cover, verticalCover: $verticalCover, seriesCover: $seriesCover, playCount: $playCount, likeCount: $likeCount, disLikeCount: $disLikeCount, pageViewCount: $pageViewCount, commentCount: $commentCount, coins: $coins, size: $size, resolution: $resolution, ratio: $ratio, status: $status, reason: $reason, freeTime: $freeTime, createdAt: $createdAt, reviewAt: $reviewAt, isTopping: $isTopping, isPopping: $isPopping, isRecommend: $isRecommend, isChoosen: $isChoosen, rewarded: $rewarded, purchaseCount: $purchaseCount, freeArea: $freeArea, grade: $grade, countGrade: $countGrade, originCoins: $originCoins, totalWorks: $totalWorks, chosen: $chosen, tags: $tags, publisher: $publisher, vidStatus: $vidStatus, watch: $watch, seedId: $seedId, seedLink: $seedLink, seedCoin: $seedCoin, seedSize: $seedSize, seedTime: $seedTime, relatedTitle: $relatedTitle, relatedCover: $relatedCover, codelessLink: $codelessLink, bountyPoint: $bountyPoint, collectCount: $collectCount, chineseLink: $chineseLink)';
  }

  factory VideoModel.ad({
    required String? id,
    required String? title,
    required String? cover,
    required String? verticalCover,
    required String? adUrl,
  }) {
    return VideoModel(
      isAd: true,
      id: id,
      title: title,
      cover: cover,
      verticalCover: verticalCover,
      adUrl: adUrl,
    );
  }

  factory VideoModel.fromJson(Map<String, Object?> json) => VideoModel(
        id: json['id'] as String?,
        newsType: json['newsType'] as String?,
        title: json['title'] as String?,
        content: json['content'] as String?,
        sourceUrl: json['sourceURL'] as String?,
        playTime: json['playTime'] as int?,
        cover: json['cover'] as String?,
        verticalCover: json['verticalCover'] as String?,
        seriesCover: (json['seriesCover'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
        playCount: json['playCount'] as int?,
        likeCount: json['likeCount'] as int?,
        imgCount: json['imgCount'] as int?,
        disLikeCount: json['disLikeCount'] as int?,
        pageViewCount: json['pageViewCount'] as int?,
        commentCount: json['commentCount'] as int?,
        coins: json['coins'] as int?,
        size: json['size'] as int?,
        resolution: json['resolution'] as String?,
        ratio: (json['ratio'] as num?)?.toDouble(),
        status: json['status'] as int?,
        reason: json['reason'] as String?,
        freeTime: json['freeTime'] as int?,
        createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt']! as String),
        reviewAt: json['reviewAt'] == null ? null : DateTime.parse(json['reviewAt']! as String),
        isTopping: json['isTopping'] as bool?,
        isPopping: json['isPopping'] as bool?,
        isRecommend: json['isRecommend'] as bool?,
        isChoosen: json['isChoosen'] as bool?,
        rewarded: json['rewarded'] as String?,
        purchaseCount: json['purchaseCount'] as int?,
        freeArea: json['freeArea'] as bool?,
        grade: json['grade'] as int?,
        countGrade: json['countGrade'] as int?,
        originCoins: json['originCoins'] as int?,
        totalWorks: json['totalWorks'] as int?,
        chosen: json['chosen'] as bool?,
        tags:
            (json['tags'] as List<dynamic>?)?.map((e) => TagsModel.fromJson(e as Map<String, Object?>)).toList() ?? [],
        publisher:
            json['publisher'] == null ? null : PublisherModel.fromJson(json['publisher']! as Map<String, Object?>),
        vidStatus:
            json['vidStatus'] == null ? null : VidStatusModel.fromJson(json['vidStatus']! as Map<String, Object?>),
        watch: json['watch'] == null ? null : WatchModel.fromJson(json['watch']! as Map<String, Object?>),
        seedId: json['seedId'] as String?,
        seedLink: json['seedLink'] as String?,
        seedCoin: json['seedCoin'] as int?,
        seedSize: json['seedSize'] as int?,
        seedTime: json['seedTime'] as String?,
        relatedTitle: json['relatedTitle'] as String?,
        relatedCover: json['relatedCover'] as String?,
        codelessLink: json['codelessLink'] as String?,
        bountyPoint: json['bountyPoint'] as int?,
        collectCount: json['collectCount'] as int?,
        chineseLink: json['chineseLink'] as String?,
        previewUrl: json['previewURL'] as String?,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'newsType': newsType,
        'title': title,
        'content': content,
        'sourceURL': sourceUrl,
        'playTime': playTime,
        'cover': cover,
        'verticalCover': verticalCover,
        'seriesCover': seriesCover,
        'playCount': playCount,
        'likeCount': likeCount,
        'disLikeCount': disLikeCount,
        'pageViewCount': pageViewCount,
        'commentCount': commentCount,
        'coins': coins,
        'size': size,
        'resolution': resolution,
        'ratio': ratio,
        'status': status,
        'reason': reason,
        'freeTime': freeTime,
        'createdAt': createdAt?.toIso8601String(),
        'reviewAt': reviewAt?.toIso8601String(),
        'isTopping': isTopping,
        'isPopping': isPopping,
        'isRecommend': isRecommend,
        'isChoosen': isChoosen,
        'rewarded': rewarded,
        'purchaseCount': purchaseCount,
        'freeArea': freeArea,
        'grade': grade,
        'countGrade': countGrade,
        'originCoins': originCoins,
        'totalWorks': totalWorks,
        'chosen': chosen,
        'tags': tags.map((e) => e.toJson()).toList(),
        'publisher': publisher?.toJson(),
        'vidStatus': vidStatus?.toJson(),
        'watch': watch?.toJson(),
        'seedId': seedId,
        'seedLink': seedLink,
        'seedCoin': seedCoin,
        'seedSize': seedSize,
        'seedTime': seedTime,
        'relatedTitle': relatedTitle,
        'relatedCover': relatedCover,
        'codelessLink': codelessLink,
        'bountyPoint': bountyPoint,
        'collectCount': collectCount,
        'chineseLink': chineseLink,
        'previewURL': previewUrl,
      };
}
