import 'package:comics_app/common/entities/MediaListInfo.dart';
import 'package:comics_app/common/entities/categories_entity.dart';
import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CategoriesState {
  List<String> tabs = [
    "动漫",
    "漫画",
    "COS",
    "真人",
    "小说",
    "写真",
    "原作",
  ];

  Map<int, String> selectTypes = {};

  late List<String> relationType = [];

  late List<String> roleType = [];

  late List<String> appearanceType = [];

  late List<String> storyType = [];

  late List<String> sexType = [];

  dynamic selectedType;

  bool isHorizontal = false;

  late ScrollController scrollController = ScrollController();

  bool isShowHeader = false;

  CategoriesEntity? categoriesEntity;

  List<int> selectedTags = [];

  late PullRefreshController pullRefreshController = PullRefreshController();

  List<MediaList> guessLikeMediaList = [];

  late List<AdsInfoList> categoriesAds = [];

  late List<AdsInfoList> categoriesAdsHorizonal = [];

  int pageNum = 1;

  int guessLikePageNum = 1;

  MediaListInfo? mediaListInfo;

  MediaListInfo? guessLikeMediaListInfo;

  bool? isFirstEnter;

  int selectedKind = 0;
  String selectedTagsName = '';

  // List<String> selectTagsName = [];

  // List<String>? tags = [];

  //bool? isLoading = false;

  bool? isLoadingEmpty = false;

  CategoriesState() {
    ///Initialize variables

    selectedType = "".obs;
  }
  final GlobalKey<ExtendedNestedScrollViewState> key = GlobalKey<ExtendedNestedScrollViewState>();

  bool overlazyExpand = false;
  bool headerExpand = true;
  bool get isVerticalCover => mediaListInfo?.data?.mediaList?.isNotEmpty == true
      ? mediaListInfo!.data!.mediaList!.first.isVerticalCover
      : false;
  double get cateViewHeight => (categoriesEntity?.data?.list?.length ?? 0) * 42.w + 20.w + 18.w;

  double get cateViewMinHeight => 47.w;
}
