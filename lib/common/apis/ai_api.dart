import 'dart:convert';

import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:comics_app/common/entities/ai/ai_params.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/utils/debug_log.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:dio/dio.dart';

/// AI 创作模块接口（`/ai/*`）。
///
/// 约定（见对接文档）：
/// - 全部 **POST**；
/// - 业务参数走 [HttpRequest.post] 的 `queryParameters`（网关 form / @RequestParam），
///   **禁止** JSON Body（`data:`）；
/// - 单对象读 `result`，列表读 `data` + `total`。
class AIApi {
  AIApi._();

  static const int _taskCreateTimeoutMs = 30000;
  static const int aiTypeImage = 1;
  static const int aiTypeVideo = 2;

  /// 本地缓存的最新 `/ai/home`，提交 / 下载成功后应刷新。
  static AiClientHomeVo? cachedHome;

  /// 将上传接口返回的完整 URL 统一转成 AI 接口需要的 CDN 相对路径。
  static String normalizeUploadPath(String value) =>
      AiParams.normalizeAiUploadPath(value);

  /// 将图片路径序列化为 JSON 数组字符串（H5 统一写法）。
  static String serializePaths(List<String> paths) =>
      AiParams.serializeAiImages(paths);

  static Map<String, dynamic> _clean(Map<String, dynamic> param) {
    param.removeWhere(
      (k, v) => v == null || (v is String && v.trim().isEmpty),
    );
    return param;
  }

  static Map<String, dynamic> _withBillingRule(
    Map<String, dynamic> params, {
    String? ruleCode,
    AiBillingRuleVo? billingRule,
  }) {
    final effectiveRule = billingRule ??
        (ruleCode == null ? null : AIApi.cachedHome?.ruleOf(ruleCode));
    final effectiveRuleCode = ruleCode ?? effectiveRule?.ruleCode;
    final deductMode = effectiveRule?.deductMode;
    final aiType = aiTypeOfRuleCode(effectiveRuleCode) ?? effectiveRule?.aiType;
    if (effectiveRuleCode != null && effectiveRuleCode.isNotEmpty) {
      params['ruleCode'] ??= effectiveRuleCode;
    }
    if (aiType != null) {
      params['aiType'] = aiType;
    }
    if (deductMode != null) {
      params['deductMode'] = deductMode;
    }
    return params;
  }

  static int? aiTypeOfRuleCode(String? ruleCode) {
    switch (ruleCode) {
      case 'ai_undress':
      case 'ai_text_to_image':
      case 'ai_image_expand':
        return aiTypeImage;
      case 'ai_text_to_video':
      case 'ai_image_to_video':
      case 'ai_custom':
        return aiTypeVideo;
      default:
        return null;
    }
  }

  static Future<BaseRespBean> _post(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    return await HttpRequest().post(
      path,
      queryParameters: _clean(params ?? <String, dynamic>{}),
      options: options,
    ) as BaseRespBean;
  }

  static Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  /// AI 接口兼容文档成功码 `0000` 与历史成功码 `200`，与 H5 保持一致。
  static bool _isSuccess(BaseRespBean resp) {
    return resp.isSuccess || resp.bizCode == '200' || resp.code == 200;
  }

  static void _logTaskResultUrls({
    required String path,
    required int page,
    required dynamic rawData,
    required List<AiTaskVo> tasks,
  }) {
    debugLog(
        '[AI_RESULT_URLS] BEGIN path=$path page=$page count=${tasks.length}');
    if (rawData is List) {
      for (var index = 0; index < rawData.length; index++) {
        final rawTask = rawData[index];
        if (rawTask is! Map) continue;
        debugLog(
          '[AI_RESULT_URLS] raw[$index] '
          'id=${rawTask['id']} '
          'taskNo=${rawTask['taskNo']} '
          'type=${rawTask['type']} '
          'status=${rawTask['status']} '
          'resultUrls=${jsonEncode(rawTask['resultUrls'])}',
        );
      }
    }
    for (var taskIndex = 0; taskIndex < tasks.length; taskIndex++) {
      final task = tasks[taskIndex];
      final urls = task.resultUrls ?? const <String>[];
      if (urls.isEmpty) {
        debugLog(
          '[AI_RESULT_URLS] parsed[$taskIndex] '
          'id=${task.id} taskNo=${task.taskNo} resultUrls=[]',
        );
        continue;
      }
      for (var urlIndex = 0; urlIndex < urls.length; urlIndex++) {
        final url = urls[urlIndex];
        debugLog(
          '[AI_RESULT_URLS] parsed[$taskIndex][$urlIndex] '
          'id=${task.id} taskNo=${task.taskNo} '
          'length=${url.length} url=$url',
        );
      }
    }
    debugLog('[AI_RESULT_URLS] END path=$path page=$page');
  }

