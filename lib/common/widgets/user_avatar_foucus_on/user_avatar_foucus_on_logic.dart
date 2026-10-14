import 'package:comics_app/common/entities/hot_topic_entity.dart';
import 'package:get/get.dart';

import '../../http/base_resp_bean.dart';
import '../../utils/toast_util.dart';

class UserAvatarFoucusOnLogic extends GetxController {
  ///关注标签
  void collect(HotTopicList hotTopicList) async {
    if (hotTopicList.id == null) {
      CustomshowToast(msg: '用户信息错误');
      return;
    }
    bool hasCollected = hotTopicList.hasCollected ?? false;
    BaseRespBean baseRespBean = BaseRespBean(0);
    // BaseRespBean baseRespBean = await CircleApi.tagCollect(data);
    if (baseRespBean.isSuccess) {
      hotTopicList.hasCollected = !hasCollected;
      if (!hasCollected) {
        CustomshowToast(msg: '关注成功');
      } else {
        CustomshowToast(msg: '取消关注');
      }
      update(["collect"]);
      return;
    }
  }
}
