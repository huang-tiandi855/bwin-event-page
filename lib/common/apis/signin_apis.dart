import 'package:comics_app/common/entities/sign_in/points_exchange_entity.dart';
import 'package:comics_app/common/entities/sign_in/points_exchange_record_entity.dart';
import 'package:comics_app/common/entities/sign_in/sign_in_overview_entity.dart';
import 'package:comics_app/common/entities/sign_in/welfare_task_entity.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';

class SignInApis {
  /// 获取签到相关数据
  static Future<SignInOverviewResultModel?> getSignInData() async {
    final BaseRespBean baseRespBean =
        await HttpRequest().post('activation/signin/v2/overview');
    if (!baseRespBean.isSuccess) {
      return null;
    }
    final dynamic d = baseRespBean.data;
    final Map<String, dynamic>? m = d is Map<String, dynamic>
        ? d
        : (d is Map ? Map<String, dynamic>.from(d) : null);
    if (m == null) {
      return null;
    }
    return SignInOverviewResultModel.fromJson(m);
  }

  /// 免费签到（日签）
  static Future<BaseRespBean> clickFreeSignIn() async {
    final BaseRespBean baseRespBean =
        await HttpRequest().post('activation/signin/v2/daily');
    return baseRespBean;
  }

  /// VIP / 会员签到
  static Future<BaseRespBean> clickVipSignIn() async {
    final BaseRespBean baseRespBean =
        await HttpRequest().post('activation/signin/v2/vip');
    return baseRespBean;
  }

  /// 获取积分兑换奖品列表（失败或 `data` 非数组时返回空列表）。
  static Future<List<PointsExchangeProductModel>> getPointsExchangeList(
      {int pageNumber = 1,
      int pageSize = 100,
      Map<String, dynamic>? paramV}) async {
    final param = paramV ??
        <String, dynamic>{
          'size': pageSize,
          'page': pageNumber,
        };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean =
        await HttpRequest().post('activation/points/product/list', data: param);
    if (!baseRespBean.isSuccess) {
      return const [];
    }
    return PointsExchangeProductModel.listFromData(baseRespBean.data);
  }

  /// 获取福利中心任务列表（`activation/welfare/center`），成功时解析 `data` 对象。
  static Future<WelfareTaskCenterModel?> getWelfaretaskList() async {
    final BaseRespBean baseRespBean =
        await HttpRequest().get('activation/welfare/center');
    if (!baseRespBean.isSuccess) {
      return null;
    }
    return WelfareTaskCenterModel.tryFromData(baseRespBean.data);
  }

  /// 获取积分奖品兑换键值
  static Future<String> getPointsExchangeKey() async {
    final BaseRespBean baseRespBean =
        await HttpRequest().get('activation/points/product/idempotencyKey');
    if (!baseRespBean.isSuccess) {
      return '';
    }
    final dynamic d = baseRespBean.data;
    if (d == null) {
      return '';
    }
    return d.toString();
  }

  /// 通过键值key和奖品id兑换积分奖品
  static Future<BaseRespBean> exchangeRewardByKeyId({
    int? productId,
    String? idempotencyKey,
    Map<String, dynamic>? paramV,
  }) async {
    final param = paramV ??
        <String, dynamic>{
          'productId': productId,
          'idempotencyKey': idempotencyKey,
        };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean = await HttpRequest()
        .get('activation/points/product/exchange', queryParameters: param);
    return baseRespBean;
  }

  /// 获取积分兑换记录（失败或 `data` 非数组时返回空列表）。
  static Future<List<PointsExchangeRecordModel>> getPointsExchangeRecordList({
    int pageNumber = 1,
    int pageSize = 30,
    Map<String, dynamic>? paramV,
  }) async {
    final param = paramV ??
        <String, dynamic>{
          'pageSize': pageSize,
          'page': pageNumber,
        };
    param.removeWhere((k, v) => v == null);
    final BaseRespBean baseRespBean = await HttpRequest().get(
        'activation/points/product/exchange/records',
        queryParameters: param);
    if (!baseRespBean.isSuccess) {
      return const [];
    }
    return PointsExchangeRecordModel.listFromData(baseRespBean.data);
  }
}
