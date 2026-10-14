import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';

class SignApi {
  static Future<BaseRespBean> getDayMark() async {
    final _data = <String, dynamic>{};
    BaseRespBean baseRespBean =
        await HttpRequest().get('/task/sign', queryParameters: _data);
    return baseRespBean;
  }

  static Future<BaseRespBean> postDayMark(String? id) async {
    final _data = {
      'id': id,
    };
    BaseRespBean baseRespBean =
        await HttpRequest().post('/task/sign', data: _data);
    return baseRespBean;
  }

  static Future<BaseRespBean> getJiFenTaskList(int pageNumber, int pageSize) async {
    ArgumentError.checkNotNull(pageNumber, 'page');
    ArgumentError.checkNotNull(pageSize, 'pageSize');
    final queryParameters = <String, dynamic>{
      'page': pageNumber,
      'pageSize': pageSize,
    };
    BaseRespBean baseRespBean = await HttpRequest()
        .get('/point/list', queryParameters: queryParameters);
    return baseRespBean;
  }

  Future<BaseRespBean> getJiFenExchange(String? id) async {
    final _data = {
      'id': id,
    };
    _data.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean =
        await HttpRequest().post('/point/exchange', data: _data);
    return baseRespBean;
  }

 static Future<BaseRespBean> doDailyTask(String? taskId) async {
    final _data = {'id': taskId};
    _data.removeWhere((k, v) => v == null);
    BaseRespBean _result = await HttpRequest()
        .post('/task/completeDaily', data: _data);
    return _result;
  }

  static Future doOnceTask(String? taskId)async {
    final _data = {'id': taskId,};
    _data.removeWhere((k, v) => v == null);
    BaseRespBean _result = await HttpRequest()
        .post('/task/completeOnce', data: _data);
    return _result;
  }

  static Future<dynamic> postOnceClickTask(String? taskId) async {
    final _data = {'id': taskId};
    _data.removeWhere((k, v) => v == null);

    BaseRespBean _result = await HttpRequest()
        .post('/task/onceClick', data: _data);
    return _result;
  }

  static Future<dynamic> getFuliTask() async {
    BaseRespBean baseRespBean =
    await HttpRequest().get('/task/newtask');
    return baseRespBean.data;
  }

  static Future<BaseRespBean> postAddress({String? id, String? name, String? phone, String? address}) async {
    final _data = {'id': id,'name': name,'tel': phone,'addr': address,};
    _data.removeWhere((k, v) => v == null);

    BaseRespBean _result = await HttpRequest()
        .post('/point/inkind', data: _data);
    return _result;
  }
}
