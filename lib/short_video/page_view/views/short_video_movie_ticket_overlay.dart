import 'package:comics_app/common/entities/video_model/ishort_video_model.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 短视频观影券付费浮层。
///
/// 视觉对齐长视频 [MovieTicketPlayerOverlay]，适配竖屏沉浸式：整屏
/// 半透明黑蒙层 + 居中文案 / 按钮，不绘制底部播放控件占位条。
///
/// 触发链路：`playerCode == 1008` / `1038` 且 `UserStore.movieTickets > 0`
/// 时由 [AbsShortVideoPlayLogic] 把 [ShortVideoAuthOverlay] /
/// [ShortVideoGoldOverlay] 替换为本浮层。
///
/// 仅一个真正可点的按钮 ——「使用观影券」。
/// 「跳过预览」是 UI 设计稿里的装饰元素，不绑回调；蒙层背景也不响应点击。
/// 一旦命中 ticket 浮层，用户唯一的退出路径就是用券。
class ShortVideoMovieTicketOverlay extends StatelessWidget {
  const ShortVideoMovieTicketOverlay({
    super.key,
    required this.videoInfo,
    required this.onUseTicketTap,
  });

  final ShortVideoModel videoInfo;

  /// 「使用观影券」按钮点击。
  final VoidCallback onUseTicketTap;

  @override
  Widget build(BuildContext context) {
    final int remainTickets = UserStore.to.getUserInfoModel?.movieTickets ?? 0;
    return GestureDetector(
      // 蒙层吃掉所有空白处的点击事件，与原 [ShortVideoAuthOverlay] /
      // [ShortVideoGoldOverlay] 的「点空白 dismiss」不同 —— ticket 浮层
      // 没有 dismiss 流程，避免误触关闭。
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '当前视频可使用观影券免费解锁',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            10.w.verticalSpace,
            Text(
              '剩余观影券:$remainTickets 张',
              style: TextStyle(
                color: Colors.white.withOpacity(.7),
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            18.h.verticalSpace,
            getConfirmButton(
              '使用观影券',
              width: 192.w,
              height: 30.h,
              radius: 100.r,
              onClick: onUseTicketTap,
              colors: const [
                Color(0XFFE16A20),
                Color(0XFFE13520),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
