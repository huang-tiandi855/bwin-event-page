import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/home/hot_search_models.dart';
import 'package:comics_app/common/entities/home/topic_media_list_model.dart';
import 'package:comics_app/common/entities/home/vod_tags_page_model.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';

class HomeApis {
  /// 获取搜索热搜词列表（`/cms/tags2`）。
  static Future<List<HotSearchGroupModel>> getHotSearchList() async {
    final BaseRespBean baseRespBean = await HttpRequest().get('cms/tags2');
    if (!baseRespBean.isSuccess) {
      return [];
    }
    return HotSearchGroupModel.listFromData(baseRespBean.data);
  }

  /// 获取视频推荐标签分页列表（`cms/vod/recommendTags`）。
  static Future<VodTagsPageModel> getVodTagsList({
    int pageNumber = 1,
    int pageSize = 100,
  }) async {
    final BaseRespBean baseRespBean = await HttpRequest().get(
      'cms/vod/recommendTags',
      queryParameters: <String, dynamic>{
        'page': pageNumber,
        'pageSize': pageSize,
      },
    );
    if (!baseRespBean.isSuccess) {
      return VodTagsPageModel.empty;
    }
    return VodTagsPageModel.fromData(baseRespBean.data);
  }

  /// 获取热门分类（`cms/group/hot`），返回与 `cms/groups` 同构的分类模型列表。
  ///
  /// 调用方（如导航抽屉「热门」宫格）可使用：
  /// - [ModuleModel.groupName] / [ModuleModel.name] 渲染标签文案；
  /// - [ModuleModel.id] 跳转到 [AppRoutes.TOPIC_MORE_DETAIL] 专题详情页；
  /// - [ModuleModel.videoType] 区分长 / 短 / 暗网视频。
  ///
  /// 失败或非成功码时返回空列表。
  static Future<List<ModuleModel>> getHotGroup() async {
    final BaseRespBean baseRespBean = await HttpRequest().get('cms/group/hot');
    if (!baseRespBean.isSuccess) {
      return const [];
    }
    return ModuleModel.listFromData(baseRespBean.data);
  }

  /// 获取首页视频数据（`cms/vod/search-json`），成功时返回 `data` 列表。
  static Future<List<MediaVideoModel>> getHomeMediaList({
    /// 作者id
    int? uid,

    /// 分类ID
    int? groupId,

    /// 专题ID
    int? groupIds,

    /// 排序方式 1.推荐 2.最新 3.最热 4.最受欢迎 5.随机 6.最多点赞 7.最多评论 8.最多收藏
    int? sortType,

    /// 金币大于多少，不填表示不限制，1表示大于等于1
    int? gold,

    /// 是否vip
    bool? isVip,

    /// 标签
    String? keyword,

    /// 视频类型 0，普通视频 1，短视频 2，暗网视频
    int videoType = 0,

    /// 关键字类型 0 标题 1 标签
    int keywordType = 0,
    int pageNumber = 1,
    int pageSize = 20,
    Map<String, dynamic>? paramV,
  }) async {
    final param = paramV ??
        <String, dynamic>{
          'uid': uid,
          'gold': gold,
          'isVip': isVip,
          'groupId': groupId,
          'groupIds': groupIds,
          'sortType': sortType,
          'keyword': keyword,
          'videoType': videoType,
          'keywordType': keywordType,
          'pageSize': pageSize,
          'page': pageNumber,
        };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean =
        await HttpRequest().post('cms/vod/search-json', data: param);
    if (!baseRespBean.isSuccess) {
      return [];
    }
    return MediaVideoModel.listFromData(baseRespBean.data);
  }

  /// 获取首页专题视频数据（`cms/vod/groups/search`），成功时返回 `data` 列表。
  static Future<List<TopicMediaGroupModel>> getTopicMediaList({
    /// 专题ID
    String? groupIds,
    int pageNumber = 1,
    int pageSize = 180,
    Map<String, dynamic>? paramV,
  }) async {
    final param = paramV ??
        <String, dynamic>{
          'groupIds': groupIds,
          'page': pageNumber,
          'pageSize': pageSize,
        };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean =
        await HttpRequest().post('cms/vod/groups/search', data: param);
    if (!baseRespBean.isSuccess) {
      return [];
    }
    return TopicMediaGroupModel.listFromData(baseRespBean.data);
  }

  /// 获取视频排行列表（`/cms/rank/list`）。
  static Future<List<MediaVideoModel>> getRankList({
    int? rankType,
    int videoType = 0,
    int rankDataType = 0,
    int pageNumber = 1,
    int pageSize = 10,
    Map<String, dynamic>? paramV,
  }) async {
    final Map<String, dynamic> param = paramV ??
        <String, dynamic>{
          'rankType': rankType,
          'videoType': videoType,
          'rankDataType': rankDataType,
          'pageSize': pageSize,
          'page': pageNumber,
        };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean =
        await HttpRequest().get('cms/rank/list', queryParameters: param);
    if (!baseRespBean.isSuccess) {
      return [];
    }
    return MediaVideoModel.listFromData(baseRespBean.data);
  }
}
