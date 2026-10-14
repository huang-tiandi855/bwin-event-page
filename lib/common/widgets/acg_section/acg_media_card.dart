import 'dart:math';

import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/pages/home/tag_detail/tag_detail_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../generated/assets.dart';
import '../../utils/date_util.dart';
import '../../utils/utils.dart';

enum ACGItemCardWidget {
  horizontal,
  vertical,
}

class MediaCard extends StatelessWidget {
  const MediaCard(
      {super.key,
      this.axis = ACGItemCardWidget.vertical,
      this.verticalCover = false,
      this.url,
      this.title,
      this.tags,
      this.tagNames,
      this.views,
      this.permission,
      this.kind,
      this.updatedDesc,
      this.dateStr,
      this.rank,
      this.id,
      this.sequelStatus,
      this.sortCode,
      this.episodeTotal,
      this.index,
      this.isHotRank,
      this.itemAspectRatio,
      this.lightKeyWord,
      this.mediaList,
      this.price,
      this.isAd,
      this.onTap});

  final ACGItemCardWidget axis;
  final bool verticalCover;
  final String? url;
  final String? title;
  final List<String>? tags;
  final List<String?>? tagNames;
  final int? views;
  final int? permission;
  final int? kind;
  final String? updatedDesc;
  final String? dateStr;
  final String? id;
  final bool? rank;
  final int? sequelStatus;
  final int? episodeTotal;
  final int? sortCode;
  final bool? isHotRank;
  final int? index;
  final double? itemAspectRatio;
  final String? lightKeyWord;
  final GestureTapCallback? onTap;
  final List<AllMediaInfoModel>? mediaList;
  final double? price;
  final bool? isAd;

  factory MediaCard.fromVideoModel(AllMediaInfoModel model,
      {bool? forceVerticalCover,
      ACGItemCardWidget axis = ACGItemCardWidget.vertical,
      double? itemAspectRatio,
      String? lightKeyWord,
      GestureTapCallback? onTap,
      int? index,
      List<AllMediaInfoModel>? mediaList}) {
    return MediaCard(
        axis: axis,
        verticalCover: forceVerticalCover ?? model.isVerticalCover,
        url: forceVerticalCover == true ? model.coverV : model.coverH,
        title: model.title ?? '',
        tags: model.tags,
        tagNames: model.tagNames?.isNotEmpty == true ? model.tagNames : model.tagDetails.map((e) => e.name).toList(),
        views: model.countView ?? 0,
        permission: model.permission,
        dateStr: model.createdAt,
        id: model.id,
        kind: model.kind,
        episodeTotal: model.totalEpisode ?? mediaList?.length ?? 0,
        sequelStatus: model.updateStatus,
        lightKeyWord: lightKeyWord,
        mediaList: mediaList,
        index: index,
        isAd: model.isAd,
        onTap: onTap ??
            (model.isAd
                ? () {
                    AppNavigator.to.jumpAdv(
                      url: model.adUrl,
                      id: model.id,
                      title: model.title,
                      planId: '',
                      slotCode: '',
                    );
                  }
                : null),
        itemAspectRatio: itemAspectRatio);
  }

  factory MediaCard.fromVideoModelRank(
    AllMediaInfoModel model, {
    bool? forceVerticalCover,
    ACGItemCardWidget axis = ACGItemCardWidget.vertical,
    GestureTapCallback? onTap,
    List<AllMediaInfoModel>? mediaList,
    bool isShowSorCode = true,
    required int index,
  }) {
    return MediaCard(
      axis: axis,
      verticalCover: forceVerticalCover ?? model.isVerticalCover,
      url: forceVerticalCover == true ? model.coverV : model.coverH,
      title: model.title ?? '',
      tags: model.tags,
      tagNames: model.tagNames?.isNotEmpty == true ? model.tagNames : model.tagDetails.map((e) => e.name).toList(),
      views: model.countView ?? 0,
      permission: model.permission,
      dateStr: model.createdAt,
      id: model.id,
      kind: model.kind,
      rank: true,
      index: index,
      episodeTotal: model.totalEpisode,
      sequelStatus: model.updateStatus,
      sortCode: isShowSorCode ? index + 1 : null,
      mediaList: mediaList,
      onTap: onTap,
      isAd: model.isAd,
    );
  }

