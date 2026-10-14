import 'package:comics_app/common/entities/avatar_border.dart';
import 'package:comics_app/common/entities/user_head.dart';
import 'package:comics_app/common/entities/user_official.dart';
import 'package:comics_app/common/entities/user_redemption_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/store/config.dart';
import 'package:comics_app/common/values/config.dart';
import 'package:comics_app/pages/home/happy/HappyModel.dart';
import 'package:dio/dio.dart';

import '../entities/card_model.dart';
import '../entities/user/user_account_model.dart';
import '../entities/user_info_model_entity.dart';
import '../http/code.dart';

class UserApi {
  /// 文档：GET jwt-token，请求头 [machineCode]；与本接口外的 [jwtToken] 头共用同一串 Jwt。
  /// 通过 [HttpRequest] 发起（可走网关），[skipJwtAuth] 避免携带尚未颁发的 jwt。
  /// 成功时明文 JWT 已在 [BaseRespBean.data]（经响应拦截器/网关解密后），直接读取即可。
  static Future<String> fetchJwtToken() async {
    final String machineCode = await ConfigStore.to.getUniqueId();
    final dynamic raw = await HttpRequest().get(
      Config.JWT_TOKEN_API_PATH,
      options: Options(
        headers: <String, dynamic>{'machineCode': machineCode},
        extra: <String, dynamic>{'skipJwtAuth': true},
      ),
    );
    if (raw is! BaseRespBean) {
      throw StateError('jwt-token 响应类型异常');
    }
    final BaseRespBean bean = raw;
    if (!bean.isSuccess) {
      throw StateError(
          'jwt-token 失败 bizCode=${bean.bizCode} code=${bean.code} msg=${bean.msg ?? bean.tip}');
    }
    final dynamic d = bean.data;
    final String jwt =
        d == null ? '' : (d is String ? d.trim() : d.toString().trim());
    if (jwt.isEmpty) {
      throw StateError('jwt-token 正文为空');
    }
    return jwt;
  }

  /// [devID] 设备id
  /// [qrCnt] qr二维码
  /// [devType] 设备信息
  /// [sysType] ios/android
  /// [ver] version
  /// [buildID] packageName
  /// [devToken] 登录设备id验签
  /// [cutInfos] 粘贴板信息
  static Future<UserInfoModelEntity> devLogin(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/mine/login', data: data);
    UserInfoModelEntity userInfoModel =
        UserInfoModelEntity.fromJson(baseRespBean.data);
    return userInfoModel;
  }

  /// 自动注册
  /// [version] 终端版本 非必填
  /// [machineCode] 机器类型 非必填
  /// [phone] 手机号码 必填
  /// [password] 密码 必填
  /// [osType] 设备类型android or ios 必填
  /// [key] 邀请码 非必填
  /// [code] 验证码 非必填，根据是否开启验证码
  /// [channelCode] 渠道 非必填
  static Future<UserInfoModelEntity> freeRegister(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('user/register/free', data: data);
    UserInfoModelEntity userInfoModel =
        UserInfoModelEntity.fromJson(baseRespBean.data);
    return userInfoModel;
  }

  ///活跃上报
  /// [clientTime] 客户端时间
  static Future<BaseRespBean> activeReport() async {
    String clientTime = DateTime.now().millisecondsSinceEpoch.toString();
    BaseRespBean baseRespBean =
        await HttpRequest().post('user/active-report', data: {
      "clientTime": clientTime,
    });
    return baseRespBean;
  }

  static Future<UserInfoModelEntity> phoneLogin(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/mine/mobileLoginOnly', data: data);
    UserInfoModelEntity userInfoModel =
        UserInfoModelEntity.fromJson(baseRespBean.data);
    return userInfoModel;
  }

  /// [content] qrurl
  static Future<UserInfoModelEntity> devLoginH5(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/mine/login/h5/qr', data: data);
    UserInfoModelEntity userInfoModel =
        UserInfoModelEntity.fromJson(baseRespBean.data);
    return userInfoModel;
  }

  ///首页获取标签信息
  /*var mediaZone = []string{
      "最新",
      "精选",
      "动漫",
      "漫画",
      "角色扮演",
      "真人",
      "小说",
      "写真",
      "禁播",
      }*/
  static Future<dynamic> initRecommend(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/zone/topic', queryParameters: data);
    return baseRespBean.toJson();
  }

  static Future<dynamic> getModuleDetaile(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/modules/detail', queryParameters: data);
    return baseRespBean.toJson();
  }

  static Future<dynamic> getOriginalTopicDetail(data) async {
    BaseRespBean baseRespBean = await HttpRequest()
        .get('/modules/original/sectionList', queryParameters: data);
    return baseRespBean.toJson();
  }

