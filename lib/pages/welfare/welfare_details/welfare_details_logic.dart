import 'package:comics_app/common/entities/annoumsg.dart';
import 'package:comics_app/common/utils/debug_log.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:get/get.dart';

import '../../../common/apis/welfare.dart';
import '../../../common/http/base_resp_bean.dart';
import 'welfare_details_state.dart';

class WelfareDetailsLogic extends GetxController {
  final WelfareDetailsState state = WelfareDetailsState();

  @override
  void onReady() {
    super.onReady();
    if(state.annouList == null){
      loadDetailData();
    }else {
      update();
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void loadDetailData() async{
    try{
      BaseRespBean response = await WelfareApi.getAnnouDetail(state.id);
      if(response.isSuccess){
         state.annouList = AnnouList.fromJson(response.data);
      }else {

      }
    }catch(e){
      debugLog(e);
      showToast(msg: "活动详情数据异常");
    }
    update(['detail']);
  }

}
