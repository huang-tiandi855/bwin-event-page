import 'package:comics_app/common/apis/apis.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:get/get.dart';

import '../../common/entities/annoumsg.dart';
import 'welfare_state.dart';

class WelfareLogic extends GetxController {
  final WelfareState state = WelfareState();

  @override
  void onInit() {
    super.onInit();
    onRefresh();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  onRefresh() async {
    state.pageNumber = 1;
    state.annouList.clear();
    getData();
  }

  onLoad() async {
    state.pageNumber++;
    getData();
  }

  getData() async {
    try {
      var data = {
        'page': state.pageNumber,
        'pageSize': state.pageSize,
      };
      BaseRespBean baseRespBean = await WelfareApi.getAnnou(data);
      if (baseRespBean.isSuccess) {
        Annoumsg annoumsg = Annoumsg.fromJson(baseRespBean.data);
        state.annouList.addAll(annoumsg.list ?? []);
        bool hasMore =
            (annoumsg.list?.length ?? 0) < state.pageSize ? false : true;
        bool isEmpty = state.annouList.isEmpty ? true : false;
        state.pullRefreshController.requestSuccess(
            isFirstPageNum: state.pageNumber == 1,
            hasMore: hasMore,
            isEmpty: isEmpty);
        update();
        return;
      }
      state.pullRefreshController
          .requestFail(isFirstPageNum: state.pageNumber == 1);
    } catch (e) {
      state.pullRefreshController
          .requestFail(isFirstPageNum: state.pageNumber == 1);
    }
  }
}
