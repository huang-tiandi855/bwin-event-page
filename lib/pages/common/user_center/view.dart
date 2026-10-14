import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/media_info.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/common/widgets/MySliverDelegate.dart';
import 'package:comics_app/common/widgets/common_dialog/confirm_dialog.dart';
import 'package:comics_app/common/widgets/community_style.dart';
import 'package:comics_app/common/widgets/post_card/post_card.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/item/home_video_list_widgets.dart';
import 'package:comics_app/common/widgets/item/meida_cover_item.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/common/widgets/tab_widgets/tab_gradient_indicator_widget.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

/// 路由 `/userCenter` 的入口 Widget。
///
/// 与 [VideoPagePage] 类似：每次进入路由都会生成一份全局唯一的 [_logicTag] 并
/// 据此注册一份独立的 [UserCenterLogic]。这样可以保证「video_page → 用户中心
/// → 视频列表点视频 → video_page → 头像再进用户中心」等堆栈复用场景下，多个
/// 用户中心实例各自持有独立的 `PullRefreshController`，避免触发
/// `Don't use one refreshController to multiple SmartRefresher` 断言。
class UserCenterPage extends StatefulWidget {
  const UserCenterPage({super.key});

  @override
  State<UserCenterPage> createState() => _UserCenterPageState();
}

class _UserCenterPageState extends State<UserCenterPage> {
  late final String _logicTag;

  @override
  void initState() {
    super.initState();
    _logicTag =
        'user_center_${identityHashCode(this)}_${DateTime.now().microsecondsSinceEpoch}';
    Get.put<UserCenterLogic>(UserCenterLogic(), tag: _logicTag);
  }

  @override
  void dispose() {
    Get.delete<UserCenterLogic>(tag: _logicTag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _UserCenterPageView(logicTag: _logicTag);
  }
}

class _UserCenterPageView extends StatelessWidget {
  const _UserCenterPageView({Key? key, required this.logicTag})
      : super(key: key);

