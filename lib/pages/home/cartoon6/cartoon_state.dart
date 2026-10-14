import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/entities/feature_info.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class CartoonState6 {
  FeatureEntity? featureEntity;

  late List<AdsInfoList> banner = [];

  late PullRefreshController pullRefreshCartoonController =
      PullRefreshController();

  int? pageNum = 1;

  int selectIndex = 0;

  CartoonState6() {
    ///Initialize variables
  }
}
