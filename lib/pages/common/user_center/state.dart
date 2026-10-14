import 'package:comics_app/common/entities/circle/posting_list_models.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';

class UserCenterState {
  final List<String> tabs = const ['影片', '抖音', '帖子'];

  /// 入口（长 / 短视频）跳转时携带的作者信息，直接用 [MediaInfoAuthor] 承载，
  /// 关注/取关时就地修改 `follow` 与 `fansNum`，返回时打包给上一页。
  /// 作品数（用户中心 header）取自 `userInfo?.vnum`。
  MediaInfoAuthor? userInfo;

  int uid = 0;
  int pageSize = 20;
  bool isFollowLoading = false;

  /// 入口处的关注状态原值，用于判断返回时是否需要回传给上一页。
  bool? initialFollow;

  /// 影片 Tab（videoType=0）。
  List<MediaVideoModel> movieList = <MediaVideoModel>[];
  int moviePage = 1;
  final PullRefreshController moviePullRefresh =
      PullRefreshController(isRequest: true);

  /// 抖音 Tab（videoType=1）。
  List<MediaVideoModel> shortList = <MediaVideoModel>[];
  int shortPage = 1;
  bool shortsLoaded = false;
  final PullRefreshController shortPullRefresh =
      PullRefreshController(isRequest: true);

  /// 帖子 Tab：用 [PostingListQuery.uid] 按当前 [uid] 拉 `posting/list`。
  /// 与影片/抖音同样的「Tab 首次进入才请求」策略，故首屏默认非请求中态。
  List<PostCardData> postList = <PostCardData>[];
  int postPage = 1;
  bool postsLoaded = false;
  final PullRefreshController postPullRefresh = PullRefreshController();

  late TabController tabController;
}
