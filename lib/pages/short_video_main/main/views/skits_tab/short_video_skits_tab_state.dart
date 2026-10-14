import 'package:comics_app/common/entities/module_detail_model/all_section_model.dart';
import 'package:comics_app/common/entities/module_detail_model/module_detail_model.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class ShortVideoSkitsTabState {
  ShortVideoSkitsTabState();

  final PullRefreshController pullRefreshController = PullRefreshController();

  ModuleDetailModel? moduleDetailModel;

  int pageNumber = 1;

  List<AllSectionModel> banner = [];
}
