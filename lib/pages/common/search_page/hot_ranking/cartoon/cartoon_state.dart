import 'package:comics_app/common/entities/acg_section/rank_model.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class CartoonState {
  int? pageNumber = 1;
  int? pageSize = 30;

  RankModel? ranking;

  late PullRefreshController pullRefreshController = PullRefreshController();

  CartoonState() {
    ///Initialize variables
  }
}
