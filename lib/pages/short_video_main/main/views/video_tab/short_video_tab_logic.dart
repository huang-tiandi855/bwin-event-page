import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/entities/pagination_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/services/module_config_service.dart';
import 'package:comics_app/common/widgets/item/home_topic_widget.dart';
import 'package:get/get.dart';

import 'short_video_tab_state.dart';

class ShortVideoTabLogic extends GetxController {
  static const int _pageSize = 20;

  final int? moduleSort;

  final ModuleModel module;
  final discoverId = ModuleConfigService.sharedInstance.discoverModuleId;

  String get id => module.id!.toString();

  String get tag => '${id}_$moduleSort';

  ShortVideoTabLogic({required this.module, this.moduleSort});

  final state = ShortVideoTabState();

  @override
  void onInit() {
    super.onInit();
    onRefresh();
  }

  void onRefresh() async {
    state.pageNumber = 1;
    getData();
  }

  onLoad() async {
    state.pageNumber++;
    getData();
  }

  getData() async {
    try {
      final list = await HomeApis.getHomeMediaList(
        groupId: discoverId,
        groupIds: module.id,
        videoType: 1,
        pageNumber: state.pageNumber,
        pageSize: _pageSize,
      );
      final hasNext = list.length >= _pageSize;
      if (state.pageNumber == 1) {
        state.mediaList = list;
      } else {
        state.mediaList = [
          ...(state.mediaList ?? []),
          ...list,
        ];
      }
      bool isEmpty = state.mediaList?.isEmpty ?? true;
      state.pullRefreshController.requestSuccess(
        isFirstPageNum: state.pageNumber == 1,
        hasMore: hasNext,
        isEmpty: isEmpty,
      );
      update(['list']);
    } catch (e) {
      state.pullRefreshController
          .requestFail(isFirstPageNum: state.pageNumber == 1);
    }
  }

  /// 短视频流的「上滑加载更多」provider，直接复用 [HomeApis.getHomeMediaList]
  /// 与 list 同源，新增数据回写到 [ShortVideoTabState.mediaList]，模型映射统一
  /// 走 [videoModelFromHomeMedia]（封装在 home_topic_widget.dart）。
  Future<PaginationModel<VideoModel>> _videoProvider() async {
    state.pageNumber++;
    try {
      final list = await HomeApis.getHomeMediaList(
        groupId: discoverId,
        groupIds: module.id,
        videoType: 1,
        pageNumber: state.pageNumber,
        pageSize: _pageSize,
      );
      final videos = list.map(videoModelFromHomeMedia).toList();
      final hasNext = list.length >= _pageSize;
      state.mediaList = [
        ...(state.mediaList ?? []),
        ...list,
      ];
      update(['list']);
      return Future.value(PaginationModel(
        list: videos,
        hasNext: hasNext,
      ));
    } catch (e) {
      rethrow;
    }
  }

  /// 跳到 [ShortVideoPlayPage]：直接走通用封装 [jumpShortMediaPlay]，本 logic
  /// 仅负责把"当前 list + index + 分页 provider"传进去，不再保留模型映射 /
  /// `Get.to(() => ShortVideoPlayPage(...))` 的样板。
  void navigateToPlayPage(int index) {
    jumpShortMediaPlay(
      mediaList: state.mediaList ?? <MediaVideoModel>[],
      index: index,
      videoProvider: _videoProvider,
    );
  }
}
