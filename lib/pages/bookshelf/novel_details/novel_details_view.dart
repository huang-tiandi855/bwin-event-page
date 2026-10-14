import 'package:audioplayers/audioplayers.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/common/widgets/acg_section/acg_media_card.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import '../../../common/res/r.dart';
import '../../../common/store/event_tracking_manager.dart';
import '../../../common/widgets/comment/comment_view.dart';
import '../../../common/widgets/comment/msg_send/msg_send_view.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import '../../../common/widgets/space_widget.dart';
import '../../../generated/assets.dart';
import 'novel_details_logic.dart';
import 'novel_details_state.dart';

import 'package:comics_app/common/utils/logger.dart';

class NovelDetailsPage extends StatefulWidget {
  const NovelDetailsPage({super.key});

  @override
  State<NovelDetailsPage> createState() => _NovelDetailsPageState();
}

class _NovelDetailsPageState extends State<NovelDetailsPage> {
  late final logic = Get.put(NovelDetailsLogic());
  NovelDetailsState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff5f5f5),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Obx(() =>
              state.isLoading.value ? const LoadingWidget() : _body(context))),
    );
  }

  Widget _body(BuildContext context) {
    return Stack(
      children: [
        createBody(context),
        Positioned(
          bottom: 0,
          child: MsgSendComponent(
            id: state.mediaInfoEntity?.id ?? '',
            type: CommentType.media,
            sid: state.mediaInfoEntity?.contents[state.index].id,
          ),
        )
      ],
    );
  }

  Widget createBody(BuildContext context) {
    return NestedScrollView(
      controller: state.scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          if (state.mediaKind == MediaKind.mediaKindAudio)
            ...audioBGWidget(context)
          else
            customAppbar(context),
          GetBuilder(
              init: logic,
              id: "refreshInfo",
              builder: (_) {
                return chapterTitleWidget();
              }),
          GetBuilder(
              init: logic,
              id: "refreshInfo",
              builder: (_) {
                return chapterItem();
              }),
          if (state.mediaKind != MediaKind.mediaKindAudio)
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () async {
                  logic.clickItem(state.index);
                },
                child: Container(
                  height: 120.w,
                  width: 1.sw,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(Assets.acgNovalDetialBg),
                          fit: BoxFit.fitWidth)),
                  child: GetBuilder<NovelDetailsLogic>(
                      id: 'refreshOldEpisode',
                      builder: (logic) {
                        return Text(
                            state.index > 0
                                ? "续看第${state.mediaInfoEntity?.contents[state.index].episodeNumber}${state.mediaKind == MediaKind.mediaKindComics ? '话' : '章'}"
                                : '立即观看',
                            style: TextStyle(
                                fontSize: 18.sp,
                                color: const Color(0xffB09FD9),
                                fontWeight: FontWeight.w900));
                      }),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Container(
              width: 343,
              height: 1,
              margin: const EdgeInsets.only(bottom: 18, top: 10),
              color: const Color.fromRGBO(230, 230, 230, 1),
            ),
          ),
          state.mediaList.isNotEmpty
              ? title('探索发现')
              : const SliverToBoxAdapter(),
          if (state.mediaList.isNotEmpty == true)
            SliverPadding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppLocation.appHorizontal),
              sliver: sliverGrid3(),
            ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 18.w),
              height: 1.r,
              decoration: const BoxDecoration(color: AppColor.lineColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: AppLocation.appHorizontal,
                      bottom: AppLocation.appHorizontal),
                  child: Text(
                    "评论",
                    style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  width: 3.w,
                ),
                Text(
                  getShowCountStr(state.mediaInfoEntity?.countComment ?? 0),
                  style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.7,
                      color: const Color.fromRGBO(148, 214, 218, 1)),
                ),
              ],
            ),
          ),
        ];
      },
      body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: AppLocation.appHorizontal),
              child: GetBuilder(
                  init: logic,
                  id: "refreshInfo",
                  builder: (logic) {
                    return CommentComponent(
                      isShowAllCommentsTitle: false,
                      id: state.mediaInfoEntity?.id ?? '',
                      type: CommentType.media,
                      sId: state.mediaInfoEntity?.contents[state.index].id,
                    );
                  }))),
    );
  }

  ///章节
  Widget chapterTitleWidget() {
    int totalEpisode = state.mediaInfoEntity?.totalEpisode ?? 0;
    String chapter = "全$totalEpisode集";
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppLocation.appHorizontal),
        child: Column(
          children: [
            SizedBox(
              height: 18.w,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('选集',
                    style: TextStyle(
                        fontSize: 18.sp,
                        color: AppColor.black,
                        fontWeight: FontWeight.w500)),
                GestureDetector(
                  onTap: () {
                    EventTrackingManager().addEpisodeVideoDatas(
                        state.mediaInfoEntity?.id,
                        state.mediaInfoEntity?.title);
                    logic.openDirectory();
                    // logic.openNovelDirectory(state.mediaInfoEntity);
                  },
                  child: Row(
                    children: [
                      Text(chapter,
                          style: TextStyle(
                              fontSize: 15.sp, color: AppColor.black)),
                      // SizedBox(width: 5.w),
                      // SvgPicture.asset(R.rightTriangle, width: 9.w)
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget normalBGWidget() {
    return Positioned(
      left: 0,
      top: 0,
      width: 1.sw,
      height: 500,
      child: ShaderMask(
        //此处是背景透明度渐变的处理
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(0, 0, 0, 1),
              Color.fromRGBO(0, 0, 0, 1),
              Color.fromRGBO(0, 0, 0, 1),
              Color.fromRGBO(0, 0, 0, 0.9),
              Color.fromRGBO(0, 0, 0, 0.7),
              Color.fromRGBO(0, 0, 0, 0.5),
              Color.fromRGBO(0, 0, 0, 0.3),
              Color.fromRGBO(0, 0, 0, 0.1),
              Color.fromRGBO(0, 0, 0, 0.0),
            ],
          ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
        },
        blendMode: BlendMode.dstATop,
        child: CustomImage(
          width: 1.sw,
          height: 500,
          url: state.mediaInfoEntity?.verticalCover ?? "",
          borderRadius: BorderRadius.circular(6.r),
          widthAndHeightAdaptive: false,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  List<Widget> audioBGWidget(context) {
    return [
      SliverAppBar(
        leading: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: SvgPicture.asset(
                R.back,
                width: 20.w,
                height: 20.w,
                fit: BoxFit.contain,
              ),
            )),
        pinned: true,
        floating: false,
        title: GetBuilder(
          init: logic,
          id: "refreshInfo",
          builder: (_) {
            return Row(
              children: [
                Expanded(
                    child: Center(
                  child: Text(
                    state.mediaInfoEntity?.title ?? "",
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                )),
                createLikeBtn(state)
              ],
            );
          },
        ),
      ),
      SliverToBoxAdapter(
          child: GetBuilder(
              init: logic,
              id: "refreshInfo",
              builder: (_) {
                return SizedBox(
                  height: 500,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 26,
                        right: 26,
                        top: 20,
                        height: 500,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: ShaderMask(
                            //此处是背景透明度渐变的处理
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromRGBO(0, 0, 0, 1),
                                  Color.fromRGBO(0, 0, 0, 1),
                                  Color.fromRGBO(0, 0, 0, 1),
                                  Color.fromRGBO(0, 0, 0, 0.9),
                                  Color.fromRGBO(0, 0, 0, 0.7),
                                  Color.fromRGBO(0, 0, 0, 0.5),
                                  Color.fromRGBO(0, 0, 0, 0.3),
                                  Color.fromRGBO(0, 0, 0, 0.1),
                                  Color.fromRGBO(0, 0, 0, 0.0),
                                ],
                              ).createShader(Rect.fromLTRB(
                                  0, 0, bounds.width, bounds.height));
                            },
                            blendMode: BlendMode.dstATop,
                            child: CustomImage(
                              width: 1.sw,
                              height: 500,
                              url: state.mediaInfoEntity?.verticalCover ?? "",
                              borderRadius: BorderRadius.circular(6.r),
                              widthAndHeightAdaptive: false,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: audioPlayView(context))
                    ],
                  ),
                );
              }))
    ];
  }

  Widget audioPlayView(context) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      width: 1.sw,
      height: 100,
      child: Column(
        children: [
          GetBuilder<NovelDetailsLogic>(
              id: logic.PLAYID,
              builder: (_) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          logic.lastAudio();
                        },
                        child: Transform.rotate(
                            angle: -110,
                            child: SvgPicture.asset(
                              Assets.acgLastAudio,
                              width: 20,
                              fit: BoxFit.cover,
                            )),
                      ),
                      GestureDetector(
                        onTap: () {
                          logic.seek(-30000);
                        },
                        child: SvgPicture.asset(
                          Assets.acgPlayQuikSeek,
                          width: 20,
                          height: 20,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (logic.playerState != PlayerState.PLAYING) {
                            logic.play();
                          } else {
                            logic.pause();
                          }
                        },
                        child: SvgPicture.asset(
                          logic.playerState != PlayerState.PLAYING
                              ? Assets.acgPlayIcon
                              : Assets.acgPauseIcon,
                          width: 50,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          logic.seek(30000);
                        },
                        child: Transform.rotate(
                          angle: -110,
                          child: SvgPicture.asset(
                            Assets.acgPlayQuikSeek,
                            width: 20,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          logic.nextAudio();
                        },
                        child: SvgPicture.asset(
                          Assets.acgLastAudio,
                          width: 20,
                        ),
                      ),
                    ],
                  )),
          GetBuilder<NovelDetailsLogic>(
              id: logic.PLAYDURATIONID,
              builder: (_) => Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: logic.openChooseSpeed,
                        child: SvgPicture.asset(
                          Assets.acgSpeedIcon,
                          width: 24,
                        ),
                      ),
                      5.horizontalSpace,
                      Text(
                        logic.position != null
                            ? logic.position?.toString().split('.').first ??
                                "00:00"
                            : '00:00',
                        style: const TextStyle(
                            fontSize: 16.0, color: Colors.black),
                      ),
                      4.horizontalSpace,
                      Expanded(
                          child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 6,
                                trackShape: const RoundedRectSliderTrackShape(),
                                overlayColor: const Color(0xffB09FD9),
                              ),
                              child: Slider(
                                thumbColor: Colors.white,
                                activeColor: const Color(0xffB09FD9),
                                inactiveColor: Colors.black12,
                                max: 100,
                                onChanged: (value) {
                                  final duration = logic.duration;
                                  if (duration == null) {
                                    return;
                                  }
                                  l.d("$value");
                                  final position =
                                      (value / 100) * duration.inMilliseconds;
                                  logic.player?.seek(
                                      Duration(milliseconds: position.round()));
                                },
                                value: (logic.position != null &&
                                        logic.duration != null &&
                                        logic.position!.inMilliseconds > 0 &&
                                        logic.position!.inMilliseconds <
                                            logic.duration!.inMilliseconds)
                                    ? (logic.position!.inMilliseconds /
                                            logic.duration!.inMilliseconds) *
                                        100
                                    : 0.0,
                              ))),
                      4.horizontalSpace,
                      Text(
                        logic.duration != null ? logic.durationText : '00:00',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      5.horizontalSpace,
                      GestureDetector(
                        onTap: () {
                          logic.openClock();
                        },
                        child: SvgPicture.asset(
                          Assets.acgClockIcon,
                          width: 24,
                        ),
                      ),
                    ],
                  ))
        ],
      ),
    );
  }

  ///自定义AppBar
  Widget customAppbar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      title: Container(
        width: 1.sw,
        height: 48,
        alignment: Alignment.center,
        child: Obx(() => state.isShowTitle.value
            ? Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Image.asset(
                        "assets/images/png/app_back.png",
                        width: 26.w,
                        height: 26.w,
                      )),
                  24.horizontalSpace,
                  Expanded(
                      child: Center(
                    child: Text(
                      state.mediaInfoEntity?.title ?? "",
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                  )),
                  createLikeBtn(state)
                ],
              )
            : const Text('')),
      ),
      expandedHeight: 510.w,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: GetBuilder(
          init: logic,
          id: "refreshInfo",
          builder: (_) {
            return bgInfo(context);
          },
        ),
      ),
    );
  }

  Widget bgInfo(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        normalBGWidget(),
        Positioned(
          left: 0,
          bottom: 0,
          width: 1.sw,
          height: 80,
          child: ShaderMask(
            //此处是背景透明度渐变的处理
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.0),
                  Color(0xfff5f5f5),
                ],
              ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
            },
            blendMode: BlendMode.dstIn,
            child: Container(
              color: const Color(0xfff5f5f5),
            ),
          ),
        ),
        Positioned(
          top: 46,
          left: 16,
          child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Image.asset(
                "assets/images/png/app_back.png",
                width: 26.w,
                height: 26.w,
              )),
        ),
        Positioned(
          top: 46,
          right: 16,
          child: createLikeBtn(state),
        ),
        Positioned(bottom: 10, child: novelInfo(context)),
      ],
    );
  }

  ///小说介绍信息
  Widget novelInfo(BuildContext context) {
    String summary = state.mediaInfoEntity?.summary ?? "";
    String title = state.mediaInfoEntity?.title ?? "";
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width - 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 12.w),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black)),
                      SizedBox(height: 12.w),
                      createTags(),
                      GestureDetector(
                          child: Text(summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.c333333))),
                    ],
                  )
                ],
              ))
            ],
          ),
        ),
      ],
    );
  }

  Widget createTags() {
    return Wrap(
        children: state.mediaInfoEntity?.tagDetails
                .map((e) => GestureDetector(
                      onTap: () {
                        Get.offNamed(AppRoutes.TAGS_DETAIL, arguments: {
                          "title": e.name,
                          "kind": state.mediaInfoEntity?.kind,
                          "tags": e.id
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.only(right: 12.w, bottom: 10.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: const Color(0xffB09FD9),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                "#",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10.sp),
                              ),
                            ),
                            4.horizontalSpace,
                            Text(
                              "${e.name}",
                              style: TextStyle(
                                  color: const Color(0xffB09FD9),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList() ??
            []);
  }

  ///title
  Widget title(String text, {Color textColor = AppColor.black}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
            left: AppLocation.appHorizontal,
            right: AppLocation.appHorizontal,
            bottom: AppLocation.appHorizontal),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 18.sp, color: textColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  ///每行3个item
  Widget sliverGrid3() {
    return GetBuilder<NovelDetailsLogic>(
        init: logic,
        id: 'recommended',
        builder: (logic) {
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    state.mediaList.first.verticalCover != null ? 3 : 2,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.w,
                childAspectRatio: 113 / 216),
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              // List tagNames = state.mediaList[index].tagNames ?? [];
              var item = state.mediaList[index];
              return MediaCard.fromVideoModel(
                forceVerticalCover: item.verticalCover != null,
                AllMediaInfoModel.fromJson(item.toJson()),
                onTap: () {
                  logic.resetAnother(item.id);
                },
              );

              //   GestureDetector(
              //   onTap: () {
              //     logic.resetAnother(item.id);
              //     // Get.delete<NovelDetailsLogic>();
              //     // AppNavigator.to.jumpDetails(
              //     //   item.kind ?? 0,
              //     //   item.id ?? "",
              //     //   isOff: true,
              //     // );
              //   },
              //   child:
              //
              //   Container(
              //     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.start,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Stack(
              //           alignment: Alignment.center,
              //           children: [
              //             CustomImage(
              //               height: 162.w,
              //               url: verticalCover,
              //               borderRadius: BorderRadius.circular(8.w),
              //             ),
              //             Positioned(
              //               top: 6.6.w,
              //               right: 6.6.w,
              //               child: getPermissionIcon(permission, state.mediaList[index].price!),
              //             ),
              //             getBottomGridentShadow(
              //                 111.w,
              //                 isNeedBorderRadius: true,
              //                 state.mediaList[index].updateStatus,
              //                 state.mediaList[index].updatedDesc),
              //           ],
              //         ),
              //         SizedBox(
              //           height: 8.w,
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.only(left: 4.0),
              //           child: Text(
              //             title,
              //             maxLines: 1,
              //             overflow: TextOverflow.ellipsis,
              //             style: TextStyle(color: Colors.black, fontSize: 12.sp),
              //           ),
              //         ),
              //         SizedBox(
              //           height: 4.w,
              //         ),
              //         Padding(
              //             padding: const EdgeInsets.only(left: 4.0),
              //             child: getTagWidget(
              //                 state.mediaList[index].tagNames, state.mediaList[index].tags, state.mediaKind.index)),
              //       ],
              //     ),
              //   ),
              // );
            }, childCount: state.mediaList.length),
          );
        });
  }

  ///章节
  Widget chapterItem() {
    int curLength = state.mediaInfoEntity?.contents.length ?? 0;
    //String chapter = state.mediaKind == MediaKind.mediaKindComics ? "话" : "章";
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(top: 18.w),
        padding: EdgeInsets.symmetric(horizontal: AppLocation.appHorizontal),
        height: 70.w,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: curLength,
          itemBuilder: (context, index) {
            var item = state.mediaInfoEntity?.contents[index];
            int episodeNumber = index + 1;
            if (index < curLength) {
              episodeNumber = item?.episodeNumber ?? index + 1;
            }
            bool hasRead = item?.mediaStatus?.hasRead == true;
            int permission = item?.listenPermission ?? 0;
            double price = (item?.price)?.toDouble() ?? 0.0;
            return GestureDetector(
              onTap: () async {
                logic.clickItem(index);
              },
              child: Container(
                width: 50.w,
                height: 67.w,
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                    color: !hasRead && state.index != index
                        ? Colors.white
                        : AppColor.cf5f5f5,
                    border: Border.all(
                        width: 2,
                        color: hasRead || state.index == index
                            ? Colors.white
                            : Colors.black12),
                    borderRadius: BorderRadius.circular(8.w)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        '${episodeNumber > 9 ? episodeNumber : "0$episodeNumber"}',
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: const Color(0xffb09fd9),
                            fontWeight: FontWeight.w900)),
                    4.verticalSpace,
                    Align(
                      alignment: Alignment.center,
                      child: _getNovelIcon(permission, price),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

_getNovelIcon(int index, double price) {
  if (index == 0) {
    return SvgPicture.asset(R.vip, width: 31.w);
  } else if (index == 1 && price > 0) {
    return SvgPicture.asset(R.gold, width: 31.w);
  } else {
    return SvgPicture.asset(R.free, width: 31.w);
  }
}

Widget createLikeBtn(NovelDetailsState state) {
  return GetBuilder(
      id: 'collect',
      builder: (NovelDetailsLogic logic) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container(
            //   margin: const EdgeInsets.only(top: 2, right: 2),
            //   child: LikeButton(
            //     size: 18,
            //     isLiked: state.mediaInfoEntity?.mediaStatus?.hasLiked,
            //     circleColor: const CircleColor(
            //       start: Color.fromRGBO(253, 5, 99, 1),
            //       end: Color.fromRGBO(253, 5, 99, 1),
            //     ),
            //     bubblesColor: const BubblesColor(
            //       dotPrimaryColor: Color.fromRGBO(253, 5, 99, 1),
            //       dotSecondaryColor: Color.fromRGBO(253, 5, 99, 1),
            //     ),
            //     likeBuilder: (bool isLiked) {
            //       return isLiked
            //           ? SvgPicture.asset(
            //               R.likeed,
            //               width: 18.w,
            //               height: 18.w,
            //             )
            //           : SvgPicture.asset(
            //               Assets.acgLikeO,
            //               width: 18.w,
            //               height: 18.w,
            //             );
            //     },
            //     onTap: (isLike) async {
            //       await logic.cartoonLike();
            //       return state.mediaInfoEntity?.mediaStatus?.hasLiked;
            //     },
            //   ),
            // ),
            10.horizontalSpace,
            Container(
              margin: const EdgeInsets.only(left: 2, top: 2, right: 8),
              child: LikeButton(
                size: 18,
                isLiked: state.mediaInfoEntity?.mediaStatus?.hasCollected,
                circleColor: const CircleColor(
                  start: Colors.amberAccent,
                  end: Colors.amberAccent,
                ),
                bubblesColor: const BubblesColor(
                  dotPrimaryColor: Colors.amberAccent,
                  dotSecondaryColor: Colors.amberAccent,
                ),
                likeBuilder: (bool hasCollected) {
                  return SvgPicture.asset(
                    Assets.acgCollect,
                    width: 24.w,
                    color: hasCollected ? Colors.amberAccent : Colors.grey,
                    height: 24.w,
                  );
                  // : SvgPicture.asset(
                  //     Assets.acgCollect,
                  //     width: 24.w,
                  //     height: 24.w,
                  //   );
                },
                onTap: (isLike) async {
                  logic.cartoonCollcet();
                  return state.mediaInfoEntity?.mediaStatus?.hasCollected;
                },
              ),
            ),
          ],
        );
      });
}
