import 'package:comics_app/common/entities/circle/post_card_data.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/home/hot_tag_models.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class SearchVideoLibraryState {
  int typeIndex = 0;

  /// -1 表示未选标签，不传 tagIds
  int tagIndex = -1;
  int payIndex = 0;
  int sortIndex = 1;

  List<HotTagItemModel> tagOptions = [];

  List<MediaVideoModel> videoItems = [];

  /// 「帖子」分类下展示的列表数据；与 [videoItems] 互斥，用 [typeIndex] 区分。
  List<PostCardData> postItems = [];

  int pageNumber = 1;

  final int pageSize = 20;

  final PullRefreshController pullRefreshController =
      PullRefreshController(isRequest: true);

  final List<HotTagItemModel> types = [
    HotTagItemModel(id: 0, tag: '视频'),
    HotTagItemModel(id: 1, tag: '抖音'),
    HotTagItemModel(id: 2, tag: '帖子'),
  ];
  final List<HotTagItemModel> payTypes = [
    HotTagItemModel(id: 0, tag: '全部'),
    HotTagItemModel(id: 1, tag: 'VIP'),
    HotTagItemModel(id: 2, tag: '金币'),
  ];
  final List<HotTagItemModel> sorts = [
    HotTagItemModel(id: 8, tag: '最多收藏'),
    HotTagItemModel(id: 2, tag: '最新上架'),
    HotTagItemModel(id: 4, tag: '最多观看'),
  ];
}
