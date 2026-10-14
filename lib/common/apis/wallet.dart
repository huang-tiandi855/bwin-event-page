import 'dart:convert';

import 'package:comics_app/common/entities/wallet_model.dart';
import 'package:comics_app/common/entities/wallet_product_list_model.dart';
import 'package:comics_app/common/entities/wallet_recharge_url_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/widgets/countdown_update_model.dart';

class WalletApi {
  ///vip 列表请求
  static Future<dynamic> vipDataListReq() async {
    final queryParameters = <String, dynamic>{'status': 1};
    BaseRespBean baseRespBean = await HttpRequest()
        .get('/vip/product', queryParameters: queryParameters);
    return NewProductList.fromJson(baseRespBean.toJson());
  }

  ///进行官方充值
  static Future<dynamic> startToPayReq(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/mine/topay', data: data);
    return RechargeUrlModel.fromJson(baseRespBean.toJson());
  }

  ///获取钱包
  static Future<WalletModel> getWallet() async {
    BaseRespBean baseRespBean = await HttpRequest().get('/mine/wallet');
    return WalletModel.fromJson(baseRespBean.data);
  }

  ///vip 新人倒计时
  static Future<Countdown> vipCutDownReq() async {
    final BaseRespBean baseRespBean =
        await HttpRequest().get('/vip/tiroCountdown');
    final dynamic data = baseRespBean.data;
    if (data is Map) {
      return Countdown.fromJson(Map<String, dynamic>.from(data));
    }
    if (data is String) {
      final String s = data.trim();
      if (s.isEmpty) return Countdown();
      try {
        final dynamic decoded = json.decode(s);
        if (decoded is Map) {
          return Countdown.fromJson(Map<String, dynamic>.from(decoded));
        }
      } catch (_) {
        final int? seconds = int.tryParse(s);
        if (seconds != null) return Countdown(countdownSec: seconds);
      }
    }
    if (data is num) {
      return Countdown(countdownSec: data.toInt());
    }
    return Countdown();
  }

  ///获取提现记录
  static Future<BaseRespBean> getWithdrawOlder(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/withdraw/order', queryParameters: data);
    return baseRespBean;
  }

  ///获取账单
  static Future<BaseRespBean> queryBill(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/mine/zqzhangdan', queryParameters: data);
    return baseRespBean;
  }

  ///收益明细
  static Future<BaseRespBean> queryIncomes(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/mine/iIncomes', queryParameters: data);
    return baseRespBean;
  }

  static Future<BaseRespBean> getTax() async {
    BaseRespBean baseRespBean = await HttpRequest().get('/withdraw/cfg');
    return baseRespBean;
  }

  ///提现
  static Future<BaseRespBean> withDraw(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/withdraw', data: data);

    return baseRespBean;
  }

  static Future<BaseRespBean> getBankCardList() async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/mine/txnact/bank/get');

    return baseRespBean;
  }

  static Future<BaseRespBean> postAddBankCard({
    String? actName, // 账户姓名
    String? act, // 账户号
    String? bankCode, //银行代号
    String? cardType, // 卡类型
  }) async {
    final data = <String, dynamic>{
      'actName': actName,
      'act': act,
      'bankCode': bankCode,
      'cardType': cardType,
    };
    data.removeWhere((key, value) => value == null);
    BaseRespBean baseRespBean =
        await HttpRequest().post('/mine/txnact/bank/add', data: data);

    return baseRespBean;
  }

  static Future<BaseRespBean> bankCardDelete(String? id) async {
    BaseRespBean baseRespBean =
        await HttpRequest().delete('/mine/txnact/del', data: {"id": id});
    return baseRespBean;
  }

  static Future<BaseRespBean> getAiChangeFaceTicket(data) async {
    BaseRespBean baseRespBean = await HttpRequest().get(
      '/backpack',
      queryParameters: data,
    );
    return baseRespBean;
  }

  //ai女友用户余额查询
  static Future<BaseRespBean> getAiBalance(data) async {
    BaseRespBean baseRespBean = await HttpRequest().get(
      '/aimate/getBalance',
      queryParameters: data,
    );
    return baseRespBean;
  }

  //获取ai女友url
  static Future<BaseRespBean> getAiFriendUrl(data) async {
    BaseRespBean baseRespBean = await HttpRequest().get(
      '/aimate/login',
      queryParameters: data,
    );
    return baseRespBean;
  }

  //获取AI女友货币列表
  static Future<BaseRespBean> getAiFriendCurrencys(data) async {
    BaseRespBean baseRespBean = await HttpRequest().get(
      '/aimate/currencys',
      queryParameters: data,
    );
    return baseRespBean;
  }

  //AI女友积分兑换
  static Future<BaseRespBean> exchangeAiFriend(data) async {
    BaseRespBean baseRespBean = await HttpRequest().post(
      '/aimate/exchange',
      data: data,
    );
    return baseRespBean;
  }
}
