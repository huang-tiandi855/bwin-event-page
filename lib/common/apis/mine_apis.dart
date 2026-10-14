import 'package:comics_app/common/entities/mine/invite_income_summary_model.dart';
import 'package:comics_app/common/entities/mine/invite_record_model.dart';
import 'package:comics_app/common/entities/mine/question_tree_model.dart';
import 'package:comics_app/common/entities/mine/vip_card_model.dart';
import 'package:comics_app/common/entities/wallet_balance_model.dart';
import 'package:comics_app/common/entities/user/user_account_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/widgets/post_card/post_card.dart';

import '../entities/home/home_media_list_models.dart';
import '../entities/home/mine_media_pay_model.dart';

class MineApis {
  /// 获取商品列表
  /// [type] 0，会员卡 1，金币
  /// [showType] 支付显示类型 0,app 1,pc 2,h5
  static Future<List<VipCardModel>> getVipCardList({
    int type = 0,
    int showType = 0,
    Map<String, dynamic>? paramV,
  }) async {
    final param = paramV ??
        <String, dynamic>{
          'type': type,
          'showType': showType,
        };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean =
        await HttpRequest().get('product/list', queryParameters: param);
    if (!baseRespBean.isSuccess) {
      return <VipCardModel>[];
    }
    final data = baseRespBean.data;
    if (data is! List) {
      return <VipCardModel>[];
    }
    return data
        .whereType<Map>()
        .map((e) => VipCardModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// 我的购买 · 已购列表
  ///
  /// [tabType]：1 影片，2 抖音[page] 页码从 1 开始。
  static Future<List<MediaVideoModel>> getUserPays({
    required int tabType,
    required int page,
  }) async {
    final BaseRespBean resp = await HttpRequest().get(
      'user/pays',
      queryParameters: <String, dynamic>{
        'tabType': tabType,
        'page': page,
      },
    );
    if (!resp.isSuccess) return <MediaVideoModel>[];
    return (resp.data['list'] as List).map((e) {
      final mediaPayModel = MediaPayModel.fromJson(Map<String, dynamic>.from(e));
      return MediaVideoModel.fromMediaPayModel(mediaPayModel);
    }).toList();
  }

  //我的购买 帖子接口
  ///posting/my/pays
  ///参数 page
  static Future<List<PostCardData>> getUserPaysPostingList({
    required int page,
  }) async {
    final BaseRespBean resp = await HttpRequest().get(
      'posting/my/pays',
      queryParameters: <String, dynamic>{
        'page': page,
      },
    );
    if (!resp.isSuccess) return <PostCardData>[];
    return PostCardData.listFromData(resp.data);
  }

  /// 我的收藏 · 视频（影片 / 抖音）
  ///
  /// [videoType]：0 影片，1 抖音；[page] 从 1 开始。
  static Future<List<MediaVideoModel>> getCollectVideoList({
    required int videoType,
    required int page,
    int pageSize = 10,
  }) async {
    final BaseRespBean resp = await HttpRequest().get(
      'cms/favorites',
      queryParameters: <String, dynamic>{
        'videoType': videoType,
        'page': page,
        'pageSize': pageSize,
      },
    );
    if (!resp.isSuccess) return <MediaVideoModel>[];
    return MediaVideoModel.listFromData(resp.data);
  }

  /// 我的收藏 · 帖子
  static Future<List<PostCardData>> getCollectPostList({
    int page = 1,
    int pageSize = 10,
  }) async {
    final BaseRespBean resp = await HttpRequest().post(
      '/posting/favorites',
      data: <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      },
    );
    if (!resp.isSuccess) return <PostCardData>[];
    return PostCardData.listFromData(resp.data);
  }

  /// 我的喜欢 · 影片 / 抖音
  ///
  /// [videoType]：0 影片，1 抖音；GET `cms/favorites`，`like=true`。
  static Future<List<MediaVideoModel>> getLikeVideoList({
    required int videoType,
    required int page,
    int pageSize = 10,
  }) async {
    final BaseRespBean resp = await HttpRequest().get(
      'cms/favorites',
      queryParameters: <String, dynamic>{
        'like': true,
        'videoType': videoType,
        'page': page,
        'pageSize': pageSize,
      },
    );
    if (!resp.isSuccess) return <MediaVideoModel>[];
    return MediaVideoModel.listFromData(resp.data);
  }

  /// 我的喜欢 · 帖子
  static Future<List<PostCardData>> getLikePostList({
    int page = 1,
    int pageSize = 10,
  }) async {
    final BaseRespBean resp = await HttpRequest().post(
      '/posting/perfect/list',
      data: <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      },
    );
    if (!resp.isSuccess) return <PostCardData>[];
    return PostCardData.listFromData(resp.data);
  }

