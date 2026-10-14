import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';

class ACGApi {
  static Future<BaseRespBean> getRank(
      {String? kind,
      int pageNumber = 1,
      int pageSize = 10,
      Map<String, dynamic>? paramV}) async {
    final param = paramV ??
        <String, dynamic>{
          'pageSize': pageSize,
          'page': pageNumber,
          'kind': kind
        };
    param.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/rank', queryParameters: param);

    return baseRespBean;
  }

  static Future<BaseRespBean> getNovalContent(String id) async {
    final param = <String, dynamic>{'id': id};
    param.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean = await HttpRequest()
        .get('/cartoon/media_content/info', queryParameters: param);

    return baseRespBean;
  }

  /// 产品购买
  /// [productType] 产品类型(0 vip/1 video)  //动漫17    //漫画18    //cos19    //真人21  //禁播22
  /// [productID] 产品id
  /// [chapterID] 章节id
  static Future<BaseRespBean> productNewBuy(
      {String? chapterID,
      String? couponId,
      int? goldVideoCouponNum,
      required String productID,
      int? productType}) async {
    var data = {
      "productID": productID,
      "chapterID": chapterID,
      "couponId": couponId,
      "goldVideoCouponNum": goldVideoCouponNum,
      "productType": productType,
      "isH5": false,
    };
    data.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean =
        await HttpRequest().post('/product/buy', data: data);
    return baseRespBean;
  }

  static Future<dynamic> getHotCategory(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/tags/media', queryParameters: data);
    return baseRespBean.toJson();
  }

  static Future<dynamic> searchNewKeyWord(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/search', queryParameters: data);
    return baseRespBean.toJson();
  }

  static Future<BaseRespBean> searchNewTags(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/searchByTag', queryParameters: data);
    return baseRespBean;
  }

  static Future<BaseRespBean> getTagsList(
      {int? kind,
      int? pageNumber,
      int? pageSize,
      required int sortType,
      required String tid}) async {
    var data = {
      "kind": kind,
      "page": pageNumber,
      "pageSize": pageSize,
      "sortType": sortType,
      "tid": tid
    };
    data.removeWhere((key, value) => value == null);
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/tags/list', queryParameters: data);
    return baseRespBean;
  }

}
