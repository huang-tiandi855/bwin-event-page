
import '../../common/entities/annoumsg.dart';
import '../../common/widgets/pullRefreshView/pull_refresh_view.dart';

class WelfareState {
  PullRefreshController pullRefreshController = PullRefreshController();
  int pageNumber = 1;
  int pageSize = 10;
  List<AnnouList> annouList = [];

  WelfareState() {
    ///Initialize variables
  }
}
