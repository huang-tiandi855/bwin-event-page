import 'package:comics_app/common/http/http_request.dart';

import '../http/base_resp_bean.dart';

class AiKeJiApi {
  static Future<BaseRespBean> getAIClothModelList() async {
    BaseRespBean baseRespBean = await HttpRequest().get('/ai/mod/list', queryParameters: {});
    return baseRespBean;
  }

  static Future<BaseRespBean> aiFaceVideoGenerate({
    List<String>? picture,
    String? vidModId,
    List<String>? discount,
  }) async {
    final _data = {'picture': picture, 'vidModId': vidModId, 'discount': discount};
    _data.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean = await HttpRequest().post('/ai/changeface/generate', data: _data);
    return baseRespBean;
  }

  static Future<BaseRespBean> aiFaceImgGenerate({
    String? originPic,
    String? mId,
  }) async {
    final _data = {'originPic': originPic, 'mId': mId};
    _data.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean = await HttpRequest().post('/ai/img/generate', data: _data);
    return baseRespBean;
  }

  //获取AI脱衣记录列表 status 1、进行中 2、生成成功 3、生成失败
  static Future<BaseRespBean> getAiRecordList(
    int pageNumber,
    int pageSize,
    int status,
  ) async {
    final queryParameters = <String, dynamic>{
      'page': pageNumber,
      'pageSize': pageSize,
      'status': status,
    };
    BaseRespBean baseRespBean = await HttpRequest().get(
      '/ai/undress/list',
      queryParameters: queryParameters,
    );
    return baseRespBean;
  }

  //获取AI图片换脸记录列表 status 1、进行中 2、生成成功 3、生成失败
  static Future<BaseRespBean> getAiFacePictureRecordList(
    int pageNumber,
    int pageSize,
    int status,
  ) async {
    final queryParameters = <String, dynamic>{
      'page': pageNumber,
      'pageSize': pageSize,
      'status': status,
    };
    BaseRespBean baseRespBean = await HttpRequest().get(
      '/ai/img/list',
      queryParameters: queryParameters,
    );
    return baseRespBean;
  }

  //获取AI视频换脸记录列表  status 1、进行中 2、生成成功 3、生成失败
  static Future<BaseRespBean> getAiFaceRecordList(
    int pageNumber,
    int pageSize,
    int status,
  ) async {
    final queryParameters = <String, dynamic>{
      'page': pageNumber,
      'pageSize': pageSize,
      'status': status,
    };
    BaseRespBean baseRespBean = await HttpRequest().get(
      '/ai/changeface/list',
      queryParameters: queryParameters,
    );
    return baseRespBean;
  }

  static Future<BaseRespBean> deleteAiBill({
    String? id,
  }) async {
    final _data = {'id': id};
    _data.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean = await HttpRequest().post('/ai/undress/hide', data: _data);
    return baseRespBean;
  }

  static Future<BaseRespBean> deleteAiFaceBill({
    String? id,
  }) async {
    final _data = {'id': id};
    _data.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean = await HttpRequest().post('/ai/changeface/hide', data: _data);
    return baseRespBean;
  }

  static Future<BaseRespBean> deleteAiImageFaceBill({
    String? id,
  }) async {
    final _data = {'id': id};
    _data.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean = await HttpRequest().post('/ai/img/hide', data: _data);
    return baseRespBean;
  }

  //生成AI脱衣记录
  static Future<BaseRespBean> aiGenerate(
    String originPic,
    String coin,
  ) async {
    final data = {'originPic': originPic};

    BaseRespBean baseRespBean = await HttpRequest().post('/ai/undress/generate', data: data);

    return baseRespBean;
  }
}