  /// 我的粉丝列表
  /// POST `/fans/fans`，body：`{ uid, page, pageSize }`。
  /// 返回项见 [UserAccountModel]。
  static Future<List<UserAccountModel>> getMyFansList({
    int? uid,
    int page = 1,
    int pageSize = 10,
  }) async {
    final BaseRespBean resp = await HttpRequest().post(
      'fans/fans',
      queryParameters: <String, dynamic>{
        'uid': uid,
        'page': page,
        'pageSize': pageSize,
      },
    );
    if (!resp.isSuccess) return <UserAccountModel>[];
    return UserAccountModel.listFromData(resp.data);
  }

  /// 我的关注列表
  /// POST `/fans/stars`，body：`{ uid, page, pageSize }`。
  /// 返回项见 [UserAccountModel]。
  static Future<List<UserAccountModel>> getMyFollowList({
    int? uid,
    int page = 1,
    int pageSize = 10,
  }) async {
    final BaseRespBean resp = await HttpRequest().post(
      'fans/stars',
      queryParameters: <String, dynamic>{
        'uid': uid,
        'page': page,
        'pageSize': pageSize,
      },
    );
    if (!resp.isSuccess) return <UserAccountModel>[];
    return UserAccountModel.listFromData(resp.data);
  }

  /// 意见反馈
  /// POST `/feedback/submit`，body：`{ content, feedbackType, annex }`。
  static Future<BaseRespBean> feedBackSubmit({
    String? annex,
    String? content,
    int? feedbackType,
  }) async {
    final BaseRespBean resp = await HttpRequest().post(
      'feedback/submit',
      queryParameters: <String, dynamic>{
        'annex': annex,
        'content': content,
        'feedbackType': feedbackType,
      },
    );

    return resp;
  }

  /// 常见问题（官方客服）问答树
  ///
  /// GET `chat/question/tree`，无参；返回多层级问答数据。
  /// 顶层节点 `answer` 作为分类标题，`child` 为该分类下的问答列表。
  /// 返回项见 [QuestionTreeModel]。
  static Future<List<QuestionTreeModel>> getQuestionTree() async {
    final BaseRespBean resp = await HttpRequest().get('chat/question/tree');
    if (!resp.isSuccess) return <QuestionTreeModel>[];
    return QuestionTreeModel.listFromData(resp.data);
  }

  /// 下单 · 提交订单
  ///payType：支付类型0 ，微信，1支付宝
  ///productId：productId 产品id
  static Future<String?> submitOrder({
    required int? productId,
    required int? payType,
  }) async {
    final BaseRespBean resp = await HttpRequest().post(
      'orders/submitByPayType',
      queryParameters: <String, dynamic>{
        'productId': productId,
        'payType': payType,
      },
    );
    //{"code":"0000","message":"","total":null,"result":{"orderId":27,"orderStatus":2,"payUrl":null},"data":null}
    return resp.isSuccess ? resp.data['payUrl'] : null;
  }

  /// 邀请记录 · 分页
  ///
  /// POST `/user/invite/info/page`，body：`{ invitingCode, type:0, page, pageSize }`。
  /// 返回 PageHelper 风格的分页结构，见 [InviteRecordPageModel]。
  static Future<InviteRecordPageModel> getInviteRecord(
    String code, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final BaseRespBean resp = await HttpRequest().post(
      '/user/invite/info/page',
      data: <String, dynamic>{
        'invitingCode': code,
        'type': 0,
        'page': page,
        'pageSize': pageSize,
      },
    );
    if (!resp.isSuccess) return InviteRecordPageModel.empty();
    final data = resp.data;
    if (data is! Map) return InviteRecordPageModel.empty();
    return InviteRecordPageModel.fromJson(Map<String, dynamic>.from(data));
  }

  ///已邀请用户人数
  static Future<int> getInviteUserCount() async {
    final BaseRespBean resp = await HttpRequest().get(
      '/user/invite/count',
    );
    if (!resp.isSuccess) return 0;
    final data = resp.data;
    return data is int ? data : 0;
  }

  /// 获取钱包余额
  ///
  /// GET `/wallet/get`，返回各类资源型余额（积分、金币、AI 次数等）。
  /// 接口失败 / 数据不是对象时返回 null，调用方按需回落到 [WalletBalanceModel.empty]。
  static Future<WalletBalanceModel?> getWalletBalance() async {
    final BaseRespBean resp = await HttpRequest().get(
      '/wallet/get',
    );
    if (!resp.isSuccess) return null;
    final data = resp.data;
    if (data is! Map) return null;
    return WalletBalanceModel.fromJson(Map<String, dynamic>.from(data));
  }

  /// 查询邀请收益汇总
  ///
  /// POST `/income/list/invite`，无参；返回累计 / 今日 / 本月金币与邀请人数。
  /// 接口失败 / 数据不是对象时返回 null，调用方按需回落 [InviteIncomeSummaryModel.empty]。
  static Future<InviteIncomeSummaryModel?> getIncomeListInvite() async {
    final BaseRespBean resp = await HttpRequest().post(
      '/income/list/invite',
    );
    if (!resp.isSuccess) return null;
    final data = resp.data;
    if (data is! Map) return null;
    return InviteIncomeSummaryModel.fromJson(Map<String, dynamic>.from(data));
  }
}
