import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/home/topic_media_list_model.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:get/get.dart';

import 'state.dart';

class RecommendTopicLogic extends GetxController {
  final RecommendTopicState state = RecommendTopicState();

  final ModuleModel module;

  RecommendTopicLogic({required this.module});

  @override
  void onInit() {
    super.onInit();
    _initTopicListFromModule();
    getTopicMediaList();
  }

  void _initTopicListFromModule() {
    state.topicListItems
      ..clear()
      ..addAll(
        module.childGroups.map(
          (ModuleModel t) => TopicListItem(topic: t, mediaList: const []),
        ),
      );
  }

  Future<void> getTopicMediaList() async {
    state.isTopicMediaLoading = true;
    state.isTopicMediaEmpty = false;
    update();

    final List<int> ids = module.childGroups
        .map((ModuleModel e) => e.id)
        .whereType<int>()
        .toList();
    if (ids.isEmpty) {
      state.topicListItems.clear();
      state.isTopicMediaLoading = false;
      state.isTopicMediaEmpty = true;
      update();
      return;
    }
    final String groupIds = ids.join(',');
    try {
      final List<TopicMediaGroupModel> apiGroups =
          await HomeApis.getTopicMediaList(groupIds: groupIds);
      final Map<String, TopicMediaGroupModel> byGroupId = {
        for (final TopicMediaGroupModel g in apiGroups) g.groupId: g,
      };
      final List<TopicListItem> nextItems = module.childGroups.map(
        (ModuleModel topic) {
          final String? key = topic.id?.toString();
          final TopicMediaGroupModel? g =
              key != null && key.isNotEmpty ? byGroupId[key] : null;
          // 与接口 key 对齐即可；内层 code 异常时仍可能带 data，有列表就展示
          final List<MediaVideoModel> media = g != null
              ? List<MediaVideoModel>.from(g.data)
              : const <MediaVideoModel>[];
          return TopicListItem(topic: topic, mediaList: media);
        },
      ).toList();
      final bool hasMedia =
          nextItems.any((TopicListItem item) => item.mediaList.isNotEmpty);

      state.topicListItems
        ..clear()
        ..addAll(hasMedia ? nextItems : const <TopicListItem>[]);
      state.isTopicMediaEmpty = !hasMedia;
    } catch (_) {
      state.topicListItems.clear();
      state.isTopicMediaEmpty = true;
    } finally {
      state.isTopicMediaLoading = false;
      update();
    }
  }
}
