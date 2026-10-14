import 'package:get/get.dart';

import 'topic_more_detail_logic.dart';
import 'topic_more_detail_route.dart';

/// 每次 push [AppRoutes.TOPIC_MORE_DETAIL] 时 GetX 都会调本 binding，按
/// [TopicMoreDetailRoute.push] 注入的 `tag` 注册一份**独立**的
/// [TopicMoreDetailLogic] 实例（默认 `SmartManagement.full`，路由 pop
/// 时自动 dispose）。
///
/// 没有 tag（少数旧入口或外链直接 toNamed）时 fallback 为无 tag 的全局
/// 单例 —— 行为退化到改造前，不立即崩溃，便于排查。
class TopicMoreDetailBinding extends Bindings {
  @override
  void dependencies() {
    final String? tag = TopicMoreDetailRoute.tagOf(Get.arguments);
    Get.lazyPut<TopicMoreDetailLogic>(
      TopicMoreDetailLogic.new,
      tag: tag,
    );
  }
}
