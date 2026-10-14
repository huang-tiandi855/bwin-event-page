import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/module_detail_model/content_model.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'short_media_play_page.dart';

class MediaEpisodeWidget extends StatelessWidget {
  final AllMediaInfoModel model;
  final Map<String, List<ContentModel>> pages;
  final int selectEpisode;
  final RxInt _selectIndex;
  final Function(int index)? choseCallBack;

  MediaEpisodeWidget(
    this.model, {
    super.key,
    this.selectEpisode = 1,
    this.choseCallBack,
  })  : _selectIndex = RxInt(selectEpisode),
        pages = model.pagination,
        _selectPage = RxInt(selectEpisode ~/ 30);

  final RxInt _selectPage;

  String get selectKey => pages.keys.elementAt(_selectPage.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(pages.length, (index) {
              final key = pages.keys.elementAt(index);
              return Obx(() {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _selectPage.value = index;
                  },
                  child: Container(
                    // constraints: const BoxConstraints(maxWidth: 91),
                    decoration: ShapeDecoration(
                      color: _selectPage.value == index
                          ? AppColor.primaryColor
                          : const Color(0xFF555555),
                      shape: const StadiumBorder(),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10.w,
                      horizontal: 30.w,
                    ),
                    margin: EdgeInsets.only(left: index == 0 ? 0 : 11.w),
                    alignment: Alignment.center,
                    child: Text(
                      key,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              });
            }).toList(),
          ),
        ),
        30.verticalSpaceFromWidth,
        LayoutBuilder(
          builder: (_, __) {
            final width = ((__.maxWidth - 7.w * 6) ~/ 7).toDouble();

            return Obx(() {
              return Wrap(
                spacing: 7.w,
                runSpacing: 8.w,
                children: List.generate(pages[selectKey]?.length ?? 0, (index) {
                  return _buildEpisodeItem(index, width);
                }).toList(),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildEpisodeItem(int index, double width) {
    final e = pages[selectKey]![index];
    final k = _selectPage.value * 30 + index;
    return Obx(
      () => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _selectEpisode(e, k);
        },
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: width,
              height: 43.w,
              decoration: BoxDecoration(
                  border: Border.all(
                    width: 1.w,
                    color: k == _selectIndex.value - 1
                        ? AppColor.primaryColor
                        : Colors.transparent,
                  ),
                  color: const Color(0xFF555555),
                  borderRadius: BorderRadius.circular(8.r)),
              alignment: Alignment.center,
              child: Text(
                '${e.episodeNumber ?? 0}'.padLeft(2, '0'),
                style: TextStyle(
                  color: AppColor.primaryColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'fonteditor',
                  height: 1.2,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: _buildEpisodePermission(e),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodePermission(ContentModel media) {
    if (media.listenPermission == 2) {
      return Image.asset(
        Assets.pngIcMediaFreeCornerMark,
        width: 14.w,
        height: 14.w,
      );
    } else if (media.listenPermission == 0) {
      return Image.asset(
        Assets.pngIcMediaVipCornerMark,
        width: 14.w,
        height: 14.w,
      );
    } else {
      return Container(
        width: 14.w,
        height: 14.w,
        decoration: BoxDecoration(
          gradient: AppColor.primaryGradient,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.r),
            bottomRight: Radius.circular(8.r),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          (media.price ?? 0).toStringAsFixed(0),
          style: TextStyle(
            fontFamily: 'fonteditor',
            fontSize: 10.sp,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  _selectEpisode(ContentModel content, int index) async {
    // final permission = content.listenPermission ?? 2;
    // if (permission == 0 && !(GlobalStore.isVIP_Cartoon())) {
    //   //2.会员视频，未充值会员
    //   var result = await Get.dialog(const VipDialogView());
    //   if (result != null && "toTaskPage" == result.toString()) {
    //     //进入任务中心
    //     // Get.to(SpecailWelfareViewTaskPage(), opaque: false);
    //   }
    //   if (result != null && "toPersonalCard" == result.toString()) {
    //     //进入邀请好友
    //     // Get.to(MineSharePage(), opaque: false);
    //   }
    //   if (result != null && result.toString() == "toMemberCenter") {
    //     //进入会员中心
    //     Get.to(() => const MineVipPage(selectIndex: 1));
    //   }
    // }

    // final controller = Get.find<media_episode_widget>();
    // controller.infos.add(model);
    // controller.entry = 2;
    // controller.jumpTo();
    // Get.back();
    if (choseCallBack != null) {
      choseCallBack?.call(index);
      Get.back();
      return;
    }
    Get.to(const ShortMediaPlayPage(), arguments: {
      'entry': 2,
      'info': [model],
      'selectIndex': index
    });
  }

  bool hasPermission(ContentModel content) {
    final permission = content.listenPermission ?? 2;

    if (permission == 2) return true;
    final isAcgV = UserStore.to.isVip();
    if (permission == 0) return isAcgV;
    return content.mediaStatus?.hasPaid ?? false;
  }
}
