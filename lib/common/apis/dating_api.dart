import 'package:comics_app/common/entities/circle/dating_models.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';

/// 约会模块 API（前缀 `/card`，见 `lib/pages/circle/约会client_api (4).md`）。
///
/// - 列表 / 详情 / 解锁 / 举报参数均为 **Query**，不是 JSON Body。
/// - 解锁仅 [unlock]；勿接已废弃的 `POST /card/pay`。
/// - VIP 权限：楼凤 `DATE_LOUFENG_UNLOCK`，外围 `DATE_WAIWEI_UNLOCK`（服务端算 [DatingCardModel.canVipUnlock]）。
class DatingApi {
  DatingApi._();

  static Future<List<DatingDictItem>?> getTypes() => _fetchDict('card/types');

  /// [type] 为标签分类 `ECardTagTypeEnum`（1 服务 / 2 推荐 / 3 个人），非约会分类 0/1。
  static Future<List<DatingTagItem>?> getTags({int? type}) async {
    try {
      final BaseRespBean resp = await HttpRequest().post(
        'card/tags',
        queryParameters: type != null ? <String, dynamic>{'type': type} : null,
      );
      if (!resp.isSuccess) return null;
      return DatingTagItem.listFromData(resp.data);
    } catch (_) {
      return null;
    }
  }

  /// 省 / 市树，按 `sort` 升序；进入约会页宜拉最新，勿长期缓存。
  static Future<List<DatingRegionNode>?> getRegionTree() async {
    try {
      final BaseRespBean resp = await HttpRequest().post('card/region/tree');
      if (!resp.isSuccess) return null;
      return DatingRegionNode.listFromData(resp.data);
    } catch (_) {
      return null;
    }
  }

  static Future<List<DatingDictItem>?> getReportTypes() =>
      _fetchDict('card/report/types');

  static Future<DatingListPage?> getList(DatingListQuery query) async {
    try {
      final BaseRespBean resp = await HttpRequest().post(
        'card/list',
        queryParameters: query.toJson(),
      );
      if (!resp.isSuccess) return null;
      return DatingListPage.fromData(
        resp.data,
        requestedPageSize: query.pageSize,
        total: resp.total,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<DatingCardModel?> getDetail(int id) async {
    if (id <= 0) return null;
    try {
      final BaseRespBean resp = await HttpRequest().post(
        'card/detail',
        queryParameters: <String, dynamic>{'id': id},
      );
      if (!resp.isSuccess) return null;
      return DatingCardModel.fromAny(resp.result);
    } catch (_) {
      return null;
    }
  }

  /// `POST /card/unlock`，成功载荷在 [BaseRespBean.result]。
  static Future<BaseRespBean> unlock({
    required int id,
    required DatingUnlockType unlockType,
  }) async {
    final BaseRespBean resp = await HttpRequest().post(
      'card/unlock',
      queryParameters: <String, dynamic>{
        'id': id,
        'unlockType': unlockType.value,
      },
    );
    return resp;
  }

  /// `POST /card/my/pays?page=`：我**金币**买过的约会（每页 10 条，不含 VIP 解锁）。
  static Future<List<DatingCardModel>> getMyPays({required int page}) async {
    try {
      final BaseRespBean resp = await HttpRequest().post(
        'card/my/pays',
        queryParameters: <String, dynamic>{'page': page},
      );
      if (!resp.isSuccess) return const <DatingCardModel>[];
      return DatingCardModel.listFromData(resp.data);
    } catch (_) {
      return const <DatingCardModel>[];
    }
  }

  static Future<BaseRespBean> report({
    required int id,
    required int type,
    String? content,
  }) async {
    final BaseRespBean resp = await HttpRequest().post(
      'card/report',
      queryParameters: <String, dynamic>{
        'id': id,
        'type': type,
        if (content != null && content.isNotEmpty) 'content': content,
      },
    );
    return resp;
  }

  static Future<List<DatingDictItem>?> _fetchDict(String path) async {
    try {
      final BaseRespBean resp = await HttpRequest().post(path);
      if (!resp.isSuccess) return null;
      return DatingDictItem.listFromData(resp.data);
    } catch (_) {
      return null;
    }
  }
}