  static void _toastFail(BaseRespBean resp) {
    showToast(msg: resp.tip ?? resp.msg ?? '请求失败');
  }

  // ---------------------------------------------------------------------------
  // Home / Rules
  // ---------------------------------------------------------------------------

  /// `POST /ai/home` → [AiClientHomeVo]。
  static Future<AiClientHomeVo?> getHome({bool toastOnFail = false}) async {
    final resp = await _post('/ai/home');
    if (!_isSuccess(resp)) {
      if (toastOnFail) _toastFail(resp);
      return null;
    }
    final map = _asMap(resp.result);
    if (map == null) return null;
    final home = AiClientHomeVo.fromJson(map);
    cachedHome = home;
    return home;
  }

  /// `POST /ai/rule/list` → 规则列表。
  static Future<List<AiBillingRuleVo>> getRuleList({
    bool toastOnFail = false,
  }) async {
    final resp = await _post('/ai/rule/list');
    if (!_isSuccess(resp)) {
      if (toastOnFail) _toastFail(resp);
      return const [];
    }
    final raw = resp.result ?? resp.data;
    return AiBillingRuleVo.listFromData(raw);
  }

  // ---------------------------------------------------------------------------
  // Create（统一 + 快捷）
  // ---------------------------------------------------------------------------

  /// `POST /ai/task/create` 统一提交。
  static Future<AiTaskVo?> taskCreate({
    required String ruleCode,
    String? prompt,
    String? images,
    String? negativePrompt,
    String? model,
    String? aspectRatio,
    String? size,
    int? imageNum,
    int? duration,
    String? styles,
    AiBillingRuleVo? billingRule,
    bool toastOnFail = true,
  }) {
    return _createTask(
      '/ai/task/create',
      params: _withBillingRule({
        'ruleCode': ruleCode,
        'prompt': prompt,
        'images': images,
        'negativePrompt': negativePrompt,
        'model': model,
        'aspectRatio': aspectRatio,
        'size': size,
        'imageNum': imageNum,
        'duration': duration,
        'styles': styles,
      }, ruleCode: ruleCode, billingRule: billingRule),
      toastOnFail: toastOnFail,
    );
  }

  /// `POST /ai/undress/create` 高级脱衣。
  static Future<AiTaskVo?> undressCreate({
    required String images,
    String? prompt,
    AiBillingRuleVo? billingRule,
    bool toastOnFail = true,
  }) {
    return _createTask(
      '/ai/undress/create',
      params: _withBillingRule(
        {'images': images, 'prompt': prompt},
        ruleCode: 'ai_undress',
        billingRule: billingRule,
      ),
      toastOnFail: toastOnFail,
    );
  }

  /// `POST /ai/image/create` 文生图。
  static Future<AiTaskVo?> imageCreate({
    required String prompt,
    String? model,
    String? images,
    String? aspectRatio,
    String? size,
    int? imageNum,
    AiBillingRuleVo? billingRule,
    bool toastOnFail = true,
  }) {
    return _createTask(
      '/ai/image/create',
      params: _withBillingRule({
        'prompt': prompt,
        'model': model,
        'images': images,
        'aspectRatio': aspectRatio,
        'size': size,
        'imageNum': imageNum,
      }, ruleCode: 'ai_text_to_image', billingRule: billingRule),
      toastOnFail: toastOnFail,
    );
  }

  /// `POST /ai/expand/create` 图片拓展。
  static Future<AiTaskVo?> expandCreate({
    required String images,
    String? prompt,
    String? size,
    AiBillingRuleVo? billingRule,
    bool toastOnFail = true,
  }) {
    return _createTask(
      '/ai/expand/create',
      params: _withBillingRule({
        'images': images,
        'prompt': prompt,
        'size': size,
      }, ruleCode: 'ai_image_expand', billingRule: billingRule),
      toastOnFail: toastOnFail,
    );
  }

  /// `POST /ai/text-video/create` 文生视频。
  static Future<AiTaskVo?> textVideoCreate({
    required String prompt,
    required String images,
    String? negativePrompt,
    String? size,
    int? duration,
    String? model,
    AiBillingRuleVo? billingRule,
    bool toastOnFail = true,
  }) {
    return _createTask(
      '/ai/text-video/create',
      params: _withBillingRule({
        'prompt': prompt,
        'negativePrompt': negativePrompt,
        'images': images,
        'size': size,
        'duration': duration,
        'model': model,
      }, ruleCode: 'ai_text_to_video', billingRule: billingRule),
      toastOnFail: toastOnFail,
    );
  }

