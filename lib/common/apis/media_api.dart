import 'package:comics_app/common/entities/comment/vod_comment_item_model.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/video_model/short_recommend_follow_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';

class MediaApi {
  /// 长视频 / 媒体详情：`GET cms/vod/detail/$id`。
  static Future<BaseRespBean> getMediaInfo(String id) async {
    final BaseRespBean baseRespBean =
        await HttpRequest().get('cms/vod/detail/$id') as BaseRespBean;
    return baseRespBean;
  }

  /// 视频 金币支付：`GET cms/vod/pays/$id`。
  static Future<BaseRespBean> videoGoldPay(String id) async {
    final BaseRespBean baseRespBean =
        await HttpRequest().get('cms/vod/pays/$id') as BaseRespBean;
    return baseRespBean;
  }

  /// 视频 观影券支付：`GET cms/vod/pay/ticket/$id`。
  ///
  /// 长 / 短视频在 1008 / 1038 鉴权拦截后，若用户 `movieTickets > 0`，前置展示
  /// 观影券浮窗，按钮回调走这条接口扣 1 张观影券。
  ///
  /// **观影券一次性票特性**（与 [videoGoldPay] 永久解锁不同）：扣 1 张只换
  /// 本次播放 —— 下次再进同一详情页，[getMediaInfo] 仍会被 1008/1038 拦截。
  /// 因此本接口响应里**直接回写**本次播放所需的整套 mediaInfo（含可播
  /// 放的 `realVideoUrl` 与可播放的 `code`），调用方拿到响应后应当**直接用
  /// 响应覆盖本地 state 起播**，**不要**再调 [getMediaInfo] 重拉详情 ——
  /// 否则会被同样的鉴权码再次拦回浮层，观影券就白扣了。
  ///
  /// - 成功：[UserStore.refreshUser]（同步 `movieTickets - 1`）+
  ///   响应内 mediaInfo 覆盖本地态走起播；
  /// - 失败：toast 接口 `tip`，浮窗保持原态。
  static Future<BaseRespBean> videoTicketPay(String id) async {
    final BaseRespBean baseRespBean =
        await HttpRequest().get('cms/vod/pay/ticket/$id') as BaseRespBean;
    return baseRespBean;
  }

  /// 关注发布者：`POST /fans/add`。
  static Future<BaseRespBean> onFocus(int star) async {
    final param = <String, dynamic>{
      'star': star,
    };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean = await HttpRequest()
        .post('fans/add', queryParameters: param) as BaseRespBean;
    return baseRespBean;
  }

  /// 取消关注发布者：`POST /fans/del`。
  static Future<BaseRespBean> onCancleFocus(int star) async {
    final param = <String, dynamic>{
      'star': star,
    };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean = await HttpRequest()
        .post('fans/del', queryParameters: param) as BaseRespBean;
    return baseRespBean;
  }

  /// 短视频搜索关注列表 `POST /cms/vod/search-follows`
  static Future<List<MediaVideoModel>> getShortFollowsList(
      {int page = 1, int pageSize = 10}) async {
    final param = <String, dynamic>{
      'videoType': 1,
      'page': page,
      'pageSize': pageSize,
    };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean = await HttpRequest()
        .post('cms/vod/search-follows', data: param) as BaseRespBean;
    if (!baseRespBean.isSuccess) return [];
    return MediaVideoModel.listFromData(baseRespBean.data);
  }

  /// 短视频推荐关注作者列表 `POST /cms/vod/authors/videos`。
  ///
  /// 返回每位作者的卡片信息 + 一批代表作短视频（[ShortRecommendFollowItemModel.videos]
  /// 复用首页 [MediaVideoModel]，避免再造一份只差名字的短视频结构）。
  ///
  /// 该接口业务侧不做分页，下拉刷新即拿回全量推荐作者。
  static Future<List<ShortRecommendFollowItemModel>>
      getShortRecommendFollowsList() async {
    final BaseRespBean baseRespBean =
        await HttpRequest().post('cms/vod/authors/videos') as BaseRespBean;
    if (!baseRespBean.isSuccess) return [];
    return ShortRecommendFollowItemModel.listFromData(baseRespBean.data);
  }

  /// 发送评论内容 'POST /cms/vod/comment/add'
  static Future<BaseRespBean> sendComment({int? vid, String? content}) async {
    final param = <String, dynamic>{
      'vid': vid,
      'content': content,
    };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean = await HttpRequest()
        .post('cms/vod/comment/add', queryParameters: param) as BaseRespBean;
    return baseRespBean;
  }

  /// 评论点赞 'POST cms/vod/comment/like'
  static Future<BaseRespBean> clickCommentLike({int? id, bool? yes}) async {
    final param = <String, dynamic>{
      'id': id,
      'yes': yes,
    };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean = await HttpRequest()
        .post('cms/vod/comment/like', queryParameters: param) as BaseRespBean;
    return baseRespBean;
  }

  /// 获取评论列表 'POST cms/vod/comment/list'
  static Future<List<VodCommentItemModel>> getVodCommentList(
      {int? vid, int page = 1, int pageSize = 10}) async {
    final param = <String, dynamic>{
      'vid': vid,
      'page': page,
      'pageSize': pageSize,
    };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean = await HttpRequest()
        .post('cms/vod/comment/list', queryParameters: param) as BaseRespBean;
    if (!baseRespBean.isSuccess) {
      return [];
    }
    return VodCommentItemModel.listFromData(baseRespBean.data);
  }
}
