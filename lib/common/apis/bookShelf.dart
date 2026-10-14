import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';

class BookApi {
  ///获取媒体
  /// [mediaID] 媒体ID
  static Future<BaseRespBean> getMediaInfo(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/media/info', queryParameters: data);
    return baseRespBean;
  }

  ///同类作品
  /// [kind]   4小说
  /// [pageNumber] 页码
  /// [pageSize] 页数
  /// [sort]
  static Future<BaseRespBean> getCartoonHot(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/hot', queryParameters: data);
    return baseRespBean;
  }

  /// 收藏媒体
  /// [kind]   4小说
  /// [mediaID] 媒体ID
  static Future<BaseRespBean> cartoonCollcet(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/cartoon/do/collect', data: data);
    return baseRespBean;
  }

  /// 取消收藏媒体
  /// [kind]   4小说
  /// [mediaID] 媒体ID
  static Future<BaseRespBean> cartoonUncollect(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().post('/cartoon/do/uncollect', data: data);
    return baseRespBean;
  }

  static Future<BaseRespBean> cartoonLike(data) async {
    BaseRespBean baseRespBean =
    await HttpRequest().post('/cartoon/do/like', data: data);
    return baseRespBean;
  }

  static Future<dynamic> cancelCartoonLike(data) async {
    BaseRespBean baseRespBean =
    await HttpRequest().post('/cartoon/do/unlike', data: data);
    return baseRespBean;
  }
  /// 获取收藏媒体
  /// [kind]  0动漫 1漫画 2角色扮演 3真人 4小说 5写真 6禁播
  /// [pageNumber] 页码
  /// [pageSize] 页数
  /// [sort]
  static Future<BaseRespBean> getCartoonCollectList(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/collect', queryParameters: data);
    return baseRespBean;
  }

  /// 获取收藏媒体
  /// [kind]  0动漫 1漫画 2角色扮演 3真人 4小说 5写真 6禁播
  /// [pageNumber] 页码
  /// [pageSize] 页数
  static Future<BaseRespBean> getCartoonRandom(data) async {
    BaseRespBean baseRespBean =
        await HttpRequest().get('/cartoon/random', queryParameters: data);
    return baseRespBean;
  }


}
