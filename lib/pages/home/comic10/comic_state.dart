import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/entities/feature_info.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class ComicState10 {
  FeatureEntity? featureEntity;

  late PullRefreshController pullRefreshControllerComic =
      PullRefreshController();

  late List<AdsInfoList> banner = [];

  int? pageNum = 1;

  int selectIndex = 0;

  bool isLoading = false;

  ComicState10() {
    ///Initialize variables
  }
}
