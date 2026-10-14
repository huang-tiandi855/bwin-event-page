import '../../../common/entities/module_detail_model/all_media_info_model.dart';
import '../../../common/entities/module_detail_model/all_section_model.dart';
import '../abs_origin_view.dart';

class ComicsState extends AbsOriginListState{

  List<AllSectionModel> dataList = [];

  List<AllMediaInfoModel> mediaList = [];

  /// 目前show type == 6 需要无限下滑
  bool? isNeedMore = false;

  /// 最后一个item 模型  只有在 isNeedMore == true 时才会有值
  AllSectionModel? lastModel;

  ComicsState() {
    ///Initialize variables
  }
}