  factory MediaCard.fromVideoModelHotRank(AllMediaInfoModel model,
      {bool? forceVerticalCover,
      ACGItemCardWidget axis = ACGItemCardWidget.vertical,
      int? index,
      GestureTapCallback? onTap,
      List<AllMediaInfoModel>? mediaList}) {
    "card".printInfo(info: "${model.title}===>${model.horizontalCover}=hh==vv>${model.verticalCover}");
    return MediaCard(
        axis: axis,
        verticalCover: forceVerticalCover ?? model.isVerticalCover,
        url: forceVerticalCover == true ? model.coverV : model.coverH,
        title: model.title ?? '',
        tags: model.tags,
        tagNames: model.tagNames?.isNotEmpty == true ? model.tagNames : model.tagDetails.map((e) => e.name).toList(),
        views: model.countView ?? 0,
        permission: model.permission,
        dateStr: model.createdAt,
        episodeTotal: model.totalEpisode,
        sequelStatus: model.updateStatus,
        id: model.id,
        kind: model.kind,
        sortCode: index,
        mediaList: mediaList,
        onTap: onTap,
        index: index,
        isAd: model.isAd,
        isHotRank: true);
  }

  double get aspectRatio {
    if (!verticalCover) {
      return 161 / 91;
    } else {
      return 165 / 243;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = Stack(
      children: [
        CustomImage(
          url: url,
          borderRadius: BorderRadius.circular(9.r),
        ),
        if (rank != true)
          Positioned(
            top: 0,
            left: 0,
            child: _buildPermissionType(),
          ),
        // Positioned(
        //   bottom: 5.w,
        //   right: 5.w,
        //   child: _buildUpdateDesc(),
        // ),
        if (rank != true)
          Positioned(
            bottom: 5.w,
            right: 5.w,
            child: _buildSequel(),
          ),
        if (kind == 7)
          Positioned(
            bottom: 5,
            left: 5,
            child: SvgPicture.asset(
              Assets.acgNovalVoiceIcon,
              width: 15,
              height: 15,
            ),
          ),
        if (isHotRank == true) _hotRankWidget()
      ],
    );
    if (rank == true) {
      return _buildRandLayout(image);
    }
    if (axis == ACGItemCardWidget.horizontal) {
      return _buildHorizontalLayout(image);
    }
    return _buildVerticalLayout(image);
  }

  void jumpR() {
    AppNavigator.to.jumpDetails(kind ?? 0, id ?? "", modelList: mediaList, index: index);
  }

  Widget _buildHorizontalLayout(Widget image) {
    return GestureDetector(
      onTap: onTap ?? jumpR,
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: itemAspectRatio ?? aspectRatio,
            child: image,
          ),
          9.horizontalSpace,
          Expanded(
            child: SizedBox(
              height: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTitle(maxLines: 2),
                  10.verticalSpaceFromWidth,
                  Flexible(child: _buildTags()),
                  10.verticalSpaceFromWidth,
                  _buildDate(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRandLayout(Widget image) {
    return GestureDetector(
      onTap: onTap ?? jumpR,
      child: SizedBox(
          height: 99,
          width: 234,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                  top: 15,
                  left: 0,
                  bottom: 0,
                  child: Container(
                    height: 88,
                    width: 234,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -4))
                        ],
                        color: Colors.white),
                  )),
              Positioned(
                left: 10,
                bottom: 11,
                child: SizedBox(
                  height: 95,
                  width: 234,
                  child: Row(
                    children: [
                      AspectRatio(
                        aspectRatio: aspectRatio,
                        child: image,
                      ),
                      9.horizontalSpace,
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(top: 12, right: 12),
                          height: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (sortCode != null)
                                Text(
                                  sortCode! > 10 ? '$sortCode' : '0$sortCode',
                                  style: TextStyle(
                                      color: const Color(0xffB09FD9),
                                      fontSize: 20.sp,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w900),
                                ),
                              4.verticalSpaceFromWidth,
                              _buildTitle(maxLines: 2),
                              4.verticalSpaceFromWidth,
                              Flexible(child: _buildTags()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _hotRankWidget() {
    int rankIndex = sortCode ?? 0;
    return rankIndex < 3
        ? Positioned(
            right: 2,
            top: -3,
            child: rankIndex == 0
                ? Image.asset(
                    Assets.acgRange01,
                    width: 24.w,
                    height: 30.w,
                  )
                : rankIndex == 1
                    ? Image.asset(
                        Assets.acgRange02,
                        width: 24.w,
                        height: 30.w,
                      )
                    : rankIndex == 2
                        ? Image.asset(
                            Assets.acgRange03,
                            width: 24.w,
                            height: 30.w,
                          )
                        : Container(
                            alignment: Alignment.topRight,
                            width: 24.w,
                            height: 24.w,
                            decoration: const BoxDecoration(
                              image: DecorationImage(image: AssetImage(Assets.acgRankBottomBg)),
                            ),
                            child: Container(
                              width: 24.w,
                              height: 24.w,
                              alignment: Alignment.topRight,
                              decoration: const BoxDecoration(
                                image: DecorationImage(image: AssetImage(Assets.acgRankTopBg)),
                              ),
                              child: Text(
                                rankIndex < 9 ? "0${rankIndex + 1}" : (rankIndex + 1).toString(),
                                style: TextStyle(
                                    color: const Color.fromRGBO(255, 255, 255, 1),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 8.w),
                              ),
                            ),
                          ),
          )
        : Positioned(
            right: -3,
            top: 0,
            child: Container(
              alignment: Alignment.topRight,
              width: 24.w,
              height: 24.w,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage(Assets.acgRankBottomBg)),
              ),
              child: Stack(
                children: [
                  Container(
                    width: 24.w,
                    height: 26.w,
                    padding: const EdgeInsets.only(right: 4, top: 2),
                    alignment: Alignment.topRight,
                    child: Text(
                      rankIndex < 9 ? "0${rankIndex + 1}" : (rankIndex + 1).toString(),
                      style: TextStyle(
                          color: const Color.fromRGBO(255, 255, 255, 1),
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                  Container(
                    width: 24.w,
                    height: 26.w,
                    decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage(Assets.acgRankTopBg)),
                    ),
                  ),
                ],
              ),
            ));
  }

  Widget _buildVerticalLayout(Widget image) {
    return GestureDetector(
        onTap: onTap ?? jumpR,
        child: Container(
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
                aspectRatio: aspectRatio,
                child: image,
              ),
              if (title?.isNotEmpty == true || tags != null)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 4.w,
                    ).copyWith(
                      bottom: 8.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (title?.isNotEmpty == true) _buildTitle(),
                        2.verticalSpaceFromWidth,
                        Flexible(
                          child: Row(
                            children: [
                              Expanded(
                                child: tags != null ? _buildTags() : Container(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ));
  }

  Widget _buildTitle({
    int maxLines = 1,
  }) {
    return Text.rich(
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        TextSpan(
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF000000),
              fontWeight: FontWeight.w600,
              height: 18 / 12,
            ),
            children: [
              if (rank == true)
                WidgetSpan(
                  child: _buildSmallPermissionType(),
                ),
              TextSpan(
                text: title!,
              )
            ]));
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 6.w,
      clipBehavior: Clip.hardEdge,
      children: List.generate(min(tagNames?.length ?? 0, !verticalCover ? 5 : 3), (index) {
        final e = tagNames![index];
        bool isLightKey = (e == lightKeyWord);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Get.delete<TagDetailLogic>();
            Get.toNamed(AppRoutes.TAGS_DETAIL, arguments: {
              "title": e,
              "kind": kind,
              "tags": tags![index],
            });
          },
          child: Text(
            e ?? "",
            style: TextStyle(
              fontSize: 10.sp,
              color: isLightKey ? AppColor.cFC4162 : const Color(0xFF999999),
              height: 16 / 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSmallPermissionType() {
    if (permission == null) {
      return Container();
    }
    return Container(
      height: 18,
      width: 32,
      margin: const EdgeInsets.only(right: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        getProductPriceType(permission!),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: permission == 1
              ? const Color.fromRGBO(225, 226, 41, 1)
              : permission == 0
                  ? const Color.fromRGBO(222, 208, 255, 1)
                  : const Color(0xFF56FAF6),
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildPermissionType() {
    if (permission == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: 4.w,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        getProductPriceType(permission!),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: permission == 1
              ? const Color.fromRGBO(225, 226, 41, 1)
              : permission == 0
                  ? const Color.fromRGBO(222, 208, 255, 1)
                  : const Color(0xFF56FAF6),
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildSequel() {
    String desText;
    if (episodeTotal == null || isAd == true) {
      return Container();
    }
    if (sequelStatus == 2 || sequelStatus == 0) {
      desText = '已完结·$episodeTotal话';
    } else {
      desText = '更新中·$episodeTotal话';
    }
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 2.w),
        decoration: ShapeDecoration(
            color: Colors.white.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            )),
        child: Text(
          desText,
          style: const TextStyle(
            color: Color(0xFF3D169C),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget _buildDate() {
    return Text(
      DataFormats.utc2iso(dateStr),
      style: TextStyle(
        fontSize: 10.sp,
        color: const Color(0xFF999999),
      ),
    );
  }
}
