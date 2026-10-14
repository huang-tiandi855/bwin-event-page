import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/res/r.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/widget.dart';
import 'package:comics_app/generated/assets.dart';
import 'package:comics_app/pages/bookshelf/bookshelf_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../common/style/location.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import '../widget/bookWidget.dart';
import 'photo_item_logic.dart';

class PhotoItemComponent extends StatelessWidget {
  const PhotoItemComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(PhotoItemLogic());
    final state = Get.find<PhotoItemLogic>().state;
    final bookShelfState = Get.find<BookshelfLogic>().state;
    return Padding(
        padding: EdgeInsets.only(left: AppLocation.appHorizontal, right: AppLocation.appHorizontal, top: 10.w),
        child: GetBuilder<PhotoItemLogic>(builder: (logic) {
          return PullRefreshView(
              onLoading: () => logic.onLoad(),
              onRefresh: () => logic.onRefresh(),
              retryOnTap: () => logic.onRefresh(),
              controller: state.pullRefreshController,
              child: state.list.isNotEmpty
                  ? MasonryGridView.builder(
                      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      itemCount: state.list.length,
                      itemBuilder: (_, index) {
                        VideoModel? model = logic.state.list[index];
                        final image = Stack(
                          children: [
                            CustomImage(
                              url: model.autoCover,
                              borderRadius: BorderRadius.circular(9.r),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: _buildFreeWidget(model),
                            ),
                          ],
                        );
                        return Stack(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  HistoryOperation.getInstance()
                                      ?.insertHistoryModel<VideoModel>(model, HistoryRecordType.picture);
                                  Get.toNamed(AppRoutes.PICTURE_GROUP_PREVIEW, arguments: {
                                    "seriesCover": model.seriesCover,
                                    'title': model.title,
                                    'hasCollect': model.vidStatus?.hasCollected ?? false,
                                    'id': model.id
                                  });
                                },
                                child: _buildItemLayout(image, model, index)),

                            /// 删除
                            Obx(() {
                              if (!bookShelfState.isEdit.value) {
                                return Positioned.fill(
                                  child: GestureDetector(
                                    onTap: () => logic.cancelCollectResponse(index),
                                    child: Container(
                                      color: Colors.black.withOpacity(0.72),
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(R.delete, width: 30.w),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            })
                          ],
                        );
                      })
                  : CustomScrollView(slivers: <Widget>[
                      /*GetBuilder<PhotoItemLogic>(
                  id: "list",
                  builder: (logic) {
                    return sliverGrid3(state.list,
                        isShowDelete: true, logic: logic,linkName: "书架-写真");
                  }),*/
                      GetBuilder<PhotoItemLogic>(
                          id: 'want',
                          builder: (logic) {
                            return state.wantToSeeList.isNotEmpty ? title() : const SliverToBoxAdapter();
                          }),
                      GetBuilder<PhotoItemLogic>(
                          id: 'want',
                          builder: (logic) {
                            return sliverGrid3(state.wantToSeeList, linkName: "书架-写真-猜你想看");
                          }),
                    ]));
        }));
  }

  Widget _buildFreeWidget(VideoModel? model) {
    return Visibility(
        visible: model?.originCoins == 0,
        child: Container(
          width: 32.w,
          height: 20.w,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('免费',
              style: TextStyle(
                  color: const Color(0xFF56FAF6), fontFamily: 'Dream', fontSize: 10.sp, fontWeight: FontWeight.w900)),
        ));
  }

  Widget _buildTitle({
    required String title,
    int maxLines = 1,
  }) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12.sp,
        color: const Color(0xFF000000),
        fontWeight: FontWeight.w600,
        height: 18 / 12,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildItemLayout(Widget image, VideoModel model, int index) {
    double imageHeight = index.isOdd ? 119 : 153;
    // double height = imageHeight + 51;
    return Container(
      // height: height.w,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(5.r),
          top: Radius.circular(10.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 119.w / imageHeight.w,
            child: image,
          ),
          if (model.title?.isNotEmpty == true)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
                vertical: 4.w,
              ).copyWith(bottom: 3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTitle(title: model.title ?? ''),
                  2.verticalSpaceFromWidth,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      rowIconAndText(
                          type: IconAndTextType.rightText,
                          iconPath: Assets.imagesPhotoViewCount,
                          iconSize: Size(16.w, 16.w),
                          text: TextUtil.moreThan1wIndent1(model.playCount ?? 0),
                          rightTextStyle: TextStyle(
                            color: const Color(0xFF777777),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                          )),
                      rowIconAndText(
                        type: IconAndTextType.rightText,
                        iconPath: Assets.imagesPhotoImgCount,
                        iconSize: Size(16.w, 16.w),
                        text: '${model.imgCount ?? 0}',
                        rightTextStyle: TextStyle(
                          color: const Color(0xFF777777),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