  /// `POST /ai/image-video/create` 图生视频。
  static Future<AiTaskVo?> imageVideoCreate({
    required String images,
    String? prompt,
    String? styles,
    String? size,
    int? duration,
    String? model,
    AiBillingRuleVo? billingRule,
    bool toastOnFail = true,
  }) {
    return _createTask(
      '/ai/image-video/create',
      params: _withBillingRule({
        'images': images,
        'prompt': prompt,
        'styles': styles,
        'size': size,
        'duration': duration,
        'model': model,
      }, ruleCode: 'ai_image_to_video', billingRule: billingRule),
      toastOnFail: toastOnFail,
    );
  }

  /// `POST /ai/custom-video/create` 自定义视频。
  static Future<AiTaskVo?> customVideoCreate({
    required String images,
    String? prompt,
    String? negativePrompt,
    String? size,
    int? duration,
    String? model,
    AiBillingRuleVo? billingRule,
    bool toastOnFail = true,
  }) {
    return _createTask(
      '/ai/custom-video/create',
      params: _withBillingRule({
        'prompt': prompt,
        'images': images,
        'negativePrompt': negativePrompt,
        'size': size,
        'duration': duration,
        'model': model,
      }, ruleCode: 'ai_custom', billingRule: billingRule),
      toastOnFail: toastOnFail,
    );
  }

  static Future<AiTaskVo?> _createTask(
    String path, {
    required Map<String, dynamic> params,
    bool toastOnFail = true,
  }) async {
    final resp = await _post(
      path,
      params: params,
      options: Options(
        sendTimeout: _taskCreateTimeoutMs,
        receiveTimeout: _taskCreateTimeoutMs,
      ),
    );
    if (!_isSuccess(resp)) {
      if (toastOnFail) _toastFail(resp);
      return null;
    }
    final map = _asMap(resp.result);
    if (map == null) {
      if (toastOnFail) showToast(msg: '提交失败');
      return null;
    }
    return AiTaskVo.fromJson(map);
  }

  // ---------------------------------------------------------------------------
  // Task / Work
  // ---------------------------------------------------------------------------

  /// `POST /ai/task/get`。
  static Future<AiTaskVo?> taskGet(
    int id, {
    bool toastOnFail = false,
  }) async {
    final resp = await _post('/ai/task/get', params: {'id': id});
    if (!_isSuccess(resp)) {
      if (toastOnFail) _toastFail(resp);
      return null;
    }
    final map = _asMap(resp.result);
    if (map == null) return null;
    return AiTaskVo.fromJson(map);
  }

  /// `POST /ai/task/list`（固定每页 10）。
  static Future<AiPagedList<AiTaskVo>> taskList({
    required int page,
    int? type,
    bool toastOnFail = false,
  }) async {
    final resp = await _post('/ai/task/list', params: {
      'page': page,
      'type': type,
    });
    if (!_isSuccess(resp)) {
      if (toastOnFail) _toastFail(resp);
      return const AiPagedList<AiTaskVo>();
    }
    final list = AiTaskVo.listFromData(resp.data);
    _logTaskResultUrls(
      path: '/ai/task/list',
      page: page,
      rawData: resp.data,
      tasks: list,
    );
    return AiPagedList<AiTaskVo>(
      list: list,
      total: resp.total ?? list.length,
    );
  }

  /// `POST /ai/work/list`。
  static Future<AiPagedList<AiTaskVo>> workList({
    required int page,
    int size = 12,
    bool toastOnFail = false,
  }) async {
    final resp = await _post('/ai/work/list', params: {
      'page': page,
      'size': size,
    });
    if (!_isSuccess(resp)) {
      if (toastOnFail) _toastFail(resp);
      return const AiPagedList<AiTaskVo>();
    }
    final list = AiTaskVo.listFromData(resp.data);
    _logTaskResultUrls(
      path: '/ai/work/list',
      page: page,
      rawData: resp.data,
      tasks: list,
    );
    return AiPagedList<AiTaskVo>(
      list: list,
      total: resp.total ?? list.length,
    );
  }

  /// `POST /ai/work/download`。
  static Future<AiDownloadVo?> workDownload(
    int id, {
    bool toastOnFail = true,
  }) async {
    final resp = await _post('/ai/work/download', params: {'id': id});
    if (!_isSuccess(resp)) {
      if (toastOnFail) _toastFail(resp);
      return null;
    }
    final map = _asMap(resp.result);
    if (map == null) {
      if (toastOnFail) showToast(msg: '下载失败');
      return null;
    }
    return AiDownloadVo.fromJson(map);
  }
}
