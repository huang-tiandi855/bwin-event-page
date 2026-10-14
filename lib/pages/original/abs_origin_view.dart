import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/apis/module_api.dart';
import '../../common/apis/section_api.dart';
import '../../common/http/base_resp_bean.dart';
import '../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import '../loading/loading_center_widget.dart';

abstract class AbsOriginListView<T extends AbsOriginListController> extends GetView<T> {

  const AbsOriginListView({super.key});

  @override
  T get controller => createController();

  String obtainTag();

  createListBody(T controller);

  T createController();

  @override
  Widget build(BuildContext context) {

    return Obx(() {
      if(controller.state.showLoading.value == true){
        return  SizedBox(
          height: 111.w,
          child: const LoadingCenterWidget(),
        );
      }
      return GetBuilder(
          tag: obtainTag(),
          builder: (T controller){
            return PullRefreshView(
              controller: controller.state.pullRefreshController,
              child: createListBody(controller),
              onLoading: (){controller.onLoad();} ,
              onRefresh: (){controller.onRefresh();},
            );
          });
    });

  }


}

abstract class AbsOriginListController<S extends AbsOriginListState> extends GetxController{

  late S state = createState();


  @override
  void onReady() {
    super.onReady();
    onRefresh();
  }

  /// 创建state
  S createState();

  fetchNetworkData(bool isRefresh);

  onRefresh(){
    state.page = 1;
    fetchNetworkData(true);
  }

  onLoad(){
    state.page ++;
    fetchNetworkData(false);
  }

  endRefresh({required bool isRefresh, required bool hasMore, bool? isEmpty}) {
    state.pullRefreshController.requestSuccess(isFirstPageNum: isRefresh, hasMore: hasMore, isEmpty: isEmpty ?? false);
  }
}

abstract class AbsOriginListState{

  /// 初始化默认加载
  var showLoading = true.obs;

  int page = 1;

  int pageSize = 10;

  PullRefreshController pullRefreshController = PullRefreshController();

}


mixin OriginFetchMixin{

  Future<BaseRespBean?> fetchOriginData(
    String id, {
    String? coverSort,
    String? coverType,
    int? moduleSort,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    BaseRespBean rsp = await ModuleApi.getVidModuleDetail(id, pageNumber: pageNumber, pageSize: pageSize);
    if (rsp.isSuccess) {
      return rsp;
    }
    return null;
  }

  Future<BaseRespBean?> getCartoonTopic(
      String id, {
        int? sortType,
        int pageNumber = 1,
        int pageSize = 10,
      }) async {
    BaseRespBean rsp = await SectionApi.getMedialTopicDetailList(sectionId: id,pageNumber: pageNumber,pageSize: pageSize);
    if (rsp.isSuccess) {
      return rsp;
    }
    return null;
  }

}