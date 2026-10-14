import 'package:comics_app/common/entities/module_detail_model/content_model.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common/utils/ads_manage/getAdv.dart';
import '../../../../common/utils/screen.dart';
import '../../../../common/utils/ads_manage/advSwiper.dart';
import '../../../../common/widgets/loading_widget.dart';

class PortrayBuildVIew extends StatelessWidget {
  final ContentModel? mediaInfoContents;
  final ScrollController scrollController;
  final double scale;
  const PortrayBuildVIew(this.mediaInfoContents, this.scrollController,
      {this.scale=1.0,Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List list = mediaInfoContents?.urlSet ?? [];
    return ListView.builder(
      controller: scrollController,
      itemBuilder: (BuildContext context, int index) {
        if (index == list.length && getAdsByType(AdsType.banner).isNotEmpty) {
          return Container(
            padding: EdgeInsets.only(
                left: AppLocation.appHorizontal,
                right: AppLocation.appHorizontal,
                bottom: (Screen.bottomSafeHeight + 80.w),
                top: 20.w),
            child: AspectRatio(
              aspectRatio: 3.6,
              child: AdvSwiper(advList: getAdsByType(AdsType.banner), adsType: AdsType.banner, aspectDatio: 3.6,),
            ),
          );
        } else {
          return Transform.scale(
              scale:scale,
              child: CustomImage(
                  url: list[index],
                  isCache:true,
                  widthAndHeightAdaptive: true,
                  loadingAndErrorWidget: SizedBox(
                    height: Get.width / 1.36,
                    child: const LoadingWidget(),
                  ))

          );
        }
      },
      itemCount:
          list.length + (getAdsByType(AdsType.banner).isNotEmpty ? 1 : 0),
    );
  }
}
