enum MediaKind {
  mediaKindCartoon, //动漫
  mediaKindComics, //漫画
  mediaKindCosPlay, //角色扮演
  mediaKindRealPerson, //真人
  mediaKindRealFiction, //小说
  mediaKindRealPhoto, //写真
  mediaKindRealBanned, //禁播
  mediaKindAudio, //有声小说
}

enum PaySuccess {
  successfulPurchase, //购买成功
  exchangeSuccessFullly, //观影券兑换成功
  successfulAllEsp;
}

enum MoreVideoType {
  user, //来自用户主页
  tagHot, //来自标签页最热
  tagNew, //来自标签页最新
  focusCircles, //圈子关注
  halfCircle, // 圈子发现
}

/// 视频排行类型
enum RankType {
  /// 总榜
  all(value: 0),

  /// 今日榜
  today(value: 1),

  /// 昨日榜
  yesterday(value: 2),

  /// 本周榜
  thisWeek(value: 3),

  /// 上周榜
  lastWeek(value: 4),

  /// 本月榜
  thisMonth(value: 5),

  /// 上月榜
  lastMonth(value: 6);

  const RankType({
    required this.value,
  });

  final int value;
}

/// 视频类型
enum VideoType {
  /// 普通视频
  video(value: 0),

  /// 短视频
  shortVideo(value: 1),

  /// 暗网视频
  darkVideo(value: 2);

  const VideoType({
    required this.value,
  });

  final int value;
}

/// 视频排序类型
enum VideoSortTypeEnum {
  // 排序方式 1. 推荐 2. 最新 3. 最热 4. 最受欢迎 5. 随机 6. 最多点赞 7. 最多评论 8. 最多收藏
  defaultSort(value: 0, fields: 'id'),
  recommend(value: 1, fields: 'recommend'),
  newest(value: 2, fields: 'createTime'),
  hot(value: 3, fields: 'readNumber'),
  love(value: 4, fields: 'readNumber'),
  random(value: 5, fields: 'id'),
  like(value: 6, fields: 'likeNumber'),
  comments(value: 7, fields: 'comments'),
  collects(value: 8, fields: 'collects'),
  downloads(value: 9, fields: 'downloads'),
  shares(value: 10, fields: 'shares'),
  priority(value: 11, fields: 'priority'),
  gold(value: 12, fields: 'gold'),
  payCount(value: 13, fields: 'payCount'),
  realRead(value: 14, fields: 'realRead');

  const VideoSortTypeEnum({
    required this.value,
    required this.fields,
  });

  final int value;
  final String fields;
}

enum FeedBackTypeEnum {
  /// 账号问题
  account(value: 0),

  /// 用户反馈
  user(value: 1),

  /// APP体验
  app(value: 2),

  /// 影视资源
  video(value: 3),

  /// 播放卡顿
  play(value: 4),

  /// 分类错误
  group(value: 5),

  /// 充值问题
  recharge(value: 6),

  /// 其他问题
  other(value: 7);

  const FeedBackTypeEnum({
    required this.value,
  });

  final int value;
}
