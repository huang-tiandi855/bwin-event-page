import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';

class TopicListItem {
  final ModuleModel topic;
  final List<MediaVideoModel> mediaList;
  TopicListItem({
    required this.topic,
    required this.mediaList,
  });
}

class RecommendTopicState {
  /// icon 网格（设计稿约 5 列 × 2 行）

  double afterBannerGap = 16;
  double afterMarqueeGap = 16;
  double afterIconGridGap = 20;
  double topicCardRadius = 10;
  double topicCoverWidth = 120;
  double topicCoverHeight = 68;
  double topicListGap = 12;
  double listBottomPadding = 24;

  /// 专题配置 + 接口返回的该专题下视频列表（与 [module.childGroups] 顺序一致）
  final List<TopicListItem> topicListItems = [];

  /// 专题视频接口请求中，首次进入时用于避免空列表闪烁。
  bool isTopicMediaLoading = true;

  /// 接口完成后没有可展示的视频数据。
  bool isTopicMediaEmpty = false;
}
