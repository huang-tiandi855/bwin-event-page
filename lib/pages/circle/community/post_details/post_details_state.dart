import 'package:flutter/material.dart';

import '../../../../common/entities/circle/post_card_data.dart';

class PostDetailsState {
  final ScrollController scrollController = ScrollController();
  int postId = 0;

  /// 帖子详情数据；首屏请求未回 / 失败时为 `null`，UI 走骨架占位。
  PostCardData? postModel;

  /// 关注状态本地副本。[PostAuthor.follow] 是只读字段，关注 / 取关
  /// 的乐观切换走这里，避免直接突变数据模型；详情请求回来时同步一次。
  bool isFollow = false;
  bool isLike = false;
  bool isCollect = false;
}
