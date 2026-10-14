// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:comics_app/common/entities/post_entity.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/pages/video_page/player_code_manage.dart';

import 'tags_model.dart';

class ShortVideoModel {
  String? id;

  String title;

  String? cover;

  String? sourceUrl;

  String realVideoUrl;

  bool hasPaid;

  int permission;

  int? price;

  bool hasFollowed;

  /// 作者头像，对应详情接口 `result.author.avatar`，列表场景可由 `publisher.portrait` 兼容填充。
  String? authorAvatar;

  /// 作者 uid，对应 `result.author.id`。
  int? authorUid;

  /// 作者昵称，对应 `result.author.nickName`。
  String? authorName;

  /// 粉丝数，对应 `result.author.fansNum`。
  int authorFansNum;

  /// 帖子/动态发布数，对应 `result.author.pnum`。
  int authorPostNum;

  /// 视频作品数，对应 `result.author.vnum`，用户中心「作品」计数。
  int authorWorksNum;

  bool hasLiked;

  int likeCount;

  bool hasCollected;

  int collectCount;

  int playCount;

  int commentCount;

  int shareCount;

  int? playerCode;

  String newsType;

  String get type {
    switch (newsType) {
      case "SP":
        return "video";
      case "COVER":
        return "image";
      case "MOVIE":
        return "movie";
      default:
        return "video";
    }
  }

  List<TagsModel> tags;

  /// 视频付费类型：
  /// - 0：会员视频（[PlayerCodeManage.nonMember] / 1008），走 [ShortVideoAuthOverlay]
  /// - 1：金币视频（[PlayerCodeManage.noPay] / 1038），走 [ShortVideoGoldOverlay]
  /// - 2：可正常播放（无须额外鉴权）
  ///
  /// 1035（[PlayerCodeManage.notEnoughGold]）不会出现在详情接口里，是
  /// `videoGoldPay` 扣费时的临时态，与本字段无关。
  int get needPermission {
    switch (playerCode) {
      case PlayerCodeManage.nonMember:
        return 0;
      case PlayerCodeManage.noPay:
        return 1;
      default:
        return 2;
    }
  }

  bool get shouldUseCoverPlaceholder {
    return PlayerCodeManage.isAuthCode(playerCode) && realVideoUrl.isEmpty;
  }

  /// 是否自动展示「开通会员」浮层（仅 1008）。
  bool get shouldAutoShowAuthOverlay =>
      playerCode == PlayerCodeManage.nonMember;

  /// 是否自动展示「金币付费」浮层（仅 1038）。
  ///
  /// 1038 时 `realVideoUrl` 通常为空，所以必须在 `getVideoInfo` 拉详情之后主动把 [goldOverlayVideoId] 置位，由
  /// [ShortVideoGoldOverlay] 直接展示。1035 由 [insufficientGoldVideoIds]
  /// 接管，不在这里出现。
  bool get shouldAutoShowGoldOverlay => playerCode == PlayerCodeManage.noPay;

  ShortVideoModel({
    required this.id,
    required this.title,
    required this.cover,
    this.sourceUrl,
    required this.realVideoUrl,
    required this.permission,
    required this.hasPaid,
    required this.price,
    required this.hasFollowed,
    required this.authorUid,
    required this.authorAvatar,
    required this.authorName,
    required this.hasLiked,
    required this.likeCount,
    required this.newsType,
    this.authorFansNum = 0,
    this.authorPostNum = 0,
    this.authorWorksNum = 0,
    this.hasCollected = false,
    this.collectCount = 0,
    this.playCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.playerCode,
    this.tags = const [],
  });

  String buildRealVideoUrl() {
    return Address.buildH5VideoUrl(sourceUrl, token: UserStore.to.getToken());
  }

  void refreshRealVideoUrl() {
    if (sourceUrl?.isNotEmpty == true) {
      realVideoUrl = buildRealVideoUrl();
    }
  }

  factory ShortVideoModel.fromVideoModel(VideoModel model) {
    return ShortVideoModel(
      id: model.id,
      title: model.title ?? '',
      cover: model.autoCover,
      sourceUrl: model.sourceUrl,
      realVideoUrl: model.realVideoUrl,
      permission: model.permission,
      hasPaid: model.vidStatus?.hasPaid ?? false,
      price: model.coins,
      hasFollowed: model.publisher?.hasFollowed ?? false,
      authorAvatar: model.publisher?.portrait,
      authorUid: model.publisher?.uid,
      authorName: model.publisher?.name,
      hasLiked: model.vidStatus?.hasLiked ?? false,
      likeCount: model.likeCount ?? 0,
      hasCollected: model.vidStatus?.hasCollected ?? false,
      collectCount: model.collectCount ?? 0,
      playCount: model.playCount ?? model.pageViewCount ?? 0,
      commentCount: model.commentCount ?? 0,
      tags: model.tags,
      newsType: model.newsType ?? '',
    );
  }

  factory ShortVideoModel.fromPostModel(PostList model) {
    final token = UserStore.to.getToken();
    int permission = 2;

    if (model.coin > 0) {
      permission = 1;
    } else {
      if (model.originCoins == 0) {
        permission = 0;
      }
    }

    return ShortVideoModel(
      id: model.id,
      title: model.title ?? '',
      cover: model.cover,
      sourceUrl: model.sourceURL,
      realVideoUrl: Address.buildH5VideoUrl(model.sourceURL, token: token),
      permission: permission,
      hasPaid: model.vidStatus?.hasPaid ?? false,
      price: model.coins,
      hasFollowed: model.publisher?.hasFollowed ?? false,
      authorAvatar: model.publisher?.portrait,
      authorUid: model.publisher?.uid,
      authorName: model.publisher?.name,
      hasLiked: model.vidStatus?.hasLiked ?? false,
      likeCount: model.likeCount ?? 0,
      hasCollected: model.vidStatus?.hasCollected ?? false,
      collectCount: 0,
      playCount: model.playCount ?? model.watch?.watchCount ?? 0,
      commentCount: model.commentCount ?? 0,
      shareCount: model.shareCount ?? 0,
      tags: model.tags?.map((e) {
            return TagsModel.fromJson(e.toJson());
          }).toList() ??
          [],
      newsType: model.newsType ?? '',
    );
  }

  bool isBeforeToday(String time) {
    if (time != "0001-01-01T00:00:00Z") {
      var startDate = time;
      var endDate = DateTime.now();
      return DateTime.parse(startDate).isBefore(endDate);
    } else {
      return true;
    }
  }
}
