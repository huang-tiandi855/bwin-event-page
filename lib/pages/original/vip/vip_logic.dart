
import '../../../common/entities/module_detail_model/module_detail_model.dart';
import '../../../common/http/base_resp_bean.dart';
import '../abs_origin_view.dart';
import 'vip_state.dart';

class VipLogic extends AbsOriginListController<VipState> with OriginFetchMixin{
  String id;

  VipLogic({required this.id});

  @override
  VipState createState() {
    return VipState();
  }

  @override
  fetchNetworkData(bool isRefresh) async {
    BaseRespBean? rsp = await fetchOriginData(id, pageNumber: state.page, pageSize: state.pageSize);
    state.showLoading.value = false;
    if (rsp != null) {
      ModuleDetailModel model = ModuleDetailModel.fromJson(rsp.data);
      if(model.allSection.isNotEmpty){
        if(isRefresh){
          state.dataList.clear();
        }
        state.dataList.addAll(model.allSection);
        endRefresh(isRefresh: isRefresh, hasMore: model.hasNext ?? false);
      }else{
        state.pullRefreshController.requestFail(isFirstPageNum: isRefresh);
      }
    }
    update();
  }
}
