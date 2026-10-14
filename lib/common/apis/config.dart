import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/entities/modules_config/king_kong_model.dart';
import 'package:comics_app/common/entities/modules_config/notice_model.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';

import '../utils/logger.dart';

class ConfigApi {
  //获取配置信息
  static Future<ConfigBean> getConfig(
      {String? groupKey, String? key, Map<String, dynamic>? paramV}) async {
    final param = paramV ??
        <String, dynamic>{
          'groupKey': groupKey,
          'key': key,
        };
    param.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean =
        await HttpRequest().get('config/query', queryParameters: param);

    return ConfigBean.fromResponse(
      baseRespBean.data,
      groupKey: groupKey,
      queryKey: key,
    );
  }

  /// 获取广告公告 / 跑马灯（`POST ads/notice/list`）。
  ///
  /// 失败或无数据时返回空列表，调用方无需再判 `isSuccess`。
  static Future<List<NoticeModel>> getAnnounceScrollingLight() async {
    final BaseRespBean resp = await HttpRequest().post('ads/notice/list');
    if (!resp.isSuccess) return const <NoticeModel>[];
    return NoticeModel.listFromData(resp.data);
  }

  /// 获取金刚区按钮（`POST ads/kingKong/list`）。
  ///
  /// 失败或无数据时返回空列表，调用方无需再判 `isSuccess`。
  static Future<List<KingKongModel>> getKingKongList() async {
    final BaseRespBean resp = await HttpRequest().post('ads/kingKong/list');
    if (!resp.isSuccess) return const <KingKongModel>[];
    return KingKongModel.listFromData(resp.data);
  }

  /// 获取广告数据
  static Future<BaseRespBean> getAdsList({String? adsSlotCode}) async {
    final Map<String, dynamic> param = <String, dynamic>{
      'adsSlotCode': adsSlotCode,
    };
    param.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean =
        await HttpRequest().post('ads/fetch/batch', queryParameters: param);
    return baseRespBean;
  }

  /// 点击广告
  static adClickReport(String id, String planId, String slotCode) async {
    l.d('adClickReport()...id=$id, planId=$planId, slotCode=$slotCode',
        tag: 'ads');
    HttpRequest().post('/ads/report', queryParameters: {
      "clickData": [
        {"materialId": id, "planId": planId}
      ],
      "slotCode": slotCode,
    });
  }
}
