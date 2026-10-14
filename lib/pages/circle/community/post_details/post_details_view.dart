import 'package:comics_app/common/utils/system_ui_util.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/location.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_icon_group.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/common/widgets/comment/comment_view.dart';
import 'package:comics_app/common/widgets/comment/post_detail_comment_bottom_bar.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common/entities/circle/post_card_data.dart';
import '../../../../common/entities/circle/post_enums.dart';
import '../../../../common/store/user.dart';
import '../../../../common/style/color.dart';
import '../../games/game_details/game_pay_bottom_sheet.dart';
import 'post_details_logic.dart';
import 'post_details_state.dart';

const Color _kBgBlack = Color(0xFF000000);
const Color _kTextGrey = Color(0x80FFFFFF);

String _metricStr(int? n) {
  if (n == null || n <= 0) return '0';
  if (n >= 10000) return TextUtil.moreThan1wIndent(n);
  return '$n';
}

class PostDetailsPage extends StatelessWidget {
  final String tag = DateTime.now().millisecond.toString();
  late final PostDetailsLogic logic;
  late final PostDetailsState state;
  PostDetailsPage({Key? key}) : super(key: key) {
    logic = Get.put(PostDetailsLogic(), tag: tag);
    state = logic.state;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostDetailsLogic>(
      tag: tag,
      builder: (PostDetailsLogic _) {
        final state = logic.state;
        final PostCardData? post = state.postModel;
        return Scaffold(
          backgroundColor: _kBgBlack,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            toolbarHeight: kAppBarToolbarHeight,
            backgroundColor: _kBgBlack,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            centerTitle: true,
            title: Text(
              '帖子详情',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600),
            ),
            leading: commonBack(color: Colors.white),
          ),
          body: NestedScrollView(
            controller: state.scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: post == null
                      ? const SizedBox.shrink()
                      : _postHeaderSection(context, post),
                ),
              ];
            },
            body: Container(
              color: AppColor.scaffoldBackground,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppLocation.appHorizontal),
                child: CommentComponent(
                  key: ValueKey(state.postId),
                  id: state.postId.toString(),
                  type: CommentType.post,
                  isNeedInnerScroll: true,
                  isShowAllCommentsTitle: false,
                ),
              ),
            ),
          ),
          bottomNavigationBar: GetBuilder<PostDetailsLogic>(
              tag: tag,
              id: 'bottom_bar',
              builder: (_) {
                return PostDetailCommentBottomBar(
                  postId: state.postId.toString(),
                  onSend: logic.onSend,
                  onCollect: logic.onCollect,
                  isCollect: state.isCollect,
                );
              }),
        );
      },
    );
  }

  Widget _postHeaderSection(BuildContext context, PostCardData post) {
    final PostAuthor? author = post.account;
    final String portrait = author?.avatar ?? '';
    final String name = post.displayName;
    final String timeLabel = post.displayTime;
    final String tagName = post.displayTag;
    final PostCostType? costType = post.costType;
    final bool isGold = costType == PostCostType.gold && post.gold > 0;
    // bool isVip = false;
    bool hasVideo =
        post.sources.any((element) => element.type == PostSourceType.video);
    final bool needPay = post.needPay;
    final bool isLocked = isGold && needPay && hasVideo;

    return Container(
      color: AppColor.scaffoldBackground,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: logic.openAuthorCenter,
                  child: CustomImage(
                    width: 40.w,
                    height: 40.w,
                    url: portrait,
                    borderRadius: BorderRadius.circular(20.w),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 6.w),
                      Text(
                        timeLabel,
                        style: TextStyle(color: _kTextGrey, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
                GetBuilder<PostDetailsLogic>(
                  tag: tag,
                  id: 'focus',
                  builder: (_) => _FollowChip(
                    hasFollowed: logic.state.isFollow,
                    onTap: logic.focus,
                  ),
                ),
              ],
            ),
            if (post.title.isNotEmpty) ...[
              SizedBox(height: 16.w),
              Text(
                post.title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.5),
              ),
            ],
            if (tagName.isNotEmpty) ...[
              SizedBox(height: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.05),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Text(tagName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500)),
              ),
            ],
            if (post.title.isNotEmpty || tagName.isNotEmpty) ...[
              SizedBox(height: 16.w),
              Container(
                height: 1.w,
                color: Colors.white.withOpacity(.15),
              ),
            ],
            _SourcesSection(sources: post.sources, isLocked: isLocked),
            if (isLocked) ...[
              SizedBox(height: 16.w),
              _unlockView(context),
            ],
            // else if (isVip) ...[
            //   SizedBox(height: 16.w),
            //   _ctaPill(),
            // ],
            SizedBox(height: 16.w),
            Container(
              height: 1.w,
              color: Colors.white.withOpacity(.15),
            ),
            SizedBox(height: 16.w),
            _metricsRow(post),
            SizedBox(height: 16.w),
            const AdsBannerIconGroup(
              // bannerType: AdsType.bannerPosting,
              iconType: AdsType.dbLineHeadPosting,
            ),
            SizedBox(height: 16.w),
            Text(
              '${post.comments}条评论',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12.w),
            Container(
              height: 1,
              color: Colors.white.withOpacity(.15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unlockView(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.w,
      child: ElevatedButton(
        onPressed: () {
          showGamePayBottomSheet(
            context,
            unlockPrice: state.postModel?.gold ?? 0,
            coinBalance: UserStore.to.getUserInfoModel?.walletApp ?? 0,
            onUnlock: () {
              logic.onUnlock();
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryButtonColor,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: Text(
          '${state.postModel?.gold ?? 0}金币/立即解锁',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _metricsRow(PostCardData post) {
    final style = TextStyle(color: _kTextGrey, fontSize: 12.sp);
    Widget cell(Image image, String text) => Row(
          children: [
            image,
            SizedBox(width: 4.w),
            Text(text, style: style),
          ],
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        cell(AssetsGen.images.circle.postEye.image(width: 20.w, height: 20.w),
            _metricStr(post.watch)),
        SizedBox(width: 18.w),
        cell(
            AssetsGen.images.circle.postMessage
                .image(width: 20.w, height: 20.w),
            _metricStr(post.comments)),
        SizedBox(width: 18.w),
        GestureDetector(
          onTap: logic.onLike,
          child: GetBuilder<PostDetailsLogic>(
            tag: tag,
            id: 'like',
            builder: (logic) => cell(
                logic.state.isLike
                    ? AssetsGen.images.circle.postHeartSel
                        .image(width: 20.w, height: 20.w)
                    : AssetsGen.images.circle.postHeart
                        .image(width: 20.w, height: 20.w),
                _metricStr(post.perfect)),
          ),
        ),
        SizedBox(width: 18.w),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.SHARE_INVITE),
          child: cell(
              AssetsGen.images.circle.postShare
                  .image(width: 20.w, height: 20.w),
              "分享"),
        ),
      ],
    );
  }
}

/// 帖子正文区：按文字 / 图片的原始顺序还原段落，**视频段落统一排到最底部**
/// （多个视频之间保持原相对顺序），与产品规则「先正文后媒体」对齐。
///
/// 金币付费帖（[isLocked] 为 true）时仅视频段落整体替换为
/// [_HiddenMediaPlaceholder]；文字与图片不受影响（即使付费未解锁也可见）。
///
/// 无可渲染段落时返回 [SizedBox.shrink]，由上层间距合上。
class _SourcesSection extends StatelessWidget {
  const _SourcesSection({required this.sources, this.isLocked = false});

  final List<PostSourceItem> sources;

  /// 帖子需要金币时为 true，**仅** 视频段落统一替换为
  /// [_HiddenMediaPlaceholder]；文字与图片不受影响（产品规则：付费只锁视频）。
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    // 视频统一沉到最底部：先按原顺序铺非视频段落，再追加视频段落。
    // 同类内部的相对顺序保留，避免后端返回顺序对图文阅读体验造成跳跃。
    final List<PostSourceItem> nonVideos = <PostSourceItem>[];
    final List<PostSourceItem> videos = <PostSourceItem>[];
    for (final PostSourceItem s in sources) {
      if (s.type == PostSourceType.video) {
        videos.add(s);
      } else {
        nonVideos.add(s);
      }
    }
    final List<PostSourceItem> ordered = <PostSourceItem>[
      ...nonVideos,
      ...videos,
    ];

    // 全帖可点预览的图片 URL 串。预先抽出来一次，每个图片节点点击时
    // 把整组传给 [AppRoutes.PICTURE_PREVIEW]，落地后用 Swiper 横滑切图，
    // 与 `chat_bubble.dart` 走同一套 arguments 约定（seriesCover + index）。
    // 顺序与 [ordered] 中 image 段落一致 —— 图片本身不参与「视频沉底」
    // 重排，所以也就是后端返回的图片自然顺序。
    final List<String> previewImageUrls = <String>[
      for (final PostSourceItem s in ordered)
        if (s.type == PostSourceType.image && (s.source?.isNotEmpty ?? false))
          s.source!,
    ];

    final List<Widget> children = <Widget>[];
    for (final PostSourceItem s in ordered) {
      switch (s.type) {
        case PostSourceType.text:
          final String msg = s.msg ?? '';
          if (msg.isEmpty) continue;
          children.add(Padding(
            padding: EdgeInsets.only(top: 12.w),
            child: Text(
              msg,
              style: TextStyle(
                color: Colors.white.withOpacity(.8),
                fontSize: 12.5.sp,
                height: 1.55,
              ),
            ),
          ));
          break;
        case PostSourceType.image:
          final String url = s.source ?? '';
          if (url.isEmpty) continue;
          // `CustomImage` 在没给 `height` 时会把 height 也兜底成 double.infinity，
          // 父级 Column 在 SliverToBoxAdapter 里又是无限高约束 —— 会触发
          // 「BoxConstraints forces an infinite height」。
          // 后端给了 `wh` 就走精确 AspectRatio；否则 `widthAndHeightAdaptive`
          // 让 CachedNetworkImage 按真实像素自适配。
          final Widget image = s.aspectRatio != null
              ? CustomImage(
                  url: url,
                  fit: BoxFit.cover,
                  aspectRatio: s.aspectRatio!,
                  widthAndHeightAdaptive: true,
                )
              : CustomImage(
                  url: url,
                  fit: BoxFit.fitWidth,
                  widthAndHeightAdaptive: true,
                );
          // 用 [previewImageUrls] 里当前 url 的下标当起始页；List 里同 URL
          // 不会去重，所以 indexOf 命中的就是当前段落，与 list 里出现的视觉
          // 顺序一致。预览页内部 [PicturePreviewLogic] 会兜底 `index` 缺失。
          final int previewIndex = previewImageUrls.indexOf(url);
          children.add(Padding(
            padding: EdgeInsets.only(top: 12.w),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(
                  AppRoutes.PICTURE_PREVIEW,
                  arguments: <String, dynamic>{
                    'seriesCover': previewImageUrls,
                    'index': previewIndex < 0 ? 0 : previewIndex,
                  },
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.w),
                child: image,
              ),
            ),
          ));
          break;
        case PostSourceType.video:
          if (isLocked) {
            children.add(Padding(
              padding: EdgeInsets.only(top: 12.w),
              child: const _HiddenMediaPlaceholder(),
            ));
            break;
          }
          final String cover = s.screen ??
              (previewImageUrls.isNotEmpty ? previewImageUrls.first : '');
          final String videoUrl = s.source ?? '';
          children.add(Padding(
            padding: EdgeInsets.only(top: 12.w),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.SIMPLE_PLAYER, arguments: {
                  'videoUrl': videoUrl,
                  'coverUrl': cover,
                  'aspectRatio': s.aspectRatio,
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.w),
                    child: CustomImage(
                      url: cover,
                      fit: BoxFit.cover,
                      aspectRatio: s.aspectRatio ?? 16 / 9,
                    ),
                  ),
                  AssetsGen.images.circle.postPaly
                      .image(width: 44.w, height: 44.w),
                ],
              ),
            ),
          ));
          break;
        default:
          continue;
      }
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// 金币 / VIP 帖子里 [PostSourceType.video] 段落的占位，与
/// [PostDetailsPage._hiddenView] 视觉等价；抽成顶层 widget 是为了让
/// [_SourcesSection] 这种顶层私有类也能直接复用，避免反向依赖 Page 实例方法。
class _HiddenMediaPlaceholder extends StatelessWidget {
  const _HiddenMediaPlaceholder();

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(10.r),
      dashPattern: const [4, 4],
      strokeWidth: 1,
      color: const Color(0xFFC781FF),
      child: Container(
        width: double.infinity,
        height: 90.w,
        margin: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10.r),
        ),
        alignment: Alignment.center,
        child: Text(
          '内容已隐藏，解锁后查看',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}

class _FollowChip extends StatelessWidget {
  final bool hasFollowed;
  final VoidCallback onTap;

  const _FollowChip({required this.hasFollowed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.w),
        decoration: BoxDecoration(
          color: hasFollowed ? AppColor.c2b2748 : AppColor.primaryButtonColor,
          borderRadius: BorderRadius.circular(30.w),
        ),
        child: Text(
          hasFollowed ? '已关注' : '+ 关注',
          style: TextStyle(
            color: hasFollowed ? _kTextGrey : Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
