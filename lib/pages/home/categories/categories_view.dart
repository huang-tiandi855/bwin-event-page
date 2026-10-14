import 'dart:math';

import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/widgets/acg_section/acg_media_card.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common/entities/categories_entity.dart';
import '../../../common/widgets/empty_widget.dart';
import '../../../common/widgets/gradient_border_button.dart';
import '../../../common/widgets/space_widget.dart';
import '../../../generated/assets.dart';
import 'categories_logic.dart';
import 'categories_state.dart';

import 'package:comics_app/common/utils/logger.dart';
// class CategoriesPage extends StatelessWidget {
//   final logic = Get.find<CategoriesLogic>();
//   final state = Get.find<CategoriesLogic>().state;
//
//   CategoriesPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: commonAppBar("热门分类"),
//       body: GetBuilder<CategoriesLogic>(builder: (logic) {
//         return logic.state.categoriesEntity == null
//             ? LoadingWidget()
//             :
//
//         PullRefreshView(
//                 controller: state.pullRefreshController,
//                 onRefresh: () {
//                   state.pageNum = 1;
//                   logic.searchVideo(isLoadByScroll:true);
//                 },
//                 onLoading: () {
//                   state.pageNum = state.pageNum! + 1;
//                   logic.searchVideo(isLoadByScroll:true);
//                 },
//                 child: CustomScrollView(
//                   controller: state.scrollController,
//                   slivers: [
//                     SliverAppBar(
//                       //floating: true,
//                       // snap: true,
//                       pinned: false,
//                       // stretch: true,
//                       automaticallyImplyLeading: false,
//                       expandedHeight: 50.w +
//                           logic.state.categoriesEntity!.data!.list!.length *
//                               40.w,
//                       flexibleSpace: FlexibleSpaceBar(
//                         // title: contain,
//                         background: StatefulBuilder(
//                           builder: (contexts, setStates) {
//                             return Container(
//                               margin: EdgeInsets.only(
//                                   left: 12.w, right: 12.w, top: 10.w),
//                               child: Column(
//                                 children: [
//                                   SizedBox(
//                                     height: 22.w,
//                                     width: ScreenUtil().screenWidth,
//                                     child: Row(
//                                       children: [
//                                         Text(
//                                           "类型       ",
//                                           style: TextStyle(
//                                               fontSize: 13.sp,
//                                               fontWeight: FontWeight.w500,
//                                               color: AppColor.warmGrey),
//                                         ),
//                                         getWidth(30),
//                                         SizedBox(
//                                           width:
//                                               ScreenUtil().screenWidth - 110.w,
//                                           child: SingleChildScrollView(
//                                             scrollDirection: Axis.horizontal,
//                                             child: ValueBuilder<dynamic>(
//                                               initialValue: "",
//                                               builder: (value, updateFn) {
//                                                 return Row(
//                                                   children:
//                                                       logic.state.tabs.map((e) {
//                                                     if (state.isFirstEnter ??
//                                                         false) {
//                                                       value =
//                                                           logic.state.tabs[0];
//
//                                                       updateFn(
//                                                           logic.state.tabs[0]);
//                                                     }
//
//                                                     return e == "COS"
//                                                         ? const SizedBox()
//                                                         : Container(
//                                                             margin:
//                                                                 EdgeInsets.only(
//                                                                     right:
//                                                                         30.w),
//                                                             child:
//                                                                 GestureDetector(
//                                                               onTap: () {
//                                                                 updateFn(e);
//
//                                                                 if (e ==
//                                                                         "COS" ||
//                                                                     e == "真人") {
//                                                                   logic
//                                                                       .updateListView(
//                                                                           true);
//                                                                 } else {
//                                                                   logic.updateListView(
//                                                                       false);
//                                                                 }
//
//                                                                 logic
//                                                                     .state.selectedTags = List.generate(state.categoriesEntity?.data?.list?.length ?? 0, (index) => -1);
//                                                                 logic
//                                                                     .state
//                                                                     .mediaListInfo
//                                                                     ?.data
//                                                                     ?.mediaList!
//                                                                     .clear();
//
//
//                                                                 logic.state
//                                                                         .selectedKind =
//                                                                     state.tabs
//                                                                         .indexOf(
//                                                                             e);
//
//                                                                 logic.doInit(
//                                                                     state.tabs
//                                                                         .indexOf(
//                                                                             e));
//
//                                                                 //logic.setSelected(null, -1, "");
//                                                               },
//                                                               child: state.tabs[logic
//                                                                   .state
//                                                                   .selectedKind!] ==
//                                                                   e
//                                                                   ? Text(
//                                                                 e.toString(),
//                                                                 style:
//                                                                 TextStyle(
//                                                                   fontWeight: FontWeight.w800,
//                                                                   fontSize:
//                                                                   13.sp,
//                                                                   color:AppColor
//                                                                       .black,
//                                                                 ),
//                                                               ) : Text(
//                                                                 e.toString(),
//                                                                 style:
//                                                                     TextStyle(
//                                                                       fontWeight: FontWeight.w500,
//                                                                   fontSize:
//                                                                       13.sp,
//                                                                   color: AppColor
//                                                                       .warmGrey,
//                                                                 ),
//                                                               ),
//                                                             ));
//                                                   }).toList(),
//                                                 );
//                                               },
//                                               // 如果你需要调用 builder 方法之外的东西。
//                                               onUpdate: (value) => value = e,
//                                               onDispose: () => debugPrint(
//                                                   "Widget unmounted"),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   getHeight(18),
//                                   Column(
//                                     children: List.generate(logic.state.categoriesEntity!.data!.list!.length, (columnIndex) {
//                                       final listItem = logic.state.categoriesEntity!.data!.list![columnIndex];
//                                       return Container(
//                                         height: 22.w,
//                                         margin: EdgeInsets.only(bottom: 18.w),
//                                         //width: ScreenUtil().screenWidth,
//                                         child: Row(
//                                           children: [
//                                             Text(
//                                               listItem.name.toString(),
//                                               style: TextStyle(
//                                                   fontSize: 13.sp,
//                                                   fontWeight: FontWeight.w500,
//                                                   color: AppColor.warmGrey),
//                                             ),
//                                             getWidth(30),
//                                             Expanded(
//                                               child: SingleChildScrollView(
//                                                 scrollDirection:
//                                                 Axis.horizontal,
//                                                 child: ValueBuilder<dynamic>(
//                                                   initialValue: "",
//                                                   builder: (value, updateFn) {
//                                                     return Row(
//                                                       children: List.generate(listItem.tags?.length ?? 0, (rowIndex) {
//                                                         final tag = listItem.tags![rowIndex];
//                                                         final isSelected = state.selectedTags[columnIndex] == rowIndex;
//                                                         return Container(
//                                                             margin: EdgeInsets.only(right: 30.w),
//                                                             child: GestureDetector(
//                                                               onTap: () {
//                                                                 updateFn(e);
//                                                                 logic.setSelected(columnIndex,rowIndex);
//                                                               },
//                                                               child: Text(
//                                                                 tag.name.toString(),
//                                                                 style: TextStyle(
//                                                                   fontSize: 13.sp,
//                                                                   fontWeight: isSelected
//                                                                       ? FontWeight.w800 : FontWeight.w500 ,
//                                                                   color: isSelected
//                                                                       ? AppColor.black
//                                                                       : AppColor.warmGrey,
//                                                                 ),
//                                                               ),
//                                                             ));
//                                                       }),
//                                                     );
//                                                   },
//                                                   // 如果你需要调用 builder 方法之外的东西。
//                                                   onUpdate: (value) =>
//                                                   value = e,
//                                                   onDispose: () => debugPrint(
//                                                       "Widget unmounted"),
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     }),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     SliverOffstage(
//                       offstage: logic.state.isShowHeader ? false : true,
//                       sliver: SliverPadding(
//                         padding: EdgeInsets.only(left: 0.w, bottom: 0.w),
//                         sliver: SliverPersistentHeader(
//                           pinned: true,
//                           floating: true,
//                           delegate: MySliverDelegate(
//                             maxHeight: 40.w,
//                             minHeight: 40.w,
//                             child: GestureDetector(
//                               onTap: () {
//                                 l.d("111233233");
//                               },
//                               child: Container(
//                                 color: Colors.white.withOpacity(0.8),
//                                 padding: EdgeInsets.only(top: 6.w, left: 6.w),
//                                 child: Container(
//                                   alignment: Alignment.center,
//                                   child: Text(
//                                     state.selectedTagsName,
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 15.sp,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     GetBuilder<CategoriesLogic>(builder: (logic) {
//                       //  if(state.isLoading!){
//                       //    return SliverToBoxAdapter(child: LoadingWidget());
//                       //   }
//
//                       if (logic.state.mediaListInfo?.data?.mediaList?.length ==
//                           0) {
//                         // return SliverToBoxAdapter(child: Empty());
//                         //return SliverToBoxAdapter(child: LoadingWidget());
//                         return SliverToBoxAdapter(child: Container());
//                       } else {
//                         if (logic.state.isHorizontal) {
//                           List<Widget> lists = [];
//
//                           if (categoriesState
//                               .categoriesAdsHorizonal.isNotEmpty) {
//                             for (var element in (logic
//                                 .state.mediaListInfo!.data!.mediaList!)) {
//                               lists.add(Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Stack(
//                                     alignment: AlignmentDirectional.center,
//                                     children: [
//                                       GestureDetector(
//                                         onTap: () {
//
//
//                                           ConfigStore.to.trackData(
//                                               '作品点击',
//                                               ConfigStore.to
//                                                   .getClickProductInfoMap(element,"首页全部分类-${state.selectedTagsName}"));
//
//
//                                           if (element.kind == 0 ||
//                                               element.kind == 2 ||
//                                               element.kind == 3 ||
//                                               element.kind == 6) {
//                                             Get.toNamed(AppRoutes.VIDEO_PAGE,
//                                                 arguments: {"id": element.id});
//                                           } else {
//                                             if (element.kind == 5) {
//                                               jumpPage(
//                                                 element.kind,
//                                                 element.id,
//                                                 index: logic
//                                                     .state
//                                                     .mediaListInfo!
//                                                     .data!
//                                                     .mediaList!
//                                                     .indexOf(element),
//                                                 mediaList: logic
//                                                     .state
//                                                     .mediaListInfo
//                                                     ?.data
//                                                     ?.mediaList,
//                                               );
//                                             } else {
//                                               jumpPage(
//                                                   element.kind, element.id);
//                                             }
//                                           }
//                                         },
//                                         child: ClipRRect(
//                                           borderRadius: BorderRadius.all(Radius.circular(8.r)),
//                                           child: CustomImage(
//                                             url: element.horizontalCover,
//                                             fit: BoxFit.cover,
//                                             width: 171.w,
//                                             height: 96.w,
//                                             // borderRadius: const BorderRadius.all(
//                                             //     Radius.circular(6)),
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         top: 6.6,
//                                         right: 6.6,
//                                         child: getMarkIcon(
//                                             element.permission, element.price),
//                                       ),
//                                       Positioned(
//                                         bottom: 0,
//                                         child: ClipRRect(
//                                           borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8.r),bottomRight: Radius.circular(8.r)),
//                                           child: getBottomGridentShadow(
//                                               171.w,
//                                               element.updateStatus,
//                                               element.updatedDesc,isNeedPosition: false),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   getHeight(6),
//                                   SizedBox(
//                                       width: 171.w,
//                                       child: Text(
//                                         element.title ?? "",
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: TextStyle(
//                                             color: Colors.black,
//                                             fontSize: 12.sp),
//                                       )),
//                                   getHeight(2),
//                                   getTagWidget(
//                                       element.tagNames,
//                                       element.tags,
//                                       element.kind),
//                                 ],
//                               ));
//                             }
//                             for (int i = 0; i < lists.length; i++) {
//                               if ((i + 1) % 5 == 0) {
//                                 lists.insert(
//                                     i, getCategoriesHorizontalCoverListAds(i));
//                               }
//                             }
//                           }
//
//                           return SliverPadding(
//                             padding: EdgeInsets.only(left: 12.w, right: 12.w),
//                             sliver: SliverGrid(
//                               //Grid
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2, //横向数量
//                                 crossAxisSpacing: 6, //间距
//                                 mainAxisSpacing: 6, //行距
//                                 childAspectRatio: 171.w / 138.w,
//                               ),
//                               delegate: SliverChildBuilderDelegate(
//                                 (BuildContext context, int index) {
//                                   return categoriesState
//                                           .categoriesAds.isNotEmpty
//                                       ? lists[index]
//                                       :
//                                       //创建子widget
//                                       Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Stack(
//                                               alignment:
//                                                   AlignmentDirectional.center,
//                                               children: [
//                                                 GestureDetector(
//                                                   onTap: () {
//
//
//                                                     ConfigStore.to.trackData(
//                                                         '作品点击',
//                                                         ConfigStore.to
//                                                             .getClickProductInfoMap(MediaList.fromJson(logic.state.mediaListInfo?.data?.mediaList![index].toJson()),"首页全部分类-${state.selectedTagsName}"));
//
//
//                                                     if (logic.state.mediaListInfo?.data?.mediaList![index].kind == 0 ||
//                                                         logic
//                                                                 .state
//                                                                 .mediaListInfo
//                                                                 ?.data
//                                                                 ?.mediaList![
//                                                                     index]
//                                                                 .kind ==
//                                                             2 ||
//                                                         logic
//                                                                 .state
//                                                                 .mediaListInfo
//                                                                 ?.data
//                                                                 ?.mediaList![
//                                                                     index]
//                                                                 .kind ==
//                                                             3 ||
//                                                         logic
//                                                                 .state
//                                                                 .mediaListInfo
//                                                                 ?.data
//                                                                 ?.mediaList![
//                                                                     index]
//                                                                 .kind ==
//                                                             6) {
//                                                       Get.toNamed(
//                                                           AppRoutes.VIDEO_PAGE,
//                                                           arguments: {
//                                                             "id": logic
//                                                                 .state
//                                                                 .mediaListInfo
//                                                                 ?.data
//                                                                 ?.mediaList![
//                                                                     index]
//                                                                 .id
//                                                           });
//                                                     } else {
//                                                       if (logic
//                                                               .state
//                                                               .mediaListInfo
//                                                               ?.data
//                                                               ?.mediaList![
//                                                                   index]
//                                                               .kind ==
//                                                           5) {
//                                                         jumpPage(
//                                                           logic
//                                                               .state
//                                                               .mediaListInfo
//                                                               ?.data
//                                                               ?.mediaList![
//                                                                   index]
//                                                               .kind,
//                                                           logic
//                                                               .state
//                                                               .mediaListInfo
//                                                               ?.data
//                                                               ?.mediaList![
//                                                                   index]
//                                                               .id,
//                                                           index: index,
//                                                           mediaList: logic
//                                                               .state
//                                                               .mediaListInfo
//                                                               ?.data
//                                                               ?.mediaList,
//                                                         );
//                                                       } else {
//                                                         jumpPage(
//                                                             logic
//                                                                 .state
//                                                                 .mediaListInfo
//                                                                 ?.data
//                                                                 ?.mediaList![
//                                                                     index]
//                                                                 .kind,
//                                                             logic
//                                                                 .state
//                                                                 .mediaListInfo
//                                                                 ?.data
//                                                                 ?.mediaList![
//                                                                     index]
//                                                                 .id);
//                                                       }
//                                                     }
//                                                   },
//                                                   child: ClipRRect(
//                                                     borderRadius: BorderRadius.all(Radius.circular(8.r)),
//                                                     child: CustomImage(
//                                                       url: logic
//                                                           .state
//                                                           .mediaListInfo
//                                                           ?.data
//                                                           ?.mediaList![index]
//                                                           .horizontalCover,
//                                                       fit: BoxFit.cover,
//                                                       width: 171.w,
//                                                       height: 96.w,
//                                                       // borderRadius:
//                                                       //     const BorderRadius.all(
//                                                       //         Radius.circular(6)),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Positioned(
//                                                   top: 6.6,
//                                                   right: 6.6,
//                                                   child: getMarkIcon(
//                                                       logic
//                                                           .state
//                                                           .mediaListInfo
//                                                           ?.data
//                                                           ?.mediaList![index]
//                                                           .permission,
//                                                       logic
//                                                           .state
//                                                           .mediaListInfo
//                                                           ?.data
//                                                           ?.mediaList![index]
//                                                           .price),
//                                                 ),
//                                                 Positioned(
//                                                   bottom: 0,
//                                                   child: ClipRRect(
//                                                     borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8.r),bottomRight: Radius.circular(8.r)),
//                                                     child: getBottomGridentShadow(
//                                                         171.w,
//                                                         logic
//                                                             .state
//                                                             .mediaListInfo
//                                                             ?.data
//                                                             ?.mediaList![index]
//                                                             .updateStatus,
//                                                         logic
//                                                             .state
//                                                             .mediaListInfo
//                                                             ?.data
//                                                             ?.mediaList![index]
//                                                             .updatedDesc,isNeedPosition: false),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             getHeight(6),
//                                             SizedBox(
//                                                 width: 171.w,
//                                                 child: Text(
//                                                   logic
//                                                           .state
//                                                           .mediaListInfo
//                                                           ?.data
//                                                           ?.mediaList?[index]
//                                                           .title ??
//                                                       "",
//                                                   maxLines: 1,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   style: TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize: 12.sp),
//                                                 )),
//                                             getHeight(2),
//
//
//                                             getTagWidget(logic
//                                                 .state
//                                                 .mediaListInfo
//                                                 ?.data
//                                                 ?.mediaList?[index].tagNames,logic
//                                                 .state
//                                                 .mediaListInfo
//                                                 ?.data
//                                                 ?.mediaList?[index].tags,logic
//                                                 .state
//                                                 .mediaListInfo
//                                                 ?.data
//                                                 ?.mediaList?[index].kind),
//                                           ],
//                                         );
//                                 },
//                                 /* childCount: logic.state.mediaListInfo?.data
//                                     ?.mediaList?.length,*/
//                                 childCount:
//                                     categoriesState.categoriesAds.isNotEmpty
//                                         ? lists.length
//                                         : logic.state.mediaListInfo?.data
//                                             ?.mediaList?.length,
//                               ),
//                             ),
//                           );
//                         } else {
//                           List<Widget> lists = [];
//
//                           if (categoriesState.categoriesAds.isNotEmpty) {
//                             for (var element in (logic
//                                 .state.mediaListInfo!.data!.mediaList!)) {
//                               lists.add(Container(
//                                 //margin: EdgeInsets.only(left: 12.w,right: 12.w),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Stack(
//                                       children: [
//                                         GestureDetector(
//                                           onTap: () {
//
//
//                                             ConfigStore.to.trackData(
//                                                 '作品点击',
//                                                 ConfigStore.to
//                                                     .getClickProductInfoMap(element,"首页全部分类-${state.selectedTagsName}"));
//
//
//                                             if (element.kind == 0 ||
//                                                 element.kind == 2 ||
//                                                 element.kind == 3 ||
//                                                 element.kind == 6) {
//                                               Get.toNamed(AppRoutes.VIDEO_PAGE,
//                                                   arguments: {
//                                                     "id": element.id
//                                                   });
//                                             } else {
//                                               if (element.kind == 5) {
//                                                 jumpPage(
//                                                   element.kind,
//                                                   element.id,
//                                                   index: logic
//                                                       .state
//                                                       .mediaListInfo!
//                                                       .data!
//                                                       .mediaList!
//                                                       .indexOf(element),
//                                                   mediaList: logic
//                                                       .state
//                                                       .mediaListInfo
//                                                       ?.data
//                                                       ?.mediaList,
//                                                 );
//                                               } else {
//                                                 jumpPage(
//                                                     element.kind, element.id);
//                                               }
//                                             }
//                                           },
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.all(Radius.circular(8.r)),
//                                             child: CustomImage(
//                                               key: Key(element.verticalCover
//                                                   .toString()),
//                                               url: element.verticalCover,
//                                               fit: BoxFit.cover,
//                                               width: 111.w,
//                                               height: 162.w,
//                                               // borderRadius:
//                                               //     const BorderRadius.all(
//                                               //         Radius.circular(6)),
//                                             ),
//                                           ),
//                                         ),
//                                         Positioned(
//                                           top: 6.6,
//                                           right: 6.6,
//                                           child: getMarkIcon(element.permission,
//                                               element.price),
//                                         ),
//                                         Positioned(
//                                           bottom: 0,
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8.r),bottomRight: Radius.circular(8.r)),
//                                             child: getBottomGridentShadow(
//                                                 111.w,
//                                                 element.updateStatus,
//                                                 element.updatedDesc,isNeedPosition: false),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     getHeight(6),
//                                     SizedBox(
//                                         width: 111.w,
//                                         child: Text(
//                                           element.title ?? "",
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 12.sp),
//                                         )),
//                                     getHeight(2),
//                                     getTagWidget(
//                                           element.tagNames,
//                                           element.tags,
//                                           element.kind),
//                                   ],
//                                 ),
//                               ));
//                             }
//                             for (int i = 0; i < lists.length; i++) {
//                               if ((i + 1) % 5 == 0) {
//                                 lists.insert(
//                                     i, getCategoriesVerticalCoverListAds(i));
//                               }
//                             }
//                           }
//
//                           return SliverPadding(
//                             sliver: SliverGrid(
//                               //Grid
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 3, //横向数量
//                                 crossAxisSpacing: 0, //间距
//                                 mainAxisSpacing: 0, //行距
//                                 childAspectRatio: 111.w / 204.w,
//                               ),
//                               delegate: SliverChildBuilderDelegate(
//                                 (BuildContext context, int index) {
//                                   return categoriesState
//                                           .categoriesAds.isNotEmpty
//                                       ? lists[index]
//                                       :
//
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Stack(
//                                         children: [
//                                           GestureDetector(
//                                             onTap: () {
//
//                                               ConfigStore.to.trackData(
//                                                   '作品点击',
//                                                   ConfigStore.to
//                                                       .getClickProductInfoMap(MediaList.fromJson(logic.state.mediaListInfo?.data?.mediaList![index].toJson()),"首页全部分类-${state.selectedTagsName}"));
//
//                                               if (logic.state.mediaListInfo?.data?.mediaList![index].kind == 0 ||
//                                                   logic
//                                                       .state
//                                                       .mediaListInfo
//                                                       ?.data
//                                                       ?.mediaList![
//                                                   index]
//                                                       .kind ==
//                                                       2 ||
//                                                   logic
//                                                       .state
//                                                       .mediaListInfo
//                                                       ?.data
//                                                       ?.mediaList![
//                                                   index]
//                                                       .kind ==
//                                                       3 ||
//                                                   logic
//                                                       .state
//                                                       .mediaListInfo
//                                                       ?.data
//                                                       ?.mediaList![
//                                                   index]
//                                                       .kind ==
//                                                       6) {
//                                                 Get.toNamed(
//                                                     AppRoutes
//                                                         .VIDEO_PAGE,
//                                                     arguments: {
//                                                       "id": logic
//                                                           .state
//                                                           .mediaListInfo
//                                                           ?.data
//                                                           ?.mediaList![
//                                                       index]
//                                                           .id
//                                                     });
//                                               } else {
//                                                 if (logic
//                                                     .state
//                                                     .mediaListInfo
//                                                     ?.data
//                                                     ?.mediaList![
//                                                 index]
//                                                     .kind ==
//                                                     5) {
//                                                   jumpPage(
//                                                     logic
//                                                         .state
//                                                         .mediaListInfo
//                                                         ?.data
//                                                         ?.mediaList![
//                                                     index]
//                                                         .kind,
//                                                     logic
//                                                         .state
//                                                         .mediaListInfo
//                                                         ?.data
//                                                         ?.mediaList![
//                                                     index]
//                                                         .id,
//                                                     index: index,
//                                                     mediaList: logic
//                                                         .state
//                                                         .mediaListInfo
//                                                         ?.data
//                                                         ?.mediaList,
//                                                   );
//                                                 } else {
//                                                   jumpPage(
//                                                       logic
//                                                           .state
//                                                           .mediaListInfo
//                                                           ?.data
//                                                           ?.mediaList![
//                                                       index]
//                                                           .kind,
//                                                       logic
//                                                           .state
//                                                           .mediaListInfo
//                                                           ?.data
//                                                           ?.mediaList![
//                                                       index]
//                                                           .id);
//                                                 }
//                                               }
//                                             },
//                                             child: ClipRRect(
//                                               borderRadius: BorderRadius.all(Radius.circular(8.r)),
//                                               child: CustomImage(
//                                                 key: Key(state
//                                                     .mediaListInfo!
//                                                     .data!
//                                                     .mediaList![index]
//                                                     .verticalCover
//                                                     .toString()),
//                                                 url: state
//                                                     .mediaListInfo
//                                                     ?.data
//                                                     ?.mediaList![index]
//                                                     .verticalCover,
//                                                 fit: BoxFit.cover,
//                                                 width: 111.w,
//                                                 height: 162.w,
//                                                 // borderRadius:
//                                                 //     const BorderRadius
//                                                 //             .all(
//                                                 //         Radius.circular(
//                                                 //             6)),
//                                               ),
//                                             ),
//                                           ),
//                                           Positioned(
//                                             top: 6.6,
//                                             right: 6.6,
//                                             child: getMarkIcon(
//                                                 logic
//                                                     .state
//                                                     .mediaListInfo
//                                                     ?.data
//                                                     ?.mediaList![index]
//                                                     .permission,
//                                                 logic
//                                                     .state
//                                                     .mediaListInfo
//                                                     ?.data
//                                                     ?.mediaList![index]
//                                                     .price),
//                                           ),
//                                           Positioned(
//                                             bottom: 0,
//                                             child: ClipRRect(
//                                               borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8.r),bottomRight: Radius.circular(8.r)),
//                                               child: getBottomGridentShadow(
//                                                   111.w,
//                                                   state
//                                                       .mediaListInfo
//                                                       ?.data
//                                                       ?.mediaList![index]
//                                                       .updateStatus,
//                                                   state
//                                                       .mediaListInfo
//                                                       ?.data
//                                                       ?.mediaList![index]
//                                                       .updatedDesc,isNeedPosition: false),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       getHeight(6),
//                                       SizedBox(
//                                           width: 111.w,
//                                           child: Text(
//                                             logic
//                                                 .state
//                                                 .mediaListInfo
//                                                 ?.data
//                                                 ?.mediaList?[index]
//                                                 .title ??
//                                                 "",
//                                             maxLines: 1,
//                                             overflow:
//                                             TextOverflow.ellipsis,
//                                             style: TextStyle(
//                                                 color: Colors.black,
//                                                 fontSize: 12.sp),
//                                           )),
//                                       getHeight(2),
//
//
//                                       getTagWidget(logic
//                                           .state
//                                           .mediaListInfo
//                                           ?.data
//                                           ?.mediaList?[index].tagNames,logic
//                                           .state
//                                           .mediaListInfo
//                                           ?.data
//                                           ?.mediaList?[index].tags,logic
//                                           .state
//                                           .mediaListInfo
//                                           ?.data
//                                           ?.mediaList?[index].kind),
//                                     ],
//                                   );
//                                 },
//                                 childCount:
//                                     categoriesState.categoriesAds.isNotEmpty
//                                         ? lists.length
//                                         : logic.state.mediaListInfo?.data
//                                             ?.mediaList?.length,
//                                 //childCount: logic.state.mediaListInfo?.data?.mediaList?.length,
//                               ),
//                             ),
//                             padding: EdgeInsets.only(left: 12.w, right: 12.w),
//                           );
//                         }
//                       }
//                     }),
//                     SliverOffstage(
//                       offstage: state.isLoadingEmpty! ? false : true,
//                       sliver: SliverToBoxAdapter(
//                         child: Padding(
//                           padding: EdgeInsets.only(
//                               top: 13.w, bottom: 20.w,),
//                           child: Image.asset(
//                             "assets/images/png/cainixiangkanline.png",
//                             width: 343.w,
//                             height: 20.w,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SliverOffstage(
//                       offstage: state.isLoadingEmpty! ? false : true,
//                       sliver: GetBuilder<CategoriesLogic>(builder: (logic) {
//                         if (logic.state.isHorizontal) {
//                           List<Widget> lists = [];
//
//                           if (categoriesState
//                               .categoriesAdsHorizonal.isNotEmpty) {
//                             for (var element in (state.guessLikeMediaList)) {
//                               lists.add(Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Stack(
//                                     alignment: AlignmentDirectional.center,
//                                     children: [
//                                       GestureDetector(
//                                         onTap: () {
//
//
//
//                                           ConfigStore.to.trackData(
//                                               '作品点击',
//                                               ConfigStore.to
//                                                   .getClickProductInfoMap(element,"首页全部分类-${state.selectedTagsName}"));
//
//
//
//                                           if (element.kind == 0 ||
//                                               element.kind == 2 ||
//                                               element.kind == 3 ||
//                                               element.kind == 6) {
//                                             Get.toNamed(AppRoutes.VIDEO_PAGE,
//                                                 arguments: {"id": element.id});
//                                           } else {
//                                             if (element.kind == 5) {
//                                               jumpPage(
//                                                 element.kind,
//                                                 element.id,
//                                                 index: state.guessLikeMediaList
//                                                     .indexOf(element),
//                                                 mediaList:
//                                                     state.guessLikeMediaList,
//                                               );
//                                             } else {
//                                               jumpPage(
//                                                   element.kind, element.id);
//                                             }
//                                           }
//                                         },
//                                         child: ClipRRect(
//                                           borderRadius: BorderRadius.all(Radius.circular(8.r)),
//                                           child: CustomImage(
//                                             url: element.horizontalCover,
//                                             fit: BoxFit.cover,
//                                             width: 171.w,
//                                             height: 96.w,
//                                             // borderRadius: const BorderRadius.all(
//                                             //     Radius.circular(6)),
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         top: 6.6,
//                                         right: 6.6,
//                                         child: getMarkIcon(
//                                             element.permission, element.price),
//                                       ),
//                                     ],
//                                   ),
//                                   getHeight(6),
//                                   SizedBox(
//                                     width: 171.w,
//                                     child: Text(
//                                       element.title ?? "",
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                       style: TextStyle(
//                                           color: Colors.black, fontSize: 12.sp),
//                                     ),
//                                   ),
//                                   getHeight(2),
//                                   getTagWidget(
//                                             element.tagNames,
//                                             element.tags,
//                                             element.kind),
//                                 ],
//                               ));
//                             }
//                             for (int i = 0; i < lists.length; i++) {
//                               if ((i + 1) % 5 == 0) {
//                                 lists.insert(
//                                     i, getCategoriesHorizontalCoverListAds(i));
//                               }
//                             }
//                           }
//
//                           return SliverPadding(
//                             padding: EdgeInsets.only(left: 12.w, right: 12.w),
//                             sliver: SliverGrid(
//                               //Grid
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2, //横向数量
//                                 crossAxisSpacing: 6, //间距
//                                 mainAxisSpacing: 6, //行距
//                                 childAspectRatio: 171.w / 138.w,
//                               ),
//                               delegate: SliverChildBuilderDelegate(
//                                 (BuildContext context, int index) {
//                                   //创建子widget
//                                   return categoriesState
//                                           .categoriesAds.isNotEmpty
//                                       ? lists[index]
//                                       : Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Stack(
//                                               alignment:
//                                                   AlignmentDirectional.center,
//                                               children: [
//                                                 GestureDetector(
//                                                   onTap: () {
//
//
//                                                     ConfigStore.to.trackData(
//                                                         '作品点击',
//                                                         ConfigStore.to
//                                                             .getClickProductInfoMap(state.guessLikeMediaList[index],"首页全部分类-猜你想看"));
//
//
//                                                     if (state.guessLikeMediaList[index].kind == 0 ||
//                                                         state
//                                                                 .guessLikeMediaList[
//                                                                     index]
//                                                                 .kind ==
//                                                             2 ||
//                                                         state
//                                                                 .guessLikeMediaList[
//                                                                     index]
//                                                                 .kind ==
//                                                             3 ||
//                                                         state
//                                                                 .guessLikeMediaList[
//                                                                     index]
//                                                                 .kind ==
//                                                             6) {
//                                                       Get.toNamed(
//                                                           AppRoutes.VIDEO_PAGE,
//                                                           arguments: {
//                                                             "id": state
//                                                                 .guessLikeMediaList[
//                                                                     index]
//                                                                 .id
//                                                           });
//                                                     } else {
//                                                       if (state
//                                                               .guessLikeMediaList[
//                                                                   index]
//                                                               .kind ==
//                                                           5) {
//                                                         jumpPage(
//                                                           state
//                                                               .guessLikeMediaList[
//                                                                   index]
//                                                               .kind,
//                                                           state
//                                                               .guessLikeMediaList[
//                                                                   index]
//                                                               .id,
//                                                           index: index,
//                                                           mediaList: state
//                                                               .guessLikeMediaList,
//                                                         );
//                                                       } else {
//                                                         jumpPage(
//                                                             state
//                                                                 .guessLikeMediaList[
//                                                                     index]
//                                                                 .kind,
//                                                             state
//                                                                 .guessLikeMediaList[
//                                                                     index]
//                                                                 .id);
//                                                       }
//                                                     }
//                                                   },
//                                                   child: ClipRRect(
//                                                     borderRadius: BorderRadius.all(Radius.circular(8.r)),
//                                                     child: CustomImage(
//                                                       url: state
//                                                           .guessLikeMediaList[
//                                                               index]
//                                                           .horizontalCover,
//                                                       fit: BoxFit.cover,
//                                                       width: 171.w,
//                                                       height: 96.w,
//                                                       // borderRadius:
//                                                       //     const BorderRadius.all(
//                                                       //         Radius.circular(6)),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 Positioned(
//                                                   top: 6.6,
//                                                   right: 6.6,
//                                                   child: getMarkIcon(
//                                                       state
//                                                           .guessLikeMediaList[
//                                                               index]
//                                                           .permission,
//                                                       state
//                                                           .guessLikeMediaList[
//                                                               index]
//                                                           .price),
//                                                 ),
//                                               ],
//                                             ),
//                                             getHeight(6),
//                                             SizedBox(
//                                                 width: 171.w,
//                                                 child: Text(
//                                                   state
//                                                           .guessLikeMediaList[
//                                                               index]
//                                                           .title ??
//                                                       "",
//                                                   maxLines: 1,
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   style: TextStyle(
//                                                       color: Colors.black,
//                                                       fontSize: 12.sp),
//                                                 )),
//                                             getHeight(2),
//
//                                             getTagWidget(state
//                                                 .guessLikeMediaList[
//                                             index].tagNames,state
//                                                 .guessLikeMediaList[
//                                             index].tags,state
//                                                 .guessLikeMediaList[
//                                             index].kind),
//                                           ],
//                                         );
//                                 },
//                                 childCount:
//                                     categoriesState.categoriesAds.isNotEmpty
//                                         ? lists.length
//                                         : state.guessLikeMediaList.length,
//                                 // childCount: state.guessLikeMediaList.length,
//                               ),
//                             ),
//                           );
//                         } else {
//                           List<Widget> lists = [];
//
//                           if (categoriesState.categoriesAds.isNotEmpty) {
//                             for (var element in (state.guessLikeMediaList)) {
//                               lists.add(Container(
//                                 //margin: EdgeInsets.only(left: 12.w,right: 12.w),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Stack(
//                                       children: [
//                                         GestureDetector(
//                                           onTap: () {
//
//
//                                             ConfigStore.to.trackData(
//                                                 '作品点击',
//                                                 ConfigStore.to
//                                                     .getClickProductInfoMap(element,"首页全部分类-${state.selectedTagsName}"));
//
//
//                                             if (element.kind == 0 ||
//                                                 element.kind == 2 ||
//                                                 element.kind == 3 ||
//                                                 element.kind == 6) {
//                                               Get.toNamed(AppRoutes.VIDEO_PAGE,
//                                                   arguments: {
//                                                     "id": element.id
//                                                   });
//                                             } else {
//                                               if (element.kind == 5) {
//                                                 jumpPage(
//                                                   element.kind,
//                                                   element.id,
//                                                   index: state
//                                                       .guessLikeMediaList
//                                                       .indexOf(element),
//                                                   mediaList:
//                                                       state.guessLikeMediaList,
//                                                 );
//                                               } else {
//                                                 jumpPage(
//                                                     element.kind, element.id);
//                                               }
//                                             }
//                                           },
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.all(Radius.circular(8.r)),
//                                             child: CustomImage(
//                                               key: Key(element.verticalCover
//                                                   .toString()),
//                                               url: element.verticalCover,
//                                               fit: BoxFit.cover,
//                                               width: 111.w,
//                                               height: 162.w,
//                                               // borderRadius:
//                                               //     const BorderRadius.all(
//                                               //         Radius.circular(6)),
//                                             ),
//                                           ),
//                                         ),
//                                         Positioned(
//                                           top: 6.6,
//                                           right: 6.6,
//                                           child: getMarkIcon(element.permission,
//                                               element.price),
//                                         ),
//                                       ],
//                                     ),
//                                     getHeight(6),
//                                     SizedBox(
//                                       width: 111.w,
//                                       child: Text(
//                                         element.title ?? "",
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: TextStyle(
//                                             color: Colors.black,
//                                             fontSize: 12.sp),
//                                       ),
//                                     ),
//                                     getHeight(2),
//                                     getTagWidget(
//                                             element.tagNames,
//                                             element.tags,
//                                             element.kind),
//                                   ],
//                                 ),
//                               ));
//                             }
//                             for (int i = 0; i < lists.length; i++) {
//                               if ((i + 1) % 5 == 0) {
//                                 lists.insert(
//                                     i, getCategoriesVerticalCoverListAds(i));
//                               }
//                             }
//                           }
//
//                           return SliverPadding(
//                             sliver: SliverGrid(
//                               //Grid
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 3, //横向数量
//                                 crossAxisSpacing: 0, //间距
//                                 mainAxisSpacing: 0, //行距
//                                 childAspectRatio: 111.w / 204.w,
//                               ),
//                               delegate: SliverChildBuilderDelegate(
//                                 (BuildContext context, int index) {
//                                   return categoriesState
//                                           .categoriesAds.isNotEmpty
//                                       ? lists[index]
//                                       : Container(
//                                           //margin: EdgeInsets.only(left: 12.w,right: 12.w),
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Stack(
//                                                 children: [
//                                                   GestureDetector(
//                                                     onTap: () {
//
//
//
//
//
//                                                       ConfigStore.to.trackData(
//                                                           '作品点击',
//                                                           ConfigStore.to
//                                                               .getClickProductInfoMap(state.guessLikeMediaList[index],"首页全部分类-猜你想看"));
//
//
//
//
//
//
//                                                       if (state.guessLikeMediaList[index].kind == 0 ||
//                                                           state
//                                                                   .guessLikeMediaList[
//                                                                       index]
//                                                                   .kind ==
//                                                               2 ||
//                                                           state
//                                                                   .guessLikeMediaList[
//                                                                       index]
//                                                                   .kind ==
//                                                               3 ||
//                                                           state
//                                                                   .guessLikeMediaList[
//                                                                       index]
//                                                                   .kind ==
//                                                               6) {
//                                                         Get.toNamed(
//                                                             AppRoutes
//                                                                 .VIDEO_PAGE,
//                                                             arguments: {
//                                                               "id": state
//                                                                   .guessLikeMediaList[
//                                                                       index]
//                                                                   .id
//                                                             });
//                                                       } else {
//                                                         if (state
//                                                                 .guessLikeMediaList[
//                                                                     index]
//                                                                 .kind ==
//                                                             5) {
//                                                           jumpPage(
//                                                             state
//                                                                 .guessLikeMediaList[
//                                                                     index]
//                                                                 .kind,
//                                                             state
//                                                                 .guessLikeMediaList[
//                                                                     index]
//                                                                 .id,
//                                                             index: index,
//                                                             mediaList: state
//                                                                 .guessLikeMediaList,
//                                                           );
//                                                         } else {
//                                                           jumpPage(
//                                                               state
//                                                                   .guessLikeMediaList[
//                                                                       index]
//                                                                   .kind,
//                                                               state
//                                                                   .guessLikeMediaList[
//                                                                       index]
//                                                                   .id);
//                                                         }
//                                                       }
//                                                     },
//                                                     child: ClipRRect(
//                                                       borderRadius: BorderRadius.all(Radius.circular(8.r)),
//                                                       child: CustomImage(
//                                                         key: Key(state
//                                                             .guessLikeMediaList[
//                                                                 index]
//                                                             .verticalCover
//                                                             .toString()),
//                                                         url: state
//                                                             .guessLikeMediaList[
//                                                                 index]
//                                                             .verticalCover,
//                                                         fit: BoxFit.cover,
//                                                         width: 111.w,
//                                                         height: 162.w,
//                                                         // borderRadius:
//                                                         //     const BorderRadius
//                                                         //             .all(
//                                                         //         Radius.circular(
//                                                         //             6)),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   Positioned(
//                                                     top: 6.6,
//                                                     right: 6.6,
//                                                     child: getMarkIcon(
//                                                         state
//                                                             .guessLikeMediaList[
//                                                                 index]
//                                                             .permission,
//                                                         state
//                                                             .guessLikeMediaList[
//                                                                 index]
//                                                             .price),
//                                                   ),
//                                                 ],
//                                               ),
//                                               getHeight(6),
//                                               SizedBox(
//                                                   width: 111.w,
//                                                   child: Text(
//                                                     state
//                                                             .guessLikeMediaList[
//                                                                 index]
//                                                             .title ??
//                                                         "",
//                                                     maxLines: 1,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     style: TextStyle(
//                                                         color: Colors.black,
//                                                         fontSize: 12.sp),
//                                                   )),
//                                               getHeight(2),
//
//                                               getTagWidget(state
//                                                   .guessLikeMediaList[
//                                               index].tagNames,state
//                                                   .guessLikeMediaList[
//                                               index].tags,state
//                                                   .guessLikeMediaList[
//                                               index].kind),
//                                             ],
//                                           ),
//                                         );
//                                 },
//                                 childCount:
//                                     categoriesState.categoriesAds.isNotEmpty
//                                         ? lists.length
//                                         : state.guessLikeMediaList.length,
//                                 //childCount: state.guessLikeMediaList.length,
//                               ),
//                             ),
//                             padding: EdgeInsets.only(left: 12.w, right: 12.w),
//                           );
//                         }
//                       }),
//                     ),
//                   ],
//                 ),
//               );
//       }),
//     );
//   }
// }

class CategoriesPage extends StatelessWidget {
  CategoriesLogic get logic => Get.find<CategoriesLogic>();
  CategoriesState get state => logic.state;

  const CategoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar("热门分类"),
      body: GetBuilder<CategoriesLogic>(
        id: 'page',
        builder: (logic) {
          return state.categoriesEntity == null
              ? const LoadingWidget()
              : Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        l.d((notification).toString());
                        logic.outerScrollListener();
                        return true;
                      },
                      child: ExtendedNestedScrollView(
                        key: state.key,
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverToBoxAdapter(
                              child: GetBuilder<CategoriesLogic>(
                                id: 'category',
                                builder: (_) {
                                  return _buildExpandView(
                                    expanded: state.headerExpand,
                                    onToggleExpand: logic.toggleHeaderExpand,
                                  );
                                },
                              ),
                            ),
                          ];
                        },
                        pinnedHeaderSliverHeightBuilder: () {
                          return 0;
                        },
                        body: PullRefreshView(
                          controller: state.pullRefreshController,
                          onRefresh: () {
                            state.pageNum = 1;
                            logic.searchVideo(isLoadByScroll: true);
                          },
                          onLoading: () {
                            state.pageNum = state.pageNum + 1;
                            logic.searchVideo(isLoadByScroll: true);
                          },
                          emptyWidget: EmptyWidget(
                            padding: EdgeInsets.only(top: 110.w),
                          ),
                          child: CustomScrollView(
                            slivers: [
                              createAd(state),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: GetBuilder<CategoriesLogic>(
                        id: 'category_overlazy',
                        builder: (context) {
                          return Visibility(
                            visible: state.isShowHeader,
                            child: _buildExpandView(
                              expanded: state.overlazyExpand,
                              onToggleExpand: logic.toggleOverlazyExpand,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget createAd(CategoriesState state) {
    return GetBuilder<CategoriesLogic>(
        id: "list",
        builder: (logic) {
          if (logic.state.mediaListInfo?.data?.mediaList?.isEmpty ?? true) {
            return SliverToBoxAdapter(child: Container());
          } else {
            if (logic.state.isHorizontal) {
              List<Widget> lists = [];

              if (categoriesState.categoriesAdsHorizonal.isNotEmpty) {
                int index = 0;
                for (var element
                    in (logic.state.mediaListInfo!.data!.mediaList!)) {
                  lists.add(MediaCard.fromVideoModel(
                    AllMediaInfoModel.fromJson(element.toJson()),
                    index: index,
                  ));
                  index++;
                }
                index = 0;
                for (int i = 0; i < lists.length; i++) {
                  if ((i + 1) % 5 == 0) {
                    lists.insert(i, getCategoriesHorizontalCoverListAds(i));
                  }
                }
              }

              return SliverPadding(
                padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 20.w),
                sliver: SliverGrid(
                  //Grid
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, //横向数量
                    crossAxisSpacing: 8, //间距
                    mainAxisSpacing: 8, //行距
                    childAspectRatio: 173.w / 148.w,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return categoriesState.categoriesAds.isNotEmpty
                          ? lists[index]
                          : MediaCard.fromVideoModel(
                              AllMediaInfoModel.fromJson(state
                                  .mediaListInfo!.data!.mediaList![index]
                                  .toJson()),
                            );
                    },
                    childCount: categoriesState.categoriesAds.isNotEmpty
                        ? lists.length
                        : logic.state.mediaListInfo?.data?.mediaList?.length,
                  ),
                ),
              );
            } else {
              List<Widget> lists = [];

              if (categoriesState.categoriesAds.isNotEmpty) {
                for (var element
                    in (logic.state.mediaListInfo!.data!.mediaList!)) {
                  lists.add(MediaCard.fromVideoModel(
                    forceVerticalCover: true,
                    AllMediaInfoModel.fromJson(element.toJson()),
                  ));
                }
                for (int i = 0; i < lists.length; i++) {
                  if ((i + 1) % 5 == 0) {
                    lists.insert(i, getCategoriesVerticalCoverListAds(i));
                  }
                }
              }

              return SliverPadding(
                sliver: SliverGrid(
                  //Grid
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, //横向数量
                    crossAxisSpacing: 8, //间距
                    mainAxisSpacing: 8, //行距
                    childAspectRatio: 113.w / 216.w,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return categoriesState.categoriesAds.isNotEmpty
                          ? lists[index]
                          : MediaCard.fromVideoModel(
                              AllMediaInfoModel.fromJson(state
                                  .mediaListInfo!.data!.mediaList![index]
                                  .toJson()),
                            );
                    },
                    childCount: categoriesState.categoriesAds.isNotEmpty
                        ? lists.length
                        : logic.state.mediaListInfo?.data?.mediaList?.length,
                  ),
                ),
                padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 20.w),
              );
            }
          }
        });
  }

  Widget _buildExpandView({
    required bool expanded,
    required void Function() onToggleExpand,
  }) {
    return Container(
      decoration: ShapeDecoration(
        shape: CustomBottomShapeBorder(
          protrusionHeight: 18.w,
          protrusionWidth: 80.w,
          protrusionRadius: 8.r,
          borderRadius: 10.r,
        ),
        color: AppColor.white,
      ),
      constraints: BoxConstraints(minHeight: 65.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // _buildCateItemView(),
          expanded ? _buildCateView() : _buildSelectedView(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleExpand,
            child: Container(
              width: 80.w,
              height: 18.w,
              alignment: Alignment.topCenter,
              child: Transform.rotate(
                angle: expanded ? -pi * 90 : -pi,
                child: SvgPicture.asset(
                  Assets.svgIcExpand,
                  height: 10.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedView() {
    return Container(
      height: state.cateViewMinHeight,
      alignment: Alignment.center,
      child: Text(
        state.selectTypes.values.join('.'),
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColor.primaryColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildCateView() {
    return StatefulBuilder(
      builder: (contexts, setStates) {
        return Container(
            padding: EdgeInsets.symmetric(vertical: 10.w).copyWith(
              left: 20.w,
            ),
            child: Column(
              children: [
                _buildCateItemView(
                    type: "类型",
                    list: state.tabs.map((e) => Tags(name: e)).toList(),
                    columnIndex: -1),
                ...List.generate(
                    state.categoriesEntity?.data?.list?.length ?? 0,
                    (columnIndex) {
                  final listItem =
                      logic.state.categoriesEntity!.data!.list![columnIndex];
                  return _buildCateItemView(
                    type: listItem.name ?? "",
                    list: listItem.tags ?? [],
                    columnIndex: columnIndex,
                  );
                })
              ],
            ));
      },
    );
  }

  Widget _buildCateItemView({
    required String type,
    required List<Tags> list,
    required int columnIndex,
  }) {
    return Container(
      height: 26.w,
      margin: EdgeInsets.symmetric(vertical: 8.w),
      child: Row(
        children: [
          Text(
            type,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ValueBuilder<dynamic>(
                initialValue: "",
                builder: (value, updateFn) {
                  return Row(
                      children: List.generate(list.length, (rowIndex) {
                    final tag = list[rowIndex];
                    final isSelected = columnIndex == -1
                        ? state.tabs[logic.state.selectedKind] == tag.name
                        : state.selectedTags[columnIndex] == rowIndex;

                    return Container(
                      margin: EdgeInsets.only(left: rowIndex == 0 ? 0 : 20.w),
                      alignment: Alignment.center,
                      child: GradientBorderButton(
                        text: tag.name ?? '',
                        activated: isSelected,
                        onTap: () {
                          updateFn(e);
                          if (columnIndex == -1) {
                            logic.clickKind(tag.name ?? "");
                            logic.state.selectTypes.clear();
                            logic.state.selectTypes[columnIndex] =
                                tag.name ?? '';
                            return;
                          }
                          if (logic.state.selectTypes.values
                              .contains(tag.name)) {
                            logic.state.selectTypes.remove(columnIndex);
                          } else {
                            logic.state.selectTypes[columnIndex] =
                                tag.name ?? '';
                          }

                          logic.setSelected(columnIndex, rowIndex);
                        },
                      ),
                    );
                  }));
                },
                // 如果你需要调用 builder 方法之外的东西。
                onUpdate: (value) => value = e,
                onDispose: () => debugPrint("Widget unmounted"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final double maxHeight;

  final Widget child;

  CustomSliverPersistentHeaderDelegate({
    required this.maxHeight,
    required this.child,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(
      child: SizedBox(
        height: shrinkOffset == 0 ? 0 : 65.w,
        child: child,
      ),
    );
  }

  @override
  double get maxExtent => 65.w;

  @override
  double get minExtent => 65.w;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class CustomBottomShapeBorder extends ShapeBorder {
  final double protrusionWidth;
  final double protrusionHeight;
  final double protrusionRadius;
  final double borderRadius;

  const CustomBottomShapeBorder({
    required this.protrusionWidth,
    required this.protrusionHeight,
    required this.protrusionRadius,
    required this.borderRadius,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    final height = rect.bottom - protrusionHeight;
    final double centerX = rect.width / 2;

    path.moveTo(0, 0);
    path.lineTo(0, height - borderRadius);
    path.arcToPoint(
      Offset(borderRadius, height),
      radius: Radius.circular(borderRadius),
      clockwise: false,
    );
    path.lineTo(centerX - protrusionWidth / 2 - protrusionRadius * 3, height);
    path.quadraticBezierTo(
      centerX - protrusionWidth / 2 - protrusionRadius,
      height,
      centerX - protrusionWidth / 2 - protrusionRadius,
      rect.bottom - protrusionRadius,
    );
    path.arcToPoint(
      Offset(centerX - protrusionWidth / 2, rect.bottom),
      radius: Radius.circular(protrusionRadius),
      clockwise: false,
    );
    path.lineTo(centerX + protrusionWidth / 2, rect.bottom);

    path.arcToPoint(
      Offset(centerX + protrusionWidth / 2 + protrusionRadius,
          rect.bottom - protrusionRadius),
      radius: Radius.circular(protrusionRadius),
      clockwise: false,
    );
    path.quadraticBezierTo(
      centerX + protrusionWidth / 2 + protrusionRadius,
      rect.bottom - protrusionHeight,
      centerX + protrusionWidth / 2 + protrusionRadius * 3,
      height,
    );
    path.lineTo(rect.width - borderRadius, height);
    path.arcToPoint(
      Offset(rect.width, height - borderRadius),
      radius: Radius.circular(borderRadius),
      clockwise: false,
    );
    path.lineTo(rect.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return CustomBottomShapeBorder(
      protrusionWidth: protrusionWidth * t,
      protrusionHeight: protrusionHeight * t,
      borderRadius: borderRadius * t,
      protrusionRadius: protrusionRadius * t,
    );
  }
}
