import 'dart:convert';

import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/post_entity.g.dart';

import '../store/user.dart';
import '../utils/debug_log.dart';
import '../utils/text_util.dart';

class PostTitle {
  PostTitle({this.originTitle, this.jsonTxt}) {
    if (jsonTxt?.isNotEmpty == true) {
      String? json = jsonTxt!.replaceAll("\\", "");
      Map<String, dynamic> linkInfo = jsonDecode(json);
      _txt = linkInfo['txt'];
      type = linkInfo['type'].toString();
      id = linkInfo['id'].toString();
    }
  }

  String? originTitle;
  String? type;
  String? jsonTxt;
  String? id;
  String? _txt;

  String? get txt {
    if (isRich) {
      return _txt;
    }
    return originTitle;
  }

  bool get isRich {
    return jsonTxt?.isNotEmpty == true;
  }

  int? get length {
    return txt?.length ?? 0;
  }

  String? get linkUrl {
    String? innerUrl = "";
    return innerUrl;
  }
}

@JsonSerializable()
class PostEntity {
  List<PostList>? list;
  List<PostList>? vInfos;
  bool? hasNext;

  PostEntity();

  factory PostEntity.fromJson(Map<String, dynamic> json) =>
      $PostEntityFromJson(json);

  Map<String, dynamic> toJson() => $PostEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

enum PostType { img, video, imgVideo } //imgVideo 图集和视频

@JsonSerializable()
class PostList {
  PostType get postType {
    if (sourceURL?.isNotEmpty == true) {
      seriesCover?.remove(cover);
      if (seriesCover?.isNotEmpty == true) {
        return PostType.imgVideo;
      }
      return PostType.video;
    } else {
      return PostType.img;
    }
  }

  String? id;
  String? newsType;
  String? content;
  String? richText;
  String? title;
  List<PostListTags>? tags;
  String? sourceURL;
  int? playTime;
  String? cover;
  String? coverThumb;
  List<String>? seriesCover;
  int? playCount;
  int? purchaseCount;
  int? likeCount;
  int? commentCount;
  int? shareCount;
  int? forwardCount;
  int? coins;
  int? size;
  String? resolution;
  double? ratio;
  int? status;
  String? reason;
  int? freeTime;
  bool? isHideLocation;
  bool? freeArea;
  String? createdAt;
  String? reviewAt;
  bool? isTopping;
  bool? isRecommend;
  bool? isChoosen;
  String? rewarded;

  String? get rewardedDesc {
    try {
      if (rewarded == null || rewarded == "0") {
        return "打赏";
      }
      return TextUtil.moreThan1wIndent(rewarded!.contains(".")
          ? double.parse(rewarded!).toInt()
          : int.parse(rewarded!));
    } catch (e) {
      debugLog(e);
      return rewarded;
    }
  }

  int? originCoins;
  PostListPublisher? publisher;
  PostListLocation? location;
  PostListVidStatus? vidStatus;
  PostListComment? comment;
  PostListWatch? watch;
  bool? isForWard;
  int? forWardUser;
  String? forWardUserName;
  List<PostTitle>? postTitleArr;
  String? seedLink;
  int seedLinkStatus = -1;

  /// -1 代表没有种子链接 0 代表已经购买过 1开通vip 2金豆

  int? get richLength {
    if (postTitleArr?.isNotEmpty == true) {
      int length = 0;
      for (int i = 0; i < postTitleArr!.length; i++) {
        length = postTitleArr![i].txt?.length ?? 0;
      }
      return length;
    }
    return title?.length ?? 0;
  }

  int get coin {
    bool isVip = UserStore.to.isVip();
    if (isVip) {
      return coins ?? 0;
    } else {
      return originCoins ?? 0;
    }
  }

  String get seedLinkText {
    if (seedLink?.isEmpty == true) {
      seedLinkStatus = -1;
      return '';
    }

    if (vidStatus?.hasPaid == true) {
      seedLinkStatus = 0;
      return '点击复制「种子链接」';
    }

    bool isVip = UserStore.to.isVip();
    if (coin > 0) {
      //金币帖子
      seedLinkStatus = 2;
      return '$coin金豆解锁 即可下载种子';
    } else {
      if (!isVip) {
        seedLinkStatus = 1;
        return '开通VIP 即可下载种子';
      } else {
        seedLinkStatus = 0;
        return '点击复制「种子链接」';
      }
    }
  }

  PostList();

  factory PostList.fromJson(Map<String, dynamic> json) =>
      $PostListFromJson(json);

  Map<String, dynamic> toJson() => $PostListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PostListTags {
  String? id;
  String? name;
  String? coverImg;
  String? description;
  int? playCount;
  bool? hasCollected;

  PostListTags();

  factory PostListTags.fromJson(Map<String, dynamic> json) =>
      $PostListTagsFromJson(json);

  Map<String, dynamic> toJson() => $PostListTagsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PostListPublisher {
  int? uid;
  String? name;
  String? gender;
  String? portrait;
  String? portraitFrame;
  bool? hasLocked;
  bool? hasBanned;
  int? vipLevel;
  bool? isVip;
  int? rechargeLevel;
  int? superUser;
  String? vipExpireDate;
  int? activeValue;
  bool? officialCert;
  int? age;
  int? follows;
  int? fans;
  String? summary;
  dynamic awards;
  bool? hasFollowed;

  String? superUserExpire;
  String? officialCertExpire;
  String? videoFreeExpiration;

  bool get isBigVip {
    if ((superUser ?? 0) > 0 && !isBeforeToday(superUserExpire)) {
      return true;
    }
    return false;
  }

  bool isBeforeToday(String? time) {
    if (time?.isNotEmpty == true && time != "0001-01-01T00:00:00Z") {
      var startDate = time!;
      var endDate = DateTime.now();
      return DateTime.parse(startDate).isBefore(endDate);
    } else {
      return true;
    }
  }

  PostListPublisher();

  factory PostListPublisher.fromJson(Map<String, dynamic> json) =>
      $PostListPublisherFromJson(json);

  Map<String, dynamic> toJson() => $PostListPublisherToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PostListLocation {
  String? id;
  String? city;
  String? cover;
  int? visit;
  String? createdAt;

  PostListLocation();

  factory PostListLocation.fromJson(Map<String, dynamic> json) =>
      $PostListLocationFromJson(json);

  Map<String, dynamic> toJson() => $PostListLocationToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PostListVidStatus {
  bool? hasLiked;
  bool? hasPaid;
  bool? hasCollected;
  int? todayRank;
  int? todayPlayCnt;

  PostListVidStatus();

  factory PostListVidStatus.fromJson(Map<String, dynamic> json) =>
      $PostListVidStatusFromJson(json);

  Map<String, dynamic> toJson() => $PostListVidStatusToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PostListComment {
  int? uid;
  String? name;
  String? portrait;
  String? cid;
  String? content;
  int? likeCount;
  bool? isAuthor;
  String? createdAt;

  PostListComment();

  factory PostListComment.fromJson(Map<String, dynamic> json) =>
      $PostListCommentFromJson(json);

  Map<String, dynamic> toJson() => $PostListCommentToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PostListWatch {
  int? watchCount;
  bool? isWatch;
  bool? isFreeWatch;

  PostListWatch();

  factory PostListWatch.fromJson(Map<String, dynamic> json) =>
      $PostListWatchFromJson(json);

  Map<String, dynamic> toJson() => $PostListWatchToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
