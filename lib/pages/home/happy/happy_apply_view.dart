import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/common/utils/ads_manage/ads_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../image/network/custom_image_network.dart';
import '../../loading/loading_center_widget.dart';
import 'Adv.dart';
import 'HappyModel.dart';
import 'ShuApp.dart';

class HappApplyView extends StatefulWidget {
  const HappApplyView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HappApplyViewState();
  }
}

class _HappApplyViewState extends State<HappApplyView> {
  List<Adv> advList = [];

  HappyModel? dataModel;

  List<AdsInfoBean> adsList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  bool dataIsNull() {
    bool app = dataModel?.hengApp?.isEmpty == true;
    bool ads = adsList.isEmpty;
    return app || ads;
  }

  Future<void> loadData() async {
    dataModel = await UserApi.happyList();
    if (dataModel != null) {
      dataModel?.adv?.forEach((element) {
        if (element.moduleType == 1) {
          advList.add(element);
        }
      });

      for (var element in advList) {
        adsList.add(AdsInfoBean(
            id: element.id,
            cover: element.image,
            href: element.url,
            title: element.name));
      }
      setState(() {});
    } else {
      debugPrint('loadData => dataModel == null ');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dataModel == null) {
      const SizedBox(
        height: 111,
        child: LoadingCenterWidget(),
      );
    }

    // if(dataIsNull()){
    //   return CErrorWidget(
    //     errorMsg: "暂无数据",
    //     retryOnTap: () {
    //       dataModel = null;
    //       setState(() {});
    //       loadData();
    //     },
    //   );
    // }

    return CustomScrollView(
      cacheExtent: 0,
      slivers: [
        // if (adsList.isNotEmpty == true)
        //   SliverToBoxAdapter(
        //     child: SizedBox(
        //       height: 156.w,
        //       // margin: const EdgeInsets.only(left: 16, right: 16),
        //       child: Swiper(
        //         onIndexChanged: (index) {
        //           //state.selectIndex = index;
        //         },
        //         itemBuilder: (BuildContext context, int index) {
        //           return GestureDetector(
        //               onTap: () {
        //                 var ad = adsList[index];
        //
        //                 UserApi.recreationList(ad.id ?? "", "adv");
        //
        //                 AppNavigator.to.jumpAdv(
        //                   id: ad.id.toString(),
        //                   title: ad.title.toString(),
        //                   url: ad.href.toString(),
        //                 );
        //               },
        //               child: CustomImage(
        //                 url: adsList[index].cover,
        //                 //height: 262.w,
        //                 aspectRatio: 2.39,
        //                 fit: BoxFit.fill,
        //               ),
        //           );
        //         },
        //         autoplayDelay: 5000,
        //         itemCount: adsList.length,
        //         autoplay: true,
        //         loop: true,
        //         pagination: (adsList.length ?? 0) > 1
        //             ? const SwiperPagination(
        //                 alignment: Alignment.bottomRight,
        //                 builder: DotSwiperPaginationBuilder(
        //                   activeColor: Color.fromRGBO(148, 214, 218, 1),
        //                   space: 6,
        //                   size: 6,
        //                   activeSize: 9,
        //                   color: Color.fromRGBO(48, 214, 218, 0.5),
        //                 ),
        //               )
        //             : null,
        //       ),
        //     ),
        //   ),
        _buildOfficalWidget(),
        _buildAppDownloadWidget()
      ],
    );
  }

  Widget _buildAppDownloadWidget() {
    if (dataModel?.shuApp?.isEmpty == true) {
      return Container();
    }
    Widget body = Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        margin: EdgeInsets.only(left: 12.w, top: 20.w, bottom: 20.w),
        height: 22,
        child: const Row(
          children: [
            Text(
              "热门应用",
              style: TextStyle(
                color: Color(0xFF292E2F),
                fontSize: 16,
                fontFamily: 'Dream',
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
      ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: dataModel?.shuApp?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          ShuApp? appInfo = dataModel?.shuApp![index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildAdAppItem(appInfo),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return getHeight(20);
        },
      )
    ]);

    return SliverToBoxAdapter(
        child: wrapShadow(double.infinity, double.infinity, body));
  }

  Widget _buildOfficalWidget() {
    if (dataModel?.hengApp?.isNotEmpty != true) {
      return const SliverToBoxAdapter();
    }
    return SliverToBoxAdapter(
        child: wrapShadow(
            1.sw,
            double.infinity,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 12.w, top: 20.w),
                  height: 22,
                  child: const Row(
                    children: [
                      Text(
                        "官方推荐",
                        style: TextStyle(
                          color: Color(0xFF292E2F),
                          fontSize: 16,
                          fontFamily: 'Dream',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dataModel?.hengApp?.length ?? 0,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 60 / 82,
                    crossAxisCount: 5,
                    mainAxisSpacing: 11,
                    crossAxisSpacing: 20, //横轴三个子widget/宽高比为1时，子widget
                  ),
                  itemBuilder: (context, index) {
                    ShuApp? appInfo = dataModel?.hengApp![index];
                    return InkWell(
                      onTap: () async {
                        await UserApi.recreationList(
                            appInfo.id.toString(), "app");

                        AppNavigator.to.jumpAdv(
                          id: appInfo.id.toString(),
                          title: appInfo.name.toString(),
                          url: appInfo.url.toString(),
                        planId: '', slotCode: '');
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: CustomImage(
                              url: appInfo?.icon,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          Text(
                            appInfo!.name.toString(),
                            style: TextStyle(
                                color: const Color(0xFF555555),
                                fontSize: 9.sp,
                                fontFamily: 'Dream',
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            )));
  }

  Widget wrapShadow(double height, double width, Widget childWidget) {
    return Container(
      // constraints: BoxConstraints(maxHeight: height,maxWidth: width),
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
      padding: EdgeInsets.only(bottom: 20.w),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0x7FAEAEC0),
            blurRadius: 20.w,
            offset: const Offset(5, 5),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFFFFFFFF),
            blurRadius: 20.w,
            offset: const Offset(-5, -5),
            spreadRadius: 0,
          )
        ],
      ),
      child: childWidget,
    );
  }

  Widget _buildAdAppItem(ShuApp? model) {
    return InkWell(
      onTap: () async {
        await UserApi.recreationList(model!.id.toString(), "app");
        AppNavigator.to.jumpAdv(
          id: model.id.toString(),
          title: model.name.toString(),
          url: model.url.toString(),
        planId: '', slotCode: '');
      },
      child: Column(
        children: [
          SizedBox(
            height: 50.w,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomImage(
                    url: model?.icon,
                    width: 50.w,
                    height: 50.w,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    model?.name ?? "",
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 28,
                  width: 72,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shadows: [
                      BoxShadow(
                        color: const Color(0xFFbdbdbd).withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "立即下载",
                    style: TextStyle(
                      color: Color(0xFFB09FD9),
                      fontSize: 12,
                      fontFamily: 'Dream',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          // Container(
          //   height: 1,
          //   color: const Color.fromRGBO(229, 229, 229, 1),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    PaintingBinding.instance.imageCache.clear();
    super.dispose();
  }
}
