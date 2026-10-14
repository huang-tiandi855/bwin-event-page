import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/entities/feature_info.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class PortrayState {
  FeatureEntity? featureEntity;

  late List<AdsInfoList> banner = [];

  late PullRefreshController pullRefreshPortrayController =
      PullRefreshController();

  int? pageNum = 1;

  int selectIndex = 0;

  PortrayState() {
    ///Initialize variables
  }
}
