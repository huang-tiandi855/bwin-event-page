import 'package:comics_app/common/entities/comment/vod_comment_item_model.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/date_util.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 评论列表项（深色主题极简卡片）。
///
/// 直接消费 [VodCommentItemModel]，渲染：
/// - 头像 / 昵称（`account.avatar` / `account.nickName`）
/// - 评论正文（`comment.content`）
/// - 创建时间（`comment.createTime`，兼容 ISO 字符串 / 毫秒数字两种形态）
/// - 点赞按钮（取 `likeNum` 显示数字，`like` 决定填心/空心；点赞接口未给出
///   前 `onTapLike` 仍为占位空操作）
class VideoCommentItem extends StatelessWidget {
  const VideoCommentItem({
    super.key,
    required this.item,
    this.onTapAvatar,
    this.onTapLike,
  });

  final VodCommentItemModel item;

  /// 头像 / 昵称点击：默认跳用户中心；外部可覆盖。
  final VoidCallback? onTapAvatar;

  /// 点赞点击：默认空操作。后端补字段后由调用方接通真正接口。
  final VoidCallback? onTapLike;

  void _defaultGotoUserCenter() {
    final int uid = item.account?.id ?? 0;
    if (uid <= 0) return;
    Get.toNamed(
      AppRoutes.USER_CENTER,
      arguments: <String, dynamic>{
        'uid': uid,
        'author': <String, dynamic>{
          'id': uid,
          'avatar': item.account?.avatar,
          'nickName': item.account?.nickName,
          'authType': item.account?.authType,
          'introduce': item.account?.introduce,
          'follow': item.account?.follow,
          'beFollow': item.account?.beFollow,
          'fansNum': item.account?.fansNum,
          'starsNum': item.account?.starsNum,
          'sex': item.account?.sex,
          'vnum': item.account?.vnum,
          'pnum': item.account?.pnum,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String avatar = item.account?.avatar ?? '';
    final String name = (item.account?.nickName?.isNotEmpty == true)
        ? item.account!.nickName!
        : '匿名用户';
    final String content = item.comment?.content ?? '';
    final String dateStr = _formatDate(item.comment?.createDateTime);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapAvatar ?? _defaultGotoUserCenter,
            child: ClipOval(
              child: CustomImage(
                url: avatar,
                width: 40.w,
                height: 40.w,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapAvatar ?? _defaultGotoUserCenter,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.primaryText,
                    ),
                  ),
                ),
                SizedBox(height: 6.w),
                if (content.isNotEmpty)
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.4,
                      color: AppColor.primaryText.withOpacity(0.9),
                    ),
                  ),
                SizedBox(height: 10.w),
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const Spacer(),
                    _LikeChip(
                      liked: item.like,
                      likeNum: item.likeNum,
                      onTap: onTapLike,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    try {
      return DataFormats.formatDateYMD(dt.toIso8601String());
    } catch (_) {
      return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}';
    }
  }

  static String _pad(int v) => v < 10 ? '0$v' : '$v';
}

/// 点赞图标 + 数量。`liked` 切换实心 / 空心和颜色；`likeNum` 经 [getShowCountStr]
/// 友好化展示。点击包裹 [clickButton] 并打开 `openLimit` 走防抖，避免连点重复
/// 触发接口。
class _LikeChip extends StatelessWidget {
  const _LikeChip({
    required this.liked,
    required this.likeNum,
    this.onTap,
  });

  final bool liked;
  final int likeNum;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color =
        liked ? const Color(0xFFF92B6C) : Colors.white.withOpacity(0.7);
    return clickButton(
      onTap: onTap,
      openLimit: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            liked ? Icons.favorite : Icons.favorite_border,
            size: 18.w,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            getShowCountStr(likeNum),
            style: TextStyle(fontSize: 12.sp, color: color),
          ),
        ],
      ),
    );
  }
}
