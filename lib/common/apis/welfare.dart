import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';

class WelfareApi {
  ///获取活动
  /// [pageNumber] 页码
  /// [pageSize] 每页条数
  static Future<BaseRespBean> getAnnou(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/annou/msg/list', queryParameters: data);
    return baseRespBean;
  }

  static Future<BaseRespBean> getAnnouDetail(String? id) async {
    BaseRespBean baseRespBean =
    await HttpRequest().get('/annou/msg/getById', queryParameters: {"id": id});
    return baseRespBean;
  }
}