  static Future<dynamic> searchKeyWord(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/search', queryParameters: data);
    return baseRespBean.toJson();
  }

  ///获取在线客服接口
  static Future<List<UserAccountModel>>? onlineServiceReq() async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/user/recharge/customers');
    if (baseRespBean.isSuccess) {
      return UserAccountModel.listFromData(baseRespBean.data);
    }
    return [];
  }

  ///获取分类标签
  static Future<dynamic> getClassifyTag(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/hotkind/tags', queryParameters: data);
    return baseRespBean.toJson();
  }

  ///isCollection: 1 收藏 0 取消收藏
  static Future<bool> collectVideo(String id, int isCollection) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('cms/vod/collection', queryParameters: {
      'id': id,
      'isCollection': isCollection,
    });
    return baseRespBean.isSuccess && Code.isDocSuccess(baseRespBean.bizCode);
  }

  // static Future<dynamic> cancelCollectVideo(data) async {
  //   BaseRespBean baseRespBean =
  //       await HttpRequest().post('/cartoon/do/uncollect', data: data);
  //   return baseRespBean.toJson();
  // }

  ///请求头像列表
  static Future<List<SwitchAvatarData?>?> headImageListReq() async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/user/initAvatarList', queryParameters: {});

    return SwitchAvatarData.fromJsonList(baseRespBean.data);
  }

  ///更改用户资料
  static Future<BaseRespBean> updateUser(data) async {
    try {
      BaseRespBean baseRespBean =
          await HttpRequest().post('/user/save', data: data);
      return baseRespBean;
    } catch (e) {
      return BaseRespBean(Code.NETWORK_ERROR);
    }
  }

  /// 查询用户信息-当前用户聚合资料
  /// [uid] 用户ID
  static Future<UserInfoModelEntity?> getMineInfo([int uid = 0]) async {
    try {
      BaseRespBean baseRespBean = await HttpRequest()
          .get('/user/profile', queryParameters: {"uid": uid});
      return UserInfoModelEntity.fromJson(baseRespBean.data);
    } catch (e) {
      return null;
    }
  }

  ///账号凭证
  static Future<CardModel?>? getCertification() async {
    try {
      BaseRespBean baseRespBean = await HttpRequest().post('/account/card/get');
      return CardModel.fromJson(baseRespBean.data);
    } catch (e) {
      return null;
    }
  }

  ///绑定手机号（设置登录密码）
  static Future<BaseRespBean> mobileBindWithPassword(
      String mobile, String password) async {
    BaseRespBean baseRespBean = await HttpRequest().post('/user/bindPhone',
        data: {
          "phone": mobile,
          "password": password,
          'code': "123456",
          'areaCode': '86'
        });
    return baseRespBean;
  }

  ///账号密码登录
  static Future<UserInfoModelEntity?> loginByAccount(
      String mobile, String password) async {
    try {
      BaseRespBean baseRespBean =
          await HttpRequest().post('/user/loginAccount', queryParameters: {
        "act": mobile,
        "password": password,
      });
      if (baseRespBean.isSuccess && Code.isDocSuccess(baseRespBean.bizCode)) {
        return UserInfoModelEntity.fromJson(baseRespBean.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  ///官方社群，商务合作，应用中心
  static Future<List<OfficeItemData>>? officialListReq(int type) async {
    try {
      BaseRespBean baseRespBean = await HttpRequest()
          .get('/official/list', queryParameters: {"type": type});
      return OfficeItemData.toList(baseRespBean.data);
    } catch (e) {
      return [];
    }
  }

  ///兑换码列表
  static Future<ExchangeRecordListModel?> getExchangeRecordList(int pageNumber,
      {int pageSize = 10}) async {
    try {
      BaseRespBean baseRespBean = await HttpRequest()
          .get('activation/redeemCode/records', queryParameters: {
        "page": pageNumber,
        "size": pageSize,
      });

      if (baseRespBean.isSuccess && Code.isDocSuccess(baseRespBean.bizCode)) {
        return ExchangeRecordListModel.fromJson(baseRespBean.data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  ///兑换码key
  static Future<String?> getExchangeCodeKeyReq() async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('activation/redeemCode/idempotencyKey');
    if (baseRespBean.isSuccess && Code.isDocSuccess(baseRespBean.bizCode)) {
      return baseRespBean.data?.toString() ?? '';
    }
    return null;
  }

  ///请求兑换码
  static Future<bool> exchangeCodeReq(String code, String key) async {
    BaseRespBean baseRespBean = await HttpRequest().post(
        'activation/redeemCode/use',
        queryParameters: {"redeemCode": code, "idempotencyKey": key});
    return baseRespBean.isSuccess && Code.isDocSuccess(baseRespBean.bizCode);
  }

  ///isLike: 1 点赞 0 取消点赞
  static Future<bool> likeVideo(String id, int isLike) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('cms/vod/like', queryParameters: {
      'id': id,
      'isLike': isLike,
    });
    return baseRespBean.isSuccess && Code.isDocSuccess(baseRespBean.bizCode);
  }

  // static Future<dynamic> cancelLikeVideo(data) async {
  //   BaseRespBean baseRespBean =
  //       await HttpRequest().post('/cartoon/do/unlike', data: data);
  //   return baseRespBean.toJson();
  // }

  ////cartoon/play/leaderboard
  static Future<dynamic> getHotRanking(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/rank', queryParameters: data);
    return baseRespBean.toJson();
  }

  /// 已购作品
  /// [kind]  0动漫 1漫画 2角色扮演 3真人 4小说 5写真 6禁播
  /// [pageNumber] 页码
  /// [pageSize] 页数
  /// [sort]
  static Future<BaseRespBean> getCartoonBrought(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/brought', queryParameters: data);
    return baseRespBean;
  }

  static Future<dynamic> getPublished(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/mine/collection', queryParameters: data);
    return baseRespBean.data;
  }

  ///邀请码
  static Future<BaseRespBean> inviteBind(String promotionCode) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/mine/inviteBind', data: {
      "promotionCode": promotionCode,
    });
    return baseRespBean;
  }

  ///绑定手机号（短信验证码）
  static Future<dynamic> mobileBind(String mobile, String code) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/mine/mobileBind', data: {
      "mobile": mobile,
      "code": code,
    });
    return baseRespBean.toJson();
  }

  ///发送手机验证码
  static Future<dynamic> sendSmsCode(String mobile, int type) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/notification/captcha', data: {
      "mobile": mobile,
      "type": type,
    });
    return baseRespBean.toJson();
  }

  ///获取观阅券
  static Future<BaseRespBean> getGoldVideoCoupons() async {
    BaseRespBean baseRespBean = await HttpRequest().get('/mine/rights');
    return baseRespBean;
  }

  ///签到
  static Future<BaseRespBean> taskSign() async {
    BaseRespBean baseRespBean = await HttpRequest().post('/task/sign');
    return baseRespBean;
  }

  ///获取首页公告
  static Future<BaseRespBean> getAnnouncement() async {
    BaseRespBean baseRespBean = await HttpRequest().get('/modules/announce');
    return baseRespBean;
  }

  static Future<HappyModel> happyList() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {};
    _data.removeWhere((k, v) => v == null);
    final _result = await HttpRequest().get(
      '/recreation/list',
      queryParameters: queryParameters,
      options: Options(
        method: 'GET',
        headers: <String, dynamic>{},
        extra: _extra,
      ),
    );
    final value = _result.data;
    return HappyModel.fromJson(value);
  }

  //娱乐模块点击统计事件接口
  // id  点击id
  // type  广告类型. app 或 adv
  static Future<dynamic> recreationList(String id, String type) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {
      "id": id,
      "type": type,
      "sysType": "android",
    };
    final _result = await HttpRequest().post('/recreation/click',
        queryParameters: queryParameters,
        options: Options(
          method: 'POST',
          headers: <String, dynamic>{},
          extra: _extra,
        ),
        data: _data);
    return _result.data;
  }

  static Future<dynamic> getOriginalBannerVideo() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {};
    _data.removeWhere((k, v) => v == null);
    final _result = await HttpRequest().get(
      '/modules/original/medias',
      queryParameters: queryParameters,
      options: Options(
        method: 'GET',
        headers: <String, dynamic>{},
        extra: _extra,
      ),
    );
    return _result.data;
  }

  static Future<dynamic> getOriginalArea() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = {};
    _data.removeWhere((k, v) => v == null);
    final _result = await HttpRequest().get(
      '/modules/original/sections',
      queryParameters: queryParameters,
      options: Options(
        method: 'GET',
        headers: <String, dynamic>{},
        extra: _extra,
      ),
    );

    /*List<OriginalAreaData> lists = [];
    _result.data.forEach((v) {
      lists.add(OriginalAreaData.fromJson(v));
    });*/

    return _result.data;
  }

  static Future<BaseRespBean> postSign(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/sign_record/resign', data: data);
    return baseRespBean;
  }

  ///请求头像框列表
  static Future<AvatarBorderData?> headImageBorderListReq() async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/photoFrame/list', queryParameters: {
      "page": 1,
      "pageSize": 30,
    });

    return AvatarBorderData.fromJson(baseRespBean.data);
  }

  static Future<dynamic> requestAvatarBorder(String id) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/photoFrame/unlock', data: {"id": id});
    return baseRespBean;
  }

  static Future<BaseRespBean> getPurchaesedPost(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/mine/buyVid', queryParameters: data);
    return baseRespBean;
  }
}
