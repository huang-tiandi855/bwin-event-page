import 'package:comics_app/common/entities/circle/game_data_model.dart';
import 'package:comics_app/common/entities/circle/post_enums.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/location.dart';
import 'package:comics_app/common/widgets/MySliverDelegate.dart';
import 'package:comics_app/common/widgets/comment/comment_view.dart';
import 'package:comics_app/common/widgets/comment/post_detail_comment_bottom_bar.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/games_style.dart';
import 'package:comics_app/common/widgets/indicators/filled_rounded_rect_tab_indicator.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/circle/games/game_details/game_details_logic.dart';
import 'package:comics_app/pages/circle/games/game_details/game_details_state.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common/style/color.dart';

const Color _kTextGrey = Color(0xFF808080);
const Color _kFreeGreen = Color(0xFF51D14F);

class GameDetailsPage extends StatelessWidget {
  GameDetailsPage({Key? key}) : super(key: key) {
    logic = Get.put(GameDetailsLogic(), tag: tag);
  }

  final String tag = DateTime.now().millisecond.toString();
  late final GameDetailsLogic logic;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GameDetailsLogic>(
      tag: tag,
      builder: (_) {
        final GameDetailsState state = logic.state;
        final GameDataModel? post = state.game;
        return Scaffold(
          backgroundColor: AppColor.scaffoldBackground,
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(),
          body: post == null
              ? _buildLoadingBody(state)
              : _buildDetailBody(context, state, post),
          bottomNavigationBar: _buildBottomBar(state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text(
        '游戏详情',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: commonBack(color: Colors.white),
    );
  }

  Widget _buildLoadingBody(GameDetailsState state) {
    return Center(
      child: state.loadFailed
          ? Text(
              '加载失败',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
            )
          : const LoadingWidget(),
    );
  }

  Widget _buildDetailBody(
    BuildContext context,
    GameDetailsState state,
    GameDataModel post,
  ) {
    return ExtendedNestedScrollView(
      controller: state.scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(child: _headerBlock(context, post)),
          _buildPinnedTabHeader(post),
        ];
      },
      // body 必须直接是 TabBarView，中间不能再套 Column，否则 NestedScrollView
      // 无法把内外滚动串起来，下拉刷新/加载更多会失效。
      body: TabBarView(
        controller: logic.tabController,
        children: [
          _buildRelatedTab(),
          _buildCommentTab(state),
        ],
      ),
    );
  }

  /// Tab + 分割线 + 下间距一并钉住。
  Widget _buildPinnedTabHeader(GameDataModel post) {
    final double height = 48.w + 5.w + 1 + 5.w + 11.w;
    return SliverPersistentHeader(
      pinned: true,
      delegate: MySliverDelegate(
        maxHeight: height,
        minHeight: height,
        child: ColoredBox(
          color: AppColor.scaffoldBackground,
          child: Column(
            children: [
              SizedBox(
                height: 48.w,
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  controller: logic.tabController,
                  indicator: FilledRoundedRectTabIndicator(
                    color: AppColor.primaryButtonColor,
                    width: 11.w,
                    height: 3.w,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(3.r),
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.5),
                  labelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: [
                    const Tab(text: '相关推荐'),
                    Tab(child: _buildCommentTabLabel(post.comments)),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(
                  horizontal: AppLocation.appHorizontal,
                  vertical: 5.w,
                ),
                color: Colors.white.withOpacity(.15),
              ),
              SizedBox(height: 11.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTabLabel(int comments) {
    return Builder(
      builder: (context) {
        final style = DefaultTextStyle.of(context).style;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('评论', style: style),
            Transform.translate(
              offset: Offset(2.w, 0),
              child: Text(
                '$comments',
                style: style.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRelatedTab() {
    return GetBuilder<GameDetailsLogic>(
      tag: tag,
      id: 'related',
      builder: (_) {
        return PullRefreshView(
            controller: logic.state.relatedPullController,
            onRefresh: () => logic.loadRelatedPage(refresh: true),
            onLoading: () => logic.loadRelatedPage(refresh: false),
            retryOnTap: () => logic.loadRelatedPage(refresh: true),
            child: getGameFourGridStyle(
              isSliver: false,
              items: logic.state.relatedGames,
              onItemTap: (_, item) => logic.openRelatedGame(item),
            ));
      },
    );
  }

  Widget _buildCommentTab(GameDetailsState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppLocation.appHorizontal),
      child: CommentComponent(
        key: ValueKey(state.gameId),
        id: '${state.gameId}',
        type: CommentType.game,
        isNeedInnerScroll: true,
        isShowAllCommentsTitle: false,
      ),
    );
  }

  Widget _buildBottomBar(GameDetailsState state) {
    return GetBuilder<GameDetailsLogic>(
      tag: tag,
      id: 'bottom_bar',
      builder: (_) => PostDetailCommentBottomBar(
        postId: '${state.gameId}',
        commentType: CommentType.game,
        onSend: logic.onSend,
        onCollect: logic.onCollect,
        isCollect: state.isCollect,
      ),
    );
  }

  Widget _headerBlock(BuildContext context, GameDataModel post) {
    final GameDetailsState state = logic.state;
    final String updateLabel = _formatDate(post.displayTimeMs);

    return ColoredBox(
      color: AppColor.scaffoldBackground,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                height: 20 / 16,
              ),
            ),
            SizedBox(height: 10.w),
            Text(
              '更新时间:$updateLabel·浏览量:${post.displayViews}',
              style: TextStyle(
                color: _kTextGrey,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 16.w),
            Container(height: 1, color: const Color(0x80808080)),
            SizedBox(height: 16.w),
            _tagsSection(state),
            SizedBox(height: 16.w),
            _infoGrid(state),
            SizedBox(height: 16.w),
            Container(height: 1, color: const Color(0x80808080)),
            SizedBox(height: 16.w),
            Text(
              '游戏名称',
              style: TextStyle(
                color: _kTextGrey,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 10.w),
            Text(
              state.gameName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (state.intro.isNotEmpty) ...[
              SizedBox(height: 16.w),
              Text(
                '游戏简介',
                style: TextStyle(
                  color: _kTextGrey,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 10.w),
              GetBuilder<GameDetailsLogic>(
                tag: tag,
                id: 'intro',
                builder: (_) {
                  final bool expanded = state.introExpanded;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.intro,
                        maxLines: expanded ? null : 3,
                        overflow: expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          height: 18 / 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.w),
                      GestureDetector(
                        onTap: logic.toggleIntro,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              expanded ? '收起' : '展开全文',
                              style: TextStyle(
                                color: _kTextGrey,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Transform.rotate(
                              angle: expanded ? 3.14159 : 0,
                              child: AssetsGen.images.game.gameExpand
                                  .image(width: 14.w, height: 14.w),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            SizedBox(height: 16.w),
            Container(height: 1, color: const Color(0x80808080)),
            SizedBox(height: 16.w),
            Text(
              '游戏封面',
              style: TextStyle(
                color: _kTextGrey,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 12.w),
            _covers(state),
            SizedBox(height: 16.w),
            GetBuilder<GameDetailsLogic>(
              tag: tag,
              id: 'download',
              builder: (_) => _downloadPanel(context, post),
            ),
            SizedBox(height: 16.w),
            _metricsRow(post),
            SizedBox(height: 16.w),
            Container(
              height: 1,
              margin: EdgeInsets.only(bottom: 4.w),
              color: Colors.white.withOpacity(0.12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagsSection(GameDetailsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AssetsGen.images.game.gameTag.image(
              width: 15.w,
              height: 15.w,
            ),
            SizedBox(width: 4.w),
            Text(
              '游戏标签（${state.detailTags.length}）',
              style: TextStyle(
                color: _kTextGrey,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.w),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.w,
          children: state.detailTags
              .map(
                (t) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 22.w,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _infoGrid(GameDetailsState state) {
    Widget cell({
      required AssetGenImage icon,
      required String label,
      required Widget value,
    }) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon.image(width: 30.w, height: 30.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _kTextGrey,
                    fontSize: 9.sp,
                  ),
                ),
                value,
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: cell(
                  icon: AssetsGen.images.game.gameIconCategory,
                  label: '分类',
                  value: Text(
                    state.categoryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: cell(
                  icon: AssetsGen.images.game.gameIconLang,
                  label: '语言',
                  value: Text(
                    state.languageLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.w),
          Row(
            children: [
              Expanded(
                child: cell(
                  icon: AssetsGen.images.game.gameIconSize,
                  label: '游戏大小',
                  value: Text(
                    state.fileSize,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: cell(
                  icon: AssetsGen.images.game.gameIconPlatform,
                  label: '支持平台',
                  value: Container(
                    height: 18.w,
                    margin: EdgeInsets.only(top: 2.w),
                    child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF00FFD0).withOpacity(0.10),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(
                                    color: const Color(0xFF00FFD0),
                                    width: 0.25),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                state.platforms[index],
                                style: TextStyle(
                                  color: const Color(0xFF00FFD0),
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 4.w),
                        itemCount: state.platforms.length),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _covers(GameDetailsState state) {
    final List<String> urls = state.coverUrls;
    if (urls.isEmpty) return const SizedBox.shrink();
    return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: CustomImage(
                url: urls[index],
                fit: BoxFit.fitWidth,
                widthAndHeightAdaptive: true,
              ),
            ),
        separatorBuilder: (context, index) => SizedBox(height: 10.w),
        itemCount: urls.length);
  }

  Widget _downloadPanel(BuildContext context, GameDataModel post) {
    final GameDetailsState state = logic.state;
    final PostCostType cost = state.game?.costType ?? PostCostType.free;
    final bool revealed = state.downloadRevealed;

    final Color accent = switch (cost) {
      PostCostType.free => _kFreeGreen,
      PostCostType.gold => const Color(0xFFFFA100),
      PostCostType.vip => AppColor.primaryButtonColor,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0x22273E80),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                state.version,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3F3F).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(4.r),
                  border:
                      Border.all(color: const Color(0xFFFF3F3F), width: .75),
                ),
                child: Text(
                  '最新版本',
                  style: TextStyle(
                    color: const Color(0xFFFF3F3F),
                    fontSize: 8.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.w),
          Text(
            '发布时间：${_formatDate(post.displayTimeMs)}',
            style: TextStyle(color: _kTextGrey, fontSize: 10.sp),
          ),
          SizedBox(height: 4.w),
          Text(
            '文件大小：${state.fileSize}',
            style: TextStyle(color: _kTextGrey, fontSize: 10.sp),
          ),
          SizedBox(height: 12.w),
          Container(height: 1, color: Colors.white.withOpacity(0.15)),
          SizedBox(height: 12.w),
          if (revealed) _revealedDownloadBody(state) else _lockedMask(cost),
          SizedBox(height: 12.w),
          SizedBox(
            width: double.infinity,
            height: 48.w,
            child: ElevatedButton(
              onPressed: () => logic.onUnlockTap(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: Text(
                revealed ? '点击复制「下载地址」' : _ctaLabel(cost, post.gold),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lockedMask(PostCostType cost) {
    final String title;
    final String subtitle;
    final AssetGenImage lockAsset;
    final Color borderColor;
    switch (cost) {
      case PostCostType.free:
        title = '免费解锁';
        subtitle = '无需消耗任何费用 直接获取';
        lockAsset = AssetsGen.images.game.gameLockBody;
        borderColor = _kFreeGreen;
        break;
      case PostCostType.gold:
        title = '金币解锁';
        subtitle = '消耗${logic.state.game?.gold ?? 0}金币解锁';
        lockAsset = AssetsGen.images.game.gameLockGold;
        borderColor = const Color(0xFFFFA100);
        break;
      case PostCostType.vip:
        title = 'VIP免费';
        subtitle = '开通VIP会员后免费获取';
        lockAsset = AssetsGen.images.game.gameLockVip;
        borderColor = AppColor.primaryButtonColor;
        break;
    }

    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(10.r),
      dashPattern: const [4, 4],
      strokeWidth: 1,
      color: borderColor,
      child: Container(
        width: double.infinity,
        height: 90.w,
        margin: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            lockAsset.image(width: 28.w, height: 28.w),
            SizedBox(width: 12.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.w),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF82888A),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _revealedDownloadBody(GameDetailsState state) {
    final Color borderColor;
    final PostCostType cost = state.game?.costType ?? PostCostType.free;
    switch (cost) {
      case PostCostType.free:
        borderColor = _kFreeGreen;
        break;
      case PostCostType.gold:
        borderColor = const Color(0xFFFFA100);
        break;
      case PostCostType.vip:
        borderColor = AppColor.primaryButtonColor;
        break;
    }
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(10.r),
      dashPattern: const [4, 4],
      strokeWidth: 1,
      color: borderColor,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10.w),
        margin: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final link in state.downloadLinks) ...[
              if (link.platform.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 4.w),
                  child: Text(
                    link.platform,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () => logic.onCopyTap(link.url),
                child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 8.w, horizontal: 10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF051215),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          link.url,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            height: 1.4,
                          ),
                        ),
                      ),
                      Text('复制',
                          style:
                              TextStyle(color: Colors.white, fontSize: 12.sp)),
                    ],
                  ),
                ),
              ),
              if ((link.extractCode ?? '').isNotEmpty) ...[
                SizedBox(height: 6.w),
                Row(
                  children: [
                    Text(
                      '提取码:',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      link.extractCode!,
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 10.w),
            ],
            if (state.downloadLinks.isEmpty && state.downloadUrl.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF051215),
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: Text(
                  state.downloadUrl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                ),
              ),
            if (state.extractPassword.isNotEmpty)
              Row(
                children: [
                  Text(
                    '解压密码:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF051215),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                    child: Text(
                      state.extractPassword,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _ctaLabel(PostCostType cost, int gold) {
    switch (cost) {
      case PostCostType.free:
        return '免费获取下载方式';
      case PostCostType.gold:
        return '消耗$gold金币获取下载方式';
      case PostCostType.vip:
        return 'VIP免费获取下载方式';
    }
  }

  Widget _metricsRow(GameDataModel post) {
    final style = TextStyle(color: _kTextGrey, fontSize: 12.sp);
    Widget cell(Widget icon, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(width: 4.w),
            Text(text, style: style),
          ],
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: logic.onLike,
          child: GetBuilder<GameDetailsLogic>(
            tag: tag,
            id: 'like',
            builder: (_) => cell(
              _.state.isLike
                  ? AssetsGen.images.circle.postHeartSel
                      .image(width: 20.w, height: 20.w)
                  : AssetsGen.images.circle.postHeart
                      .image(width: 20.w, height: 20.w),
              post.displayLikes,
            ),
          ),
        ),
        GestureDetector(
          onTap: logic.onCollect,
          child: GetBuilder<GameDetailsLogic>(
            tag: tag,
            id: 'collection',
            builder: (_) => cell(
              AssetsGen.images.game.gemeCollection.image(
                width: 20.w,
                height: 20.w,
                color: _.state.isCollect ? AppColor.primaryButtonColor : null,
              ),
              post.displayCollect,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.SHARE_INVITE),
          child: cell(
            AssetsGen.images.circle.postShare.image(width: 20.w, height: 20.w),
            '分享',
          ),
        ),
        cell(
          AssetsGen.images.game.gameUnlockMetric.image(
            width: 20.w,
            height: 20.w,
          ),
          post.displayUnlock,
        ),
      ],
    );
  }

  static String _formatDate(int ms) {
    if (ms <= 0) return '';
    final DateTime t = DateTime.fromMillisecondsSinceEpoch(ms);
    final String mm = t.month.toString().padLeft(2, '0');
    final String dd = t.day.toString().padLeft(2, '0');
    return '${t.year}-$mm-$dd';
  }
}
