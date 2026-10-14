
import '../../../common/entities/acg_section/section_model.dart';
import '../../../common/entities/module_detail_model/all_media_info_model.dart';
import '../../../common/entities/module_detail_model/all_section_model.dart';
import '../../../common/entities/module_detail_model/module_detail_model.dart';
import '../../../common/http/base_resp_bean.dart';
import '../abs_origin_view.dart';
import 'girl_state.dart';

class GirlLogic extends AbsOriginListController<GirlState> with OriginFetchMixin{
  String id;

  GirlLogic({required this.id});

  @override
  GirlState createState() {
    return GirlState();
  }

  @override
  fetchNetworkData(bool isRefresh) async {
    if (!isRefresh && state.isNeedMore == true) {
      loadMore();
      return;
    }

    BaseRespBean? rsp = await fetchOriginData(id, pageNumber: state.page, pageSize: state.pageSize);
    state.showLoading.value = false;
    if (rsp != null) {
      ModuleDetailModel model = ModuleDetailModel.fromJson(rsp.data);
      if(model.allSection.isNotEmpty){
        if(isRefresh){
          state.dataList.clear();
          state.dataList.clear();
        }

        state.dataList.addAll(model.allSection);
        AllSectionModel lastModel = state.dataList[state.dataList.length - 1];
        if (lastModel.showType == 6) {
          state.lastModel = lastModel;
          state.isNeedMore = true;
          endRefresh(isRefresh: isRefresh, hasMore: true);
        } else {
          state.isNeedMore = false;
          endRefresh(isRefresh: isRefresh, hasMore: model.hasNext ?? false);
        }
      }else{
        state.pullRefreshController.requestFail(isFirstPageNum: isRefresh);
      }
    }
    update();
  }


  Future<void> loadMore() async {
    if (state.isNeedMore == true) {
      int length = (state.lastModel?.allMediaInfo.length ?? 0);
      if (length > 0) {
        AllMediaInfoModel? model = state.lastModel?.allMediaInfo.last;
        if (model != null) {
          BaseRespBean? rsp = await getCartoonTopic(model.sId ?? "", pageNumber: state.page, pageSize: state.pageSize);
          if (rsp?.isSuccess == true) {
            final model = SectionModel.fromJson(rsp?.data);
            state.mediaList.addAll(model.mediaList!);
            endRefresh(isRefresh: false, hasMore: model.hasNext??false);
          } else {
            state.pullRefreshController.requestFail(isFirstPageNum: false);
          }
          update();
        }
      }
    }
  }

}
