import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class AiRecordState {
  final List<AiTaskVo> records = [];
  int page = 1;
  int total = 0;
  bool hasMore = true;
  bool loading = false;

  String get tipText => '作品仅保留3个月，请及时下载';

  final PullRefreshController refreshController =
      PullRefreshController(isRequest: true);

  void resetList() {
    page = 1;
    total = 0;
    hasMore = true;
    records.clear();
  }
}
