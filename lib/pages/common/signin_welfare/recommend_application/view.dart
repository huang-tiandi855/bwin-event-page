import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_widget.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/utils/extensions/string_extensions.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:comics_app/common/utils/ads_manage/ads_info_list_extension.dart';

/// 应用推荐 Tab。
class RecommendApplicationPage extends StatelessWidget {
  const RecommendApplicationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return getBgColorsView(
      child: Padding(
        padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight + 44.h),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdsBannerWidget(
                adsType: AdsType.recommendAppBanner,
                height: 140.h,
                radius: 8.r,
                padding: EdgeInsets.only(bottom: 18.h),
              ),
              GetBuilder<ConfigStore>(
                builder: (_) {
                  final List<AdsInfoList> apps =
                      getAdsByType(AdsType.recommendAppIcon);
                  if (apps.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: apps.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 60 / 84,
                    ),
                    itemBuilder: (context, index) =>
                        _ApplicationItem(item: apps[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplicationItem extends StatelessWidget {
  const _ApplicationItem({required this.item});

  final AdsInfoList item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => item.jumpAdvByType(AdsType.recommendAppIcon),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CustomImage(
              url: item.resourceUrl,
              width: 60.w,
              height: 60.w,
              fit: BoxFit.cover,
            ),
          ),
          7.h.verticalSpace,
          FittedBox(
            child: Text(
              (item.title ?? ''.ellipsis(5)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
