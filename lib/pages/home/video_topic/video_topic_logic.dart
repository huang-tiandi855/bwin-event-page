import 'package:comics_app/common/http/code.dart';
import 'package:get/get.dart';

import '../../../common/apis/user.dart';
import '../../../common/entities/feature_info.dart';
import 'video_topic_state.dart';

class VideoTopicLogic extends GetxController {
  final VideoTopicState state = VideoTopicState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    onRefresh();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  onRefresh() async {
    state.pageNumber = 1;
    state.topicList.clear();
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
        'mustInList': true,
      };

      Map<String, dynamic> topicEntityInfo = await UserApi.initRecommend(data);
      if (!Code.isDocSuccess(topicEntityInfo['code'])) {
        state.pullRefreshController
            .requestFail(isFirstPageNum: state.pageNumber == 1);
        return;
      }
      FeatureEntity topicEntityTemp = FeatureEntity.fromJson(topicEntityInfo);
      state.topicList.addAll(topicEntityTemp.data?.list ?? []);
      bool hasMore =
          (topicEntityTemp.data?.list?.length ?? 0) < state.pageSize
              ? false
              : true;
      bool isEmpty =
          (topicEntityTemp.data?.list ?? []).isEmpty ? true : false;
      state.pullRefreshController.requestSuccess(
          isFirstPageNum: state.pageNumber == 1,
          hasMore: hasMore,
          isEmpty: isEmpty);
      update();
      return;
    } catch (e) {
      state.pullRefreshController
          .requestFail(isFirstPageNum: state.pageNumber == 1);
    }
  }
}
