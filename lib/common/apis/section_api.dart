import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';

class SectionApi {
  static Future<BaseRespBean> getMedialTopicDetailList({
    required String sectionId,
    int? sortType,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    BaseRespBean baseRespBean = await HttpRequest().get(
      '/cartoon/topic',
      queryParameters: {
        'sId': sectionId,
        'sortType': sortType,
        'page': pageNumber,
        'pageSize': pageSize,
      }..removeWhere((key, value) => value == null),
    );

    return baseRespBean;
  }
}
