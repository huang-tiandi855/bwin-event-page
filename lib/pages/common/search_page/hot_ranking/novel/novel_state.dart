import 'package:comics_app/common/entities/ranking.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class NovelState {
  int? pageNumber = 1;
  int? pageSize = 30;

  Ranking? ranking;

  late PullRefreshController pullRefreshController = PullRefreshController();
  NovelState() {
    ///Initialize variables
  }
}
