import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';

class VidApi {
  static Future<BaseRespBean> reward({
    required String id,
    required int coins,
  }) async {
    BaseRespBean baseRespBean = await HttpRequest().post('/mine/reward', data: {
      'vid': id,
      'coins': coins.toString(),
      'msg': '',
    });
    return baseRespBean;
  }
}
