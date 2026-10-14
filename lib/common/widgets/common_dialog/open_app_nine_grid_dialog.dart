import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/routers/app_navigator.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:comics_app/common/utils/extensions/string_extensions.dart';
import 'package:comics_app/common/utils/ads_manage/ads_info_list_extension.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';

/// 首页九宫格弹窗（对应 `INDEX_TIP_GUILD` 广告位）。
///
/// 注：文件名/类名里的 "Nine" 只是沿用业务侧"九宫格"叫法；实际按 4 列网格
/// 自适应行数，不强制一定要 9 个广告。
///
/// - 整屏半透明遮罩 `#181818B2`，点击空白处不关闭，避免误触；
/// - 每行 4 列，单元 63×63，下方一行标题文案；
/// - 单个 item 点击触发 [AppNavigator.jumpAdv] 跳广告外链；
/// - 底部 X 关闭按钮使用 `assets/images/home/image_close.png`。
Future<void> openAppNineGridDialog({required List<AdsInfoList> ads}) {
  return Get.dialog(
    AppNineGridDialog(ads: ads),
    barrierColor: Colors.transparent,
    barrierDismissible: false,
    useSafeArea: false,
  );
}

class AppNineGridDialog extends StatelessWidget {
  const AppNineGridDialog({super.key, required this.ads});

  final List<AdsInfoList> ads;

  static const _bgColor = Color(0xB2181818);
  static const _textColor = Color(0xFFD9D9D9);
  static const int _columns = 4;
  static const double _iconSize = 63;
  static const double _columnGap = 5;
  static const double _rowGap = 5;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    double row = 4.5;
    final count = (ads.length / _columns).ceil();
    if (count < row) {
      row = count.toDouble();
    }
    final height = row * (_iconSize.w + 6.w + 20.w) + _columnGap.w * (row - 1);

    return Stack(
      alignment: Alignment.center,
      children: [
        getPhotoMaskView(
          sigmaXY: 2.0,
          color: Colors.transparent,
        ),
        Material(
          type: MaterialType.transparency,
          child: Container(
            width: media.size.width,
            height: media.size.height,
            color: _bgColor,
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              top: media.padding.top + 12.h,
              bottom: media.padding.bottom + 24.h,
              left: 25.w,
              right: 25.w,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: height, child: _buildGrid()),
                SizedBox(height: 30.w),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.back(),
                  child: AssetsGen.images.home.imageClose
                      .image(width: 40.w, height: 40.w),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    if (ads.isEmpty) return const SizedBox.shrink();
    //获取五个字的宽度
    final textPainter = TextPainter(
      text: TextSpan(
          text: '六六个字宽度 ',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final fiveWordsWidth = textPainter.width;
    //水平间距
    double horizontalSpacing =
        (Screen.width - fiveWordsWidth * _columns - 50.w) / (_columns - 1);
    final imgSpacing =
        (Screen.width - AppNineGridDialog._iconSize.w * _columns - 50.w) /
            (_columns - 1);
    if (horizontalSpacing > imgSpacing) {
      horizontalSpacing = imgSpacing;
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: ads.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        mainAxisSpacing: _rowGap.w,
        crossAxisSpacing: horizontalSpacing,
        // 63 图标 + 6 间距 + 文字一行 ≈ 89，按宽度自适应：传 childAspectRatio
        // 让单元宽度撑满列宽、高度 = 图标 + 文字组合的固定高，避免文字被裁
        mainAxisExtent: _iconSize.w + 7.w + 20.w,
      ),
      itemBuilder: (_, index) => _GridItem(ad: ads[index]),
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem({required this.ad});

  final AdsInfoList ad;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ad.jumpAdvByType(AdsType.indexTipGuild),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              width: AppNineGridDialog._iconSize.w,
              height: AppNineGridDialog._iconSize.w,
              child: CustomImage(
                url: ad.resourceUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 7.w),
          Text(
            ad.title?.ellipsis(5) ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppNineGridDialog._textColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
