import 'package:comics_app/common/entities/circle/gaming_models.dart';
import 'package:comics_app/common/entities/comment/vod_comment_item_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/code.dart';
import 'package:comics_app/common/http/http_request.dart';

/// 游戏模块 API（前缀 `/gaming`）。
///
/// 约定：列表看 `data` + `total`；解锁看 `result`。
/// `SearchModel` 类接口用 form / query，**不要**走 JSON body。
class GameApi {
  GameApi._();

  // ---------- 字典（建议走 [GamesDictCache] 缓存，勿在列表每次筛选重复打） ----------

  static Future<List<GamingDictItem>?> getCategories() =>
      _fetchDict('gaming/category');

  static Future<List<GamingDictItem>?> getPlatforms() =>
      _fetchDict('gaming/platform');

  static Future<List<GamingDictItem>?> getLanguages() =>
      _fetchDict('gaming/language');

  static Future<List<GamingDictItem>?> getTags() => _fetchDict('gaming/tag');

  static Future<List<GamingDictItem>?> _fetchDict(String path) async {
    try {
      final BaseRespBean resp = await HttpRequest().post(path);
      if (!resp.isSuccess) return null;
      return GamingDictItem.listFromData(resp.data);
    } catch (_) {
      return null;
    }
  }

  // ---------- 列表 ----------

  /// `POST /gaming/list`（query / form）。
  static Future<GamingListPage?> getList(GamingListQuery query) async {
    try {
      final BaseRespBean resp = await HttpRequest().post(
        'gaming/list',
        queryParameters: query.toJson(),
      );
      if (!resp.isSuccess) return null;
      return GamingListPage.fromData(
        resp.data,
        requestedPageSize: query.pageSize,
        total: resp.total,
      );
    } catch (_) {
      return null;
    }
  }

  /// 按 id 拉单条详情（复用 list）。
  static Future<GameDataModel?> getDetail(int id) async {
    if (id <= 0) return null;
    final GamingListPage? page = await getList(
      GamingListQuery(page: 1, pageSize: 1, id: id),
    );
    if (page == null || page.list.isEmpty) return null;
    return page.list.first;
  }

  // ---------- 解锁 / 观看 / 互动 ----------

  /// `POST /gaming/unlock?id=`，成功载荷在 [BaseRespBean.result]。
  static Future<BaseRespBean> unlock(int id) async {
    final BaseRespBean resp = await HttpRequest().post(
      'gaming/unlock',
      queryParameters: <String, dynamic>{'id': id},
    );
    return resp;
  }

  /// `GET /gaming/watch/{id}`，记一次观看。
  static Future<bool> watch(int id) async {
    if (id <= 0) return false;
    try {
      final BaseRespBean resp = await HttpRequest().get('gaming/watch/$id');
      return resp.isSuccess && Code.isDocSuccess(resp.bizCode);
    } catch (_) {
      return false;
    }
  }

  /// `POST /gaming/perfect?id=`，点赞 / 取消（以后端为准）。
  static Future<bool> perfect(int id) async {
    final BaseRespBean resp = await HttpRequest().post(
      'gaming/perfect',
      queryParameters: <String, dynamic>{'id': id},
    );
    return resp.isSuccess && Code.isDocSuccess(resp.bizCode);
  }

  /// `POST /gaming/collection`，JSON body：`ids` + `isCollection`（1 收藏 / 0 取消）。
  static Future<bool> collection({
    required List<int> ids,
    required bool isCollection,
  }) async {
    if (ids.isEmpty) return false;
    final BaseRespBean resp = await HttpRequest().post(
      'gaming/collection',
      data: <String, dynamic>{
        'ids': ids,
        'isCollection': isCollection ? 1 : 0,
      },
    );
    return resp.isSuccess && Code.isDocSuccess(resp.bizCode);
  }

  /// `POST /gaming/perfect/list`：我赞过的游戏（JSON `{ page, pageSize }`）。
  static Future<List<GameDataModel>> getPerfectList({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final BaseRespBean resp = await HttpRequest().post(
        'gaming/perfect/list',
        data: <String, dynamic>{
          'page': page,
          'pageSize': pageSize.clamp(1, 20),
        },
      );
      if (!resp.isSuccess) return <GameDataModel>[];
      return GameDataModel.listFromData(resp.data);
    } catch (_) {
      return <GameDataModel>[];
    }
  }

  /// `POST /gaming/favorites`：我的游戏收藏（JSON `{ page, pageSize }`）。
  static Future<List<GameDataModel>> getFavorites({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final BaseRespBean resp = await HttpRequest().post(
        'gaming/favorites',
        data: <String, dynamic>{
          'page': page,
          'pageSize': pageSize.clamp(1, 20),
        },
      );
      if (!resp.isSuccess) return <GameDataModel>[];
      return GameDataModel.listFromData(resp.data);
    } catch (_) {
      return <GameDataModel>[];
    }
  }

  /// `POST /gaming/my/pays?page=`：我解锁 / 买过的游戏。
  static Future<List<GameDataModel>> getMyPays({
    required int page,
  }) async {
    try {
      final BaseRespBean resp = await HttpRequest().post(
        'gaming/my/pays',
        queryParameters: <String, dynamic>{'page': page},
      );
      if (!resp.isSuccess) return <GameDataModel>[];
      return GameDataModel.listFromData(resp.data);
    } catch (_) {
      return <GameDataModel>[];
    }
  }

  // ---------- 评论（前缀 `/gaming/comment`） ----------

  /// `POST /gaming/comment/list`：`pid` + `page`。
  static Future<List<VodCommentItemModel>> getCommentList(
    int pid,
    int page,
  ) async {
    try {
      final BaseRespBean resp = await HttpRequest().post(
        'gaming/comment/list',
        queryParameters: <String, dynamic>{
          'pid': pid,
          'page': page,
        },
      );
      if (!resp.isSuccess) return <VodCommentItemModel>[];
      return VodCommentItemModel.listFromData(resp.data);
    } catch (_) {
      return <VodCommentItemModel>[];
    }
  }

  /// `POST /gaming/comment/add`：`pid` + `content`。成功一般需后台审核后才出现在列表。
  static Future<BaseRespBean> addComment({
    required int pid,
    required String content,
  }) async {
    final BaseRespBean resp = await HttpRequest().post(
      'gaming/comment/add',
      queryParameters: <String, dynamic>{
        'pid': pid,
        'content': content,
      },
    );
    return resp;
  }

  /// `POST /gaming/comment/perfect?id=`：评论点赞。
  static Future<BaseRespBean> commentPerfect(int commentId) async {
    final BaseRespBean resp = await HttpRequest().post(
      'gaming/comment/perfect',
      queryParameters: <String, dynamic>{'id': commentId},
    );
    return resp;
  }
}
