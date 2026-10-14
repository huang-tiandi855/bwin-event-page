import 'package:comics_app/common/entities/circle/post_card_data.dart';
import 'package:comics_app/common/routers/app_navigator.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../pages/image/network/custom_image_network.dart';
import '../../style/color.dart';

/// 转发帖子卡片所需的数据模型，避免历史调用方在 `import 'post_card.dart'`
/// 之后还要额外 import 实体文件；新代码建议直接引用
/// `package:comics_app/common/entities/circle/post_card_data.dart`。
export 'package:comics_app/common/entities/circle/post_card_data.dart';

/// 社区信息流卡片：纵向卡片 UI，数据来源为 [PostCardData]。
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.singleImageAspectRatio = _defaultSingleImageAspectRatio,
    this.gridCellAspectRatio = _defaultGridCellAspectRatio,
    this.isCreationCenter = false,
    this.statusLabelOverride,
  });

  /// 单张大图模式的宽高比（width / height）。
  static const double _defaultSingleImageAspectRatio = 343 / 193;

  /// 三图网格每个 cell 的宽高比（width / height），默认 `1` 为正方形。
  static const double _defaultGridCellAspectRatio = 1;

  final PostCardData post;
  final double singleImageAspectRatio;
  final double gridCellAspectRatio;
  final bool isCreationCenter;

  /// 创作中心等场景下，外部按 Tab 强制指定状态文案（如「待审核」），
  /// 非 `null` 时优先使用，避免直接修改 [PostCardData.status]（后端 final 字段）。
  final String? statusLabelOverride;

  static const Color _mediaPlaceholder = Color(0xFF2C2C2C);

  @override
  Widget build(BuildContext context) {
    final uid = post.account?.id ?? 0;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!isCreationCenter)
                clickButton(
                  onTap: () => AppNavigator.to.go(
                    AppRoutes.USER_CENTER,
                    arguments: <String, dynamic>{
                      'uid': uid,
                      'author': <String, dynamic>{
                        'id': uid,
                        'avatar': post.account?.avatar ?? '',
                        'nickName': post.account?.nickName ?? '',
                        'follow': post.account?.follow ?? false,
                        'fansNum': post.account?.fansNum ?? 0,
                        'vnum': post.account?.vnum ?? 0,
                        'pnum': post.account?.pnum ?? 0,
                      },
                    },
                  ),
                  child: CustomImage(
                    url: post.account?.avatar ?? '',
                    width: 40.w,
                    height: 40.w,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              if (!isCreationCenter) SizedBox(width: 14.w),
              Expanded(
                child: SizedBox(
                  height: 40.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        isCreationCenter
                            ? post.displayCreateTime
                            : post.displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!isCreationCenter)
                        Text(
                          post.displayTime,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.5),
                            fontSize: 12.sp,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (isCreationCenter)
                _StatusChip(statusLabelOverride ?? post.displayStatusLabel),
            ],
          ),
          if (post.title.isNotEmpty) ...[
            SizedBox(height: 12.w),
            Text(
              post.title,
              style:
                  TextStyle(color: Colors.white, fontSize: 12.sp, height: 1.5),
            ),
          ],
          _buildMedia(
            singleImageAspectRatio: singleImageAspectRatio,
            gridCellAspectRatio: gridCellAspectRatio,
          ),
          SizedBox(height: 12.w),
          Row(
            children: [
              AssetsGen.images.circle.postEye.image(width: 20.w, height: 20.w),
              SizedBox(width: 4.w),
              Text(
                post.displayViews,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(.5),
                ),
              ),
              SizedBox(width: 14.w),
              AssetsGen.images.circle.postMessage
                  .image(width: 20.w, height: 20.w),
              SizedBox(width: 4.w),
              Text(
                post.displayComments,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(.5),
                ),
              ),
              SizedBox(width: 14.w),
              AssetsGen.images.circle.postHeart
                  .image(width: 20.w, height: 20.w),
              SizedBox(width: 4.w),
              Text(
                post.displayLikes,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(.5),
                ),
              ),
              const Spacer(),
              if (post.displayTag.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.w),
                  decoration: BoxDecoration(
                    color: AppColor.primaryButtonColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    post.displayTag,
                    style: TextStyle(fontSize: 12.sp, color: Colors.white),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.w),
          Container(
            height: 1.w,
            color: Colors.white.withOpacity(.15),
          ),
        ],
      ),
    );
  }

  /// 从 [PostCardData.sources] 取图片 / 视频段落，**视频统一排在前面**（保留
  /// 各自的原始相对顺序），合计最多 3 个；再根据数量决定版式：
  ///
  /// - 0 个 → [SizedBox.shrink]（不留空白，让上下间距自然合上）
  /// - 1 个 → 单张大图（[singleImageAspectRatio]）
  /// - 2~3 个 → 行内等分网格（[gridCellAspectRatio]）
  ///
  /// 视频封面取 [PostSourceItem.screen]（API 约定），缺封面就用占位底色 +
  /// 播放角标兜底；图片段落缺地址直接跳过，避免出现纯灰色 cell。
  Widget _buildMedia({
    required double singleImageAspectRatio,
    required double gridCellAspectRatio,
  }) {
    final video = post.sources
        .firstWhereOrNull((element) => element.type == PostSourceType.video);
    bool hasVideo = video != null;
    bool hasVideoHasScreen = video?.screen?.isNotEmpty ?? false;
    List<PostSourceItem> images = post.sources
        .where((element) =>
            element.type == PostSourceType.image &&
            (element.source?.isNotEmpty ?? false))
        .toList();
    String? placeholder;
    if (hasVideoHasScreen) {
      images.insert(0, video!);
    } else if (hasVideo) {
      final firstImage = images.firstOrNull;
      if (firstImage != null) {
        images.remove(firstImage);
      }
      placeholder = firstImage?.source;
      images.insert(0, video);
    }
    images = images.take(3).toList();
    if (images.isEmpty) return const SizedBox.shrink();

    final Widget body = images.length == 1
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: AspectRatio(
              aspectRatio: singleImageAspectRatio,
              child: _singleImageCell(images.first, placeholder),
            ),
          )
        : _buildGridMedia(
            count: images.length,
            gridCellAspectRatio: gridCellAspectRatio,
            itemBuilder: (i) => _mediaCell(images[i], placeholder),
          );
    // 与上方 avatar / 标题之间留 16，避免媒体直接贴住文字；
    // media 为空时不进这里，外层间距自然合上不会出现多余空白。
    return Padding(padding: EdgeInsets.only(top: 16.w), child: body);
  }

  /// 单格媒体：图片直接展示；视频用 `screen` 作封面 + 居中播放角标。
  Widget _mediaCell(PostSourceItem item, String? placeholder) {
    final bool isVideo = item.type == PostSourceType.video;
    final String? cover = isVideo ? (item.screen ?? placeholder) : item.source;
    final Widget background = Container(
      color: _mediaPlaceholder,
      child: (cover != null && cover.isNotEmpty)
          ? CustomImage(url: cover, fit: BoxFit.cover)
          : null,
    );
    if (!isVideo) return background;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        background,
        Center(
          child:
              AssetsGen.images.circle.postPaly.image(width: 30.w, height: 30.w),
        ),
      ],
    );
  }

  /// 单格媒体：图片直接展示；视频用 `screen` 作封面 + 居中播放角标。
  Widget _singleImageCell(PostSourceItem item, String? placeholder) {
    final bool isVideo = item.type == PostSourceType.video;
    final String? cover = isVideo ? (item.screen ?? placeholder) : item.source;
    final Widget background = Container(
      color: _mediaPlaceholder,
      child: (cover != null && cover.isNotEmpty)
          ? CustomImage(url: cover, fit: BoxFit.contain)
          : null,
    );
    if (!isVideo) return background;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        background,
        Center(
          child:
              AssetsGen.images.circle.postPaly.image(width: 30.w, height: 30.w),
        ),
      ],
    );
  }

  /// 行内等分媒体网格：以「3 列宽度」为单 cell 上限，[count] < 3 时各 cell
  /// 仍铺满整行（按 [count] 等分），避免出现尾部留白。
  Widget _buildGridMedia({
    required int count,
    required Widget Function(int index) itemBuilder,
    required double gridCellAspectRatio,
  }) {
    final spacing = 6.w;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - spacing * (count - 1)) / count;
        final itemHeight = itemWidth / gridCellAspectRatio;
        return Row(
          children: List.generate(
            count,
            (i) => Padding(
              padding: EdgeInsets.only(right: i < count - 1 ? spacing : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: itemBuilder(i),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    final isRejected = status == '未通过';
    final isPublished = status == '已发布';
    final color = isRejected
        ? const Color(0xFFFF2E55)
        : isPublished
            ? const Color(0xFF23C33B)
            : const Color(0xFF2E90FF);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 4.5.w),
      decoration: BoxDecoration(
        color: color.withOpacity(.19),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
