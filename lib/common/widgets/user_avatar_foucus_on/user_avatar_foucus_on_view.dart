import 'package:comics_app/common/entities/hot_topic_entity.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../generated/assets.dart';
import '../../utils/text_util.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import '../follow_button.dart';
import 'user_avatar_foucus_on_logic.dart';

class UserAvatarFoucusOnComponent extends StatelessWidget {
  final HotTopicList hotTopicList;
  final double? userWidth;
  final double? userHeight;

  UserAvatarFoucusOnComponent(this.hotTopicList,
      {Key? key, this.userWidth, this.userHeight})
      : super(key: key);

  final logic = Get.put(UserAvatarFoucusOnLogic());

  @override
  Widget build(BuildContext context) {
    String coverImg = hotTopicList.coverImg ?? "";
    String name = hotTopicList.name ?? "未知";
    String tagDesc = hotTopicList.tagDesc ?? "";
    int viewCount = hotTopicList.playCount ?? 0;
    int collectCount = hotTopicList.collCount ?? 0;
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.translucent,
      child: wrapShadow(
        79.w,
        double.infinity,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomImage(
                  width: userWidth ?? 55.w,
                  height: userHeight ?? 55.w,
                  url: coverImg,
                  borderRadius: BorderRadius.circular(8.w),
                ),
                SizedBox(width: 8.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 220.w),
                        child: Text(name,
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis),
                            maxLines: 1)),
                    Row(
                      children: [
                        leftIconAndText(Assets.svgStarTag, collectCount),
                        getWidth(8),
                        leftIconAndText(Assets.svgViewTag, viewCount),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 180.w),
                      child: Text(tagDesc,
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: const Color(0xFF999999),
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis),
                          maxLines: 1),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () => logic.collect(hotTopicList),
              child: GetBuilder<UserAvatarFoucusOnLogic>(
                  id: "collect",
                  builder: (logic) {
                    return FollowButton(
                        isFollow: (hotTopicList.hasCollected ?? false));
                  }),
            )
          ],
        ),
      ),
    );
  }
}

Widget leftIconAndText(String imagePath, int text) {
  return Row(
    children: [
      SvgPicture.asset(
        imagePath,
        width: 15.w,
        height: 15.w,
      ),
      Text(TextUtil.moreThan1wIndent(text),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: Color(0xFF999999),
          )),
    ],
  );
}

Widget wrapShadow(double height, double width, Widget childWidget) {
  return Container(
    constraints: BoxConstraints(maxHeight: height, maxWidth: width),
    margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0.w),
    padding: EdgeInsets.only(bottom: 11.w, left: 10.w, right: 12.w, top: 11.w),
    decoration: ShapeDecoration(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      shadows: [
        BoxShadow(
          color: const Color(0x7FAEAEC0),
          blurRadius: 8.w,
          offset: const Offset(3, 5),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: const Color(0xFFFFFFFF),
          blurRadius: 20.w,
          offset: const Offset(-3, -5),
          spreadRadius: 0,
        )
      ],
    ),
    child: childWidget,
  );
}