  /// 由 [_UserCenterPageState] 注入的 logic tag，内部 [GetBuilder] / `Get.find`
  /// 共用，保证拿到的是本路由专属实例。
  final String logicTag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserCenterLogic>(
      tag: logicTag,
      builder: (UserCenterLogic logic) {
        final UserCenterState state = logic.state;
        return WillPopScope(
          onWillPop: () async {
            // 系统返回 / 侧滑返回时同样把最新关注状态回传给入口页。
            logic.popWithResult();
            return false;
          },
          child: Scaffold(
            body: ExtendedNestedScrollView(
              pinnedHeaderSliverHeightBuilder: () {
                return kToolbarHeight + 48.w;
              },
              headerSliverBuilder: (_, __) => <Widget>[
                _UserCenterHeader(
                  user: state.userInfo,
                  isMe: logic.isMe,
                  isFollow: logic.isFollow,
                  onBackTap: logic.popWithResult,
                  onFollowTap: logic.toggleFollow,
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: MySliverDelegate(
                    maxHeight: 40.w,
                    minHeight: 40.w,
                    child: ColoredBox(
                      color: AppColor.scaffoldBackground,
                      child: TabGradientIndicatorTabBar(
                        controller: state.tabController,
                        useSigninWelfareDefaults: false,
                        tabAlignment: TabAlignment.fill,
                        labelPadding: EdgeInsets.zero,
                        indicatorWeight: 0,
                        indicatorUnderlineWidth: 20.w,
                        indicatorInsets: EdgeInsets.zero,
                        labelStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        tabs: [
                          for (final String tab in state.tabs) Tab(text: tab),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: state.tabController,
                children: <Widget>[
                  _UserVideoGrid(
                    items: state.movieList,
                    controller: state.moviePullRefresh,
                    onRefresh: logic.onRefreshMovies,
                    onLoadMore: logic.onLoadMoreMovies,
                    displayType: MediaCoverDisplayType.landscape,
                    emptyText: '暂无影片',
                  ),
                  _UserVideoGrid(
                    items: state.shortList,
                    controller: state.shortPullRefresh,
                    onRefresh: logic.onRefreshShorts,
                    onLoadMore: logic.onLoadMoreShorts,
                    displayType: MediaCoverDisplayType.shortvideo,
                    emptyText: '暂无抖音作品',
                    // 抖音作品强制走 [jumpShortMediaPlay]：默认
                    // [jumpMediaPlayByModel] 虽然也会按 videoType 路由到短视频，
                    // 但拿不到本页的分页 provider，进 [ShortVideoPlayPage] 后
                    // 无法续翻；这里把 logic 暴露的 [navigateToShortPlay] 接进来。
                    onItemClick: logic.navigateToShortPlay,
                  ),
                  _UserPostList(
                    items: state.postList,
                    controller: state.postPullRefresh,
                    onRefresh: logic.onRefreshPosts,
                    onLoadMore: logic.onLoadMorePosts,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UserCenterHeader extends StatelessWidget {
  const _UserCenterHeader({
    required this.user,
    required this.isMe,
    required this.isFollow,
    required this.onBackTap,
    required this.onFollowTap,
  });

  /// 透传自入口的作者信息，由 [MediaInfoAuthor.fromJson] 反序列化得到，
  /// 用户中心展示的头像 / 昵称 / 作品数 / 粉丝数全部读自这个对象。
  final MediaInfoAuthor? user;
  final bool isMe;
  final bool isFollow;
  final VoidCallback onBackTap;
  final VoidCallback onFollowTap;

  @override
  Widget build(BuildContext context) {
    final double expandedHeight = 283.w;
    return SliverAppBar(
      expandedHeight: expandedHeight,
      backgroundColor: Colors.black,
      elevation: 0,
      pinned: true,
      floating: false,
      automaticallyImplyLeading: false,
      leadingWidth: 52.w,
      leading: GestureDetector(
        onTap: onBackTap,
        child: Container(
          width: 36.w,
          height: 36.w,
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 12.w),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 22.w,
          ),
        ),
      ),
      // 展开态：title 透明（避免和大昵称 / 关注 / 私信按钮区域重叠）；
      // 上滑接近折叠时：通过 [AnimatedOpacity] 渐显，[FlexibleSpaceBar] 内置
      // 的位移/缩放动画会把 title 自然停到收起后的 toolbar 中央。
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double topPad = MediaQuery.of(context).padding.top;
          final double minH = kToolbarHeight + topPad;
          final double range =
              (expandedHeight - minH).clamp(1.0, double.infinity);
          // 0 = 完全展开，1 = 完全折叠
          final double collapseProgress =
              ((expandedHeight - constraints.biggest.height) / range)
                  .clamp(0.0, 1.0);
          // 接近折叠时（>0.85）才让 title 出现，避免半收起态时半透明字闪烁。
          final double titleOpacity = collapseProgress > 0.85 ? 1.0 : 0.0;
          return FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            centerTitle: true,
            titlePadding: const EdgeInsets.symmetric(vertical: 14),
            title: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: titleOpacity,
                child: Text(
                  user?.nickName ?? '用户',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            background: Stack(
              children: <Widget>[
                Positioned.fill(
                    child: AssetsGen.images.mine.icUserBackground.image()),
                // Positioned.fill(
                //   child: DecoratedBox(
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //         begin: Alignment.topCenter,
                //         end: Alignment.bottomCenter,
                //         colors: <Color>[
                //           Colors.black.withOpacity(0.18),
                //           Colors.black.withOpacity(0.35),
                //           Colors.black.withOpacity(0.88),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 22.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        CustomImage(
                          url: user?.avatar,
                          width: 88.w,
                          height: 88.w,
                          fit: BoxFit.cover,
                        ),
                        15.w.verticalSpace,
                        Text(
                          user?.nickName ?? '用户',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        6.w.verticalSpace,
                        Text(
                          '作品 ${getShowCountStr((user?.vnum ?? 0) + (user?.pnum ?? 0))}  |  粉丝 ${getShowCountStr(user?.fansNum ?? 0)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        20.w.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (!isMe)
                              getCommonButton(isFollow ? '已关注' : '+ 关注',
                                  width: 80.w,
                                  height: 34.w,
                                  radius: 100.r,
                                  onClick: onFollowTap,
                                  color: isFollow
                                      ? Colors.white.withOpacity(.1)
                                      : AppColor.primaryButtonColor,
                                  textStyle: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isFollow
                                        ? Colors.white60
                                        : Colors.white,
                                  )),
                            if (!isMe) 18.w.horizontalSpace,
                            getCommonButton(
                              '私信',
                              width: 80.w,
                              height: 34.w,
                              radius: 100.r,
                              color: Colors.white,
                              textStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              onClick: () => _onPrivateMessageTap(user?.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 「私信」按钮点击：弹会员开通确认对话框。
  ///
  /// 按产品要求：**不区分用户当前是否已是会员**，统一弹该提示，点击「前往会员」
  /// 跳到 [AppRoutes.MEMBER_CENTER]，点击「取消」关闭弹窗。后续真正的私信能力
  /// 接入后再走具体业务判断。
  Future<void> _onPrivateMessageTap(int? uid) async {
    if (uid == null) return;
    if (UserStore.to.isVip()) {
      Get.toNamed(AppRoutes.CHAT, arguments: {
        'uid': uid,
      });
      return;
    }
    final bool ok = await showConfirm(
      '温馨提示',
      '需开通会员，解锁私信功能',
      rightButtonTitle: '前往会员',
    );
    if (ok) {
      Get.toNamed(AppRoutes.MEMBER_CENTER);
    }
  }
}

class _UserVideoGrid extends StatelessWidget {
  const _UserVideoGrid({
    required this.items,
    required this.controller,
    required this.onRefresh,
    required this.onLoadMore,
    required this.displayType,
    this.emptyText = '暂无作品',
    this.onItemClick,
  });

  final List<MediaVideoModel> items;
  final PullRefreshController controller;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;
  final MediaCoverDisplayType displayType;
  final String emptyText;

  /// 可选的 item 点击回调；不传则 [getFourGrid] 内部走默认的
  /// [jumpMediaPlayByModel]（按 videoType 自动路由长 / 短视频）。
  final ValueChanged<int>? onItemClick;

  @override
  Widget build(BuildContext context) {
    return PullRefreshView(
      controller: controller,
      onRefresh: onRefresh,
      onLoading: onLoadMore,
      retryOnTap: onRefresh,
      emptyText: emptyText,
      emptyWidget: _UserCenterEmpty(text: emptyText),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          getFourGrid(
            items,
            sliver: true,
            sliverPadding: EdgeInsets.fromLTRB(16.w, 14.w, 16.w, 24.w),
            displayType: displayType,
            onItemClick: onItemClick,
          ),
        ],
      ),
    );
  }
}

/// 用户中心「帖子」Tab：复用 [getPostListStyle] 的纵向 [PostCard] 信息流。
///
/// 数据来自 [UserCenterLogic.onRefreshPosts] / [UserCenterLogic.onLoadMorePosts]，
/// 与影片 / 抖音 Tab 共用同一套 [PullRefreshView] 状态机（空 / 失败 / 加载中）。
class _UserPostList extends StatelessWidget {
  const _UserPostList({
    required this.items,
    required this.controller,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final List<PostCardData> items;
  final PullRefreshController controller;
  final VoidCallback onRefresh;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return PullRefreshView(
      controller: controller,
      onRefresh: onRefresh,
      onLoading: onLoadMore,
      retryOnTap: onRefresh,
      emptyText: '暂无帖子',
      emptyWidget: const _UserCenterEmpty(text: '暂无帖子'),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          getPostListStyle(
            items: items,
            onItemTap: (_, PostCardData item) =>
                jumpPostDetail(item.id.toString()),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 16.w)),
        ],
      ),
    );
  }
}

class _UserCenterEmpty extends StatelessWidget {
  const _UserCenterEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 14.sp,
        ),
      ),
    );
  }
}
