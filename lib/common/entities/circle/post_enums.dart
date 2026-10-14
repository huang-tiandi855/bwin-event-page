/// 帖子相关的枚举集中放这里，避免 `posting_list_models.dart` 与
/// `post_card.dart` 互相 import 形成循环依赖。

/// 帖子媒体类型（API `type` 字段）。
enum PostType {
  /// 0：视频
  video(0),

  /// 1：图文
  imageText(1),

  /// 2：图片
  image(2);

  const PostType(this.value);
  final int value;

  /// 安全反查；解析失败返回 `null`。
  static PostType? fromValue(int? v) {
    if (v == null) return null;
    for (final t in PostType.values) {
      if (t.value == v) return t;
    }
    return null;
  }
}

/// 帖子消费类型（API `costType` 字段）。
enum PostCostType {
  /// 0：免费
  free(0),

  /// 1：VIP
  vip(1),

  /// 2：金币
  gold(2);

  const PostCostType(this.value);
  final int value;

  static PostCostType? fromValue(int? v) {
    if (v == null) return null;
    for (final c in PostCostType.values) {
      if (c.value == v) return c;
    }
    return null;
  }
}

/// 帖子列表排序方式（API `sortType` 字段）。
enum PostSortType {
  /// 0：最新
  newest(0),

  /// 1：推荐
  recommend(1),

  /// 2：评论数
  comment(2),

  /// 3：点赞数（精华）
  like(3),

  /// 4：评论时间
  commentTime(4),

  /// 5：观看数（最热）
  view(5);

  const PostSortType(this.value);
  final int value;
}
