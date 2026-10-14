import 'package:comics_app/common/routers/app_routes.dart';
import 'package:get/get.dart';

/// 跳转 [AppRoutes.TOPIC_MORE_DETAIL] 的统一入口。
///
/// ### 为什么需要这个 helper
/// [TopicMoreDetailBinding] 用 `Get.lazyPut(TopicMoreDetailLogic.new)`
/// 注册 logic。如果不带 tag，多份 [TopicMoreDetailPage] 同时存在于路由栈
/// 上时（专题 A → 短视频流 → 专题 B；专题 A → 长视频 → `offNamed` 专题 B；
/// 同路由 `preventDuplicates: false` push 等），所有页面共享同一份 logic
/// 实例，state 会被后入栈的页面覆盖，pop 回前一个页面时看到错位数据。
///
/// 这里在每次 push 前生成一个**唯一 tag**（`topicId + 微秒时间戳`）写进
/// `Get.arguments`，由 [TopicMoreDetailBinding] / [TopicMoreDetailPage]
/// 读取后用作 `Get.lazyPut` / `Get.find` 的 tag。这样每次 push 都对应
/// 一份独立 logic + state，路由 pop 时 GetX（默认 `SmartManagement.full`）
/// 自动 dispose。
///
/// ### 入口约定
/// 所有跳 [AppRoutes.TOPIC_MORE_DETAIL] 的地方都走 [push] / [replace]，
/// 不要再直接 `Get.toNamed(AppRoutes.TOPIC_MORE_DETAIL, ...)`，否则会
/// 跳过 tag 注入，回退到「共享单例」的老行为。
class TopicMoreDetailRoute {
  TopicMoreDetailRoute._();

  /// `Get.arguments` 中存放页面 tag 的 key。
  ///
  /// 双下划线前缀 + 命名空间，避免与业务字段（`topicId / topicName /
  /// keywordType / videoType`）冲突。
  static const String _kPageTagKey = '__topicMoreDetailTag';

  /// 普通 push（`Get.toNamed`）。
  ///
  /// - [topicId]、[topicName]、[keywordType]、[videoType] 与现网调用方
  ///   参数命名一一对齐，传哪个填哪个。
  /// - 内部自动生成唯一 tag、自动开启 `preventDuplicates: false` 让 GetX
  ///   不要因为「当前路由已经是 TOPIC_MORE_DETAIL」吞掉跳转。
  static Future<dynamic> push({
    Object? topicId,
    String? topicName,
    int? keywordType,
    int? videoType,
  }) {
    return Get.toNamed(
          AppRoutes.TOPIC_MORE_DETAIL,
          arguments: _buildArguments(
            topicId: topicId,
            topicName: topicName,
            keywordType: keywordType,
            videoType: videoType,
          ),
          preventDuplicates: false,
        ) ??
        Future.value();
  }

  /// 替换当前栈顶（`Get.offNamed`）。
  ///
  /// 用于「从长视频详情页点专题标签时希望把视频页一起替换掉」等场景，
  /// 与现网 `video_page_view` 里 `Get.offNamed(TOPIC_MORE_DETAIL, ...)`
  /// 行为一致；tag 注入逻辑与 [push] 共用。
  static Future<dynamic> replace({
    Object? topicId,
    String? topicName,
    int? keywordType,
    int? videoType,
  }) {
    return Get.offNamed(
          AppRoutes.TOPIC_MORE_DETAIL,
          arguments: _buildArguments(
            topicId: topicId,
            topicName: topicName,
            keywordType: keywordType,
            videoType: videoType,
          ),
          preventDuplicates: false,
        ) ??
        Future.value();
  }

  /// 由 [TopicMoreDetailBinding] / [TopicMoreDetailPage] 调用：从
  /// `Get.arguments` 里取出本次 push 注入的 tag。
  ///
  /// - 没有 tag（旧入口忘了走 helper、外链 scheme 等）时返回 `null`，
  ///   调用方自然 fallback 到无 tag 的全局实例 —— 行为退化到改造前，
  ///   不会立即崩溃，便于排查问题。
  static String? tagOf(dynamic raw) {
    if (raw is Map) {
      final v = raw[_kPageTagKey];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }

  static Map<String, dynamic> _buildArguments({
    Object? topicId,
    String? topicName,
    int? keywordType,
    int? videoType,
  }) {
    return <String, dynamic>{
      if (topicId != null) 'topicId': topicId,
      if (topicName != null) 'topicName': topicName,
      if (keywordType != null) 'keywordType': keywordType,
      if (videoType != null) 'videoType': videoType,
      _kPageTagKey: _buildTag(topicId),
    };
  }

  /// 生成本次 push 的页面 tag。
  ///
  /// 形式：`topic_more_detail::{topicId}::{microsecondsSinceEpoch}`。
  /// - 加 topicId 是为了在日志里更容易看出是哪个专题的实例；
  /// - 微秒级时间戳保证连续两次跳同一专题（甚至同毫秒内）也能拿到不同
  ///   tag，避免 [Get.lazyPut] 因为 tag 冲突命中已注册实例。
  static String _buildTag(Object? topicId) {
    final String idPart = topicId?.toString() ?? '0';
    final int ts = DateTime.now().microsecondsSinceEpoch;
    return 'topic_more_detail::$idPart::$ts';
  }
}
