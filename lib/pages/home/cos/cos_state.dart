import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/entities/feature_info.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class CosState {
  FeatureEntity? featureEntity;

  late PullRefreshController pullRefreshCosController = PullRefreshController();

  late List<AdsInfoList> banner = [];

  int? pageNum = 1;

  int selectIndex = 0;

  CosState() {
    ///Initialize variables
  }
}
