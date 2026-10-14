import 'package:comics_app/common/entities/config.dart';

import '../../../common/entities/feature_info.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';

class NewState {
  late List<AdsInfoList> banner = [];

  FeatureEntity? featureEntity;

  late PullRefreshController pullRefreshNewController = PullRefreshController();

  int? pageNum = 1;

  NewState() {
    ///Initialize variables
    //banner = ["assets/images/jpg/1.jpg","assets/images/jpg/2.jpg","assets/images/jpg/3.jpg","assets/images/jpg/4.jpg"];
  }
}
