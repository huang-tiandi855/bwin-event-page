import 'package:cached_network_image/cached_network_image.dart';
import 'package:comics_app/common/res/r.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/pages/image/network/image_cache_manager.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/pages/bookshelf/bookshelf_logic.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../common/entities/media_list_entity.dart';
import '../../../common/style/location.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import '../widget/bookWidget.dart';
import 'cartoon_item_logic.dart';

class CartoonItemComponent extends StatelessWidget {
  const CartoonItemComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CartoonItemLogic());
    final state = Get.find<CartoonItemLogic>().state;

    final bookShelfState = Get.find<BookshelfLogic>().state;
    final bookshelfLogic = Get.find<BookshelfLogic>();

    return Padding(
        padding: EdgeInsets.only(left: AppLocation.appHorizontal, right: AppLocation.appHorizontal, top: 10.w),
        child: GetBuilder<CartoonItemLogic>(builder: (logic) {
          return PullRefreshView(
              onLoading: () => logic.onLoad(),
              onRefresh: () => logic.onRefresh(),
              retryOnTap: () => logic.onRefresh(),
              //enablePullDown: state.list.isNotEmpty ? false : true,
              //enablePullUp: state.list.isNotEmpty ? false : true,
              controller: state.pullRefreshController,
              child: state.list.isNotEmpty
                  ? SingleChildScrollView(
                      child: StaggeredGrid.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: state.list.asMap().entries.map((e) {
                          MediaListMediaList item = state.list[e.key];
                          return GestureDetector(
                            onTap: () {
                              jumpPage(0, state.list[e.key].id);
                            },
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                              child: Container(
                                color: Colors.white,
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CachedNetworkImage(
                                          cacheManager: ImgCacheMgr(),
                                          imageUrl: e.value.verticalCover == null
                                              ? getPath(e.value.horizontalCover)
                                              : getPath(e.value.verticalCover),
                                          placeholder: (context, url) {
                                            return Image(
                                              image: () {
                                                return const AssetImage("assets/images/png/place_holder_image.png");
                                              }(),
                                              width: Screen.width / 2,
                                              height: 180,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          child: SizedBox(
                                            width: 32,
                                            height: 20,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 0,
                                                  top: 0,
                                                  child: Container(
                                                    width: 32,
                                                    height: 20,
                                                    decoration: ShapeDecoration(
                                                      color: Colors.black.withOpacity(0.7),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 6,
                                                  top: 4,
                                                  child: Text(
                                                    getProductPriceType(state.list[e.key].permission!),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Color(0xFF56FAF6),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w900,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            right: 6,
                                            bottom: 6,
                                            child: SizedBox(
                                              width: 78,
                                              height: 20,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                                                    decoration: ShapeDecoration(
                                                      color: Colors.white.withOpacity(0.7),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(11),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          (state.list[e.key].updateStatus == 2 ||
                                                                  state.list[e.key].updateStatus == 0)
                                                              ? '已完结·${state.list[e.key].totalEpisode}话'
                                                              : '更新中·${state.list[e.key].totalEpisode}话',
                                                          style: const TextStyle(
                                                            color: Color(0xFF3D169C),
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                        Obx(() => Offstage(
                                              offstage: bookShelfState.isEdit.value,
                                              child: GestureDetector(
                                                onTap: () async {
                                                  bool isOk = await bookshelfLogic.unCollect(
                                                      0, state.list[e.key].id.toString());
                                                  state.list.remove(e.value);
                                                  if (isOk) {
                                                    if (state.list.isEmpty) {
                                                      bookShelfState.isEdit.value = true;
                                                    }
                                                    logic.update();
                                                    showToast(msg: "移除成功");
                                                    return;
                                                  }
                                                  showToast(msg: "删除失败");
                                                },
                                                child: Container(
                                                  height:
                                                      TextUtil.isEmpty(state.list[e.key].verticalCover) ? 98 : 254,
                                                  color: Colors.black.withOpacity(0.72),
                                                  alignment: Alignment.center,
                                                  child: SvgPicture.asset(R.delete, width: 30.w),
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: SizedBox(
                                        width: 163,
                                        child: Text(
                                          '${item.title}',
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                        left: 10,
                                      ),
                                      child: Row(
                                        children: state.list[e.key].tagNames!.map((e) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 6,
                                            ),
                                            child: Text(
                                              e,
                                              style: const TextStyle(
                                                color: Color(0xFF999999),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : CustomScrollView(slivers: <Widget>[
                      GetBuilder<CartoonItemLogic>(
                          id: 'want',
                          builder: (logic) {
                            return state.wantToSeeList.isNotEmpty ? title() : const SliverToBoxAdapter();
                          }),
                      GetBuilder<CartoonItemLogic>(
                          id: 'want',
                          builder: (logic) {
                            return sliverGrid3(state.wantToSeeList, linkName: "书架-动漫-猜你想看");
                          }),
                    ]));
        }));
  }
}
