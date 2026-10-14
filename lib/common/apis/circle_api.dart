import '../entities/circle/posting_list_models.dart';
import '../entities/comment/vod_comment_item_model.dart';
import '../entities/modules_config/module_model.dart';
import '../http/base_resp_bean.dart';
import '../http/code.dart';
import '../http/http_request.dart';

class CircleApi {
  //发帖接口
  static Future<bool> publishPost(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('posting/add', queryParameters: data);
    return baseRespBean.isSuccess && Code.isDocSuccess(baseRespBean.bizCode);
  }

  /// 获取帖子分类。
  ///
  /// 返回 `null` 表示请求失败（网络异常 / 解析异常 / 业务码非成功），
  /// 返回空列表表示后端给了空数据，调用方据此区分「失败」和「空」。
  static Future<List<ModuleModel>?> getPostingCategory() async {
    try {
      final BaseRespBean baseRespBean =
          await HttpRequest().post('posting/category');
      if (!baseRespBean.isSuccess) return null;
      return ModuleModel.listFromData(baseRespBean.data);
    } catch (_) {
      return null;
    }
  }

  /// 获取帖子列表（`posting/list`）。
  ///可以查询分类列表、user帖子列表，单个帖子详情
  /// [query] 查询条件
  /// [query.id] 帖子id
  /// [query.uid] 用户id
  /// [query.page] 页码
  /// [query.pageSize] 每页条数
  /// [query.sortType] 排序方式
  /// [query.type] 帖子类型
  /// [query.categoryId] 分类id
  /// [query.childCategoryId] 子分类id
  /// [query.costType] 消费类型
  /// [query.keyword] 关键词
  /// [query.nickName] 用户昵称
  /// [query.sortType] 排序方式
  /// [query.type] 帖子类型
  /// [query.uid] 用户id
  /// [query.uids] 用户id列表
  /// [query.hasVideo] 是否视频贴子
  static Future<PostingListPage?> getPostingList(
    PostingListQuery query,
  ) async {
    try {
      // 注意：`posting/*` 系列后端用 @RequestParam 接参，必须走 query string，
      // 不能用 body（`data:`），否则会返回 BSC10001「请求参数错误」。
      final BaseRespBean resp = await HttpRequest().post(
        'posting/list',
        queryParameters: query.toJson(),
      );
      if (!resp.isSuccess) return null;
      return PostingListPage.fromData(
        resp.data,
        requestedPageSize: query.pageSize,
      );
    } catch (_) {
      return null;
    }
  }

  ///记录帖子观看/posting/watch/{id}
  ///[id] id
  ///返回是否观看成功
  static Future<bool> postWatch(int id) async {
    final BaseRespBean resp = await HttpRequest().get(
      'posting/watch/$id',
    );
    return resp.isSuccess && Code.isDocSuccess(resp.bizCode);
  }

  /// 我的帖子列表（`posting/my`），用于创作中心 Tab。
  /// 后端 `status` 文档：
  /// - 0 审核中
  /// - 1 审核通过（已发布）
  /// - 2 审核失败（未通过）
  /// - 3 下架
  /// - 4 创建失败
  static Future<PostingListPage?> getMyPostingList({
    required int status,
    int page = 1,
  }) async {
    try {
      final BaseRespBean resp = await HttpRequest().post(
        'posting/my',
        queryParameters: <String, dynamic>{
          'page': page,
          'status': status,
        },
      );
      if (!resp.isSuccess) return null;
      return PostingListPage.fromData(
        resp.data,
        requestedPageSize: 10,
      );
    } catch (_) {
      return null;
    }
  }

  ///帖子收藏
  ///[ids] id 列表
  ///[isCollection] 是否收藏 0 取消，1收藏
  ///返回是否收藏成功
  static Future<bool> postCollection(List<int> ids, int isCollection) async {
    final BaseRespBean resp = await HttpRequest().post(
      'posting/collection',
      data: <String, dynamic>{
        'ids': ids,
        'isCollection': isCollection,
      },
    );
    return resp.isSuccess && Code.isDocSuccess(resp.bizCode);
  }

  ///帖子点赞/posting/perfect
  ///[id] id
  ///返回是否点赞成功
  static Future<bool> postLike(int id, int isLike) async {
    final BaseRespBean resp = await HttpRequest().post(
      'posting/perfect',
      queryParameters: <String, dynamic>{
        'id': id,
      },
    );
    return resp.isSuccess && Code.isDocSuccess(resp.bizCode);
  }

  ///帖子解锁/posting/unlock
  ///[id] id
  ///返回是否解锁成功
  static Future<BaseRespBean> postUnlock(int id) async {
    final BaseRespBean resp = await HttpRequest().post(
      '/posting/pay',
      queryParameters: <String, dynamic>{
        'id': id,
      },
    );
    return resp;
  }

  ////帖子评论列表comment/list
  ///[id] id
  ///[page] 页码
  ///返回评论列表
  static Future<List<VodCommentItemModel>> getPostCommentList(
      int id, int page) async {
    try {
      final BaseRespBean resp = await HttpRequest().post(
        'comment/list',
        queryParameters: <String, dynamic>{
          'pid': id,
          'page': page,
        },
      );
      if (!resp.isSuccess) return [];
      return VodCommentItemModel.listFromData(resp.data);
    } catch (_) {
      return [];
    }
  }

  //发表帖子评论/comment/add
  ///[id] id
  ///[content] 内容
  ///返回是否发表成功
  static Future<bool> postCommentAdd(int id, String content) async {
    final BaseRespBean resp = await HttpRequest().post(
      'comment/add',
      queryParameters: <String, dynamic>{
        'pid': id,
        'content': content,
      },
    );
    return resp.isSuccess && Code.isDocSuccess(resp.bizCode);
  }

  //帖子评论点赞/comment/perfect
  ///[id] id
  ///返回是否点赞成功
  static Future<BaseRespBean> postCommentLike(int id) async {
    final BaseRespBean resp = await HttpRequest().post(
      '/comment/perfect',
      queryParameters: <String, dynamic>{
        'id': id,
      },
    );
    return resp;
  }
}
