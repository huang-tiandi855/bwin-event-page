
import 'package:dio/dio.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/services.dart';

/// 请求header拦截器
/// 主要是为每个请求添加header
class CustomHttpClientAdapter extends HttpClientAdapter{
  String dnsIp;
  CustomHttpClientAdapter(this.dnsIp);

  @override
  void close({bool force = false}) {
  }

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future? cancelFuture) async{
    // TODO: implement fetch
    // 在请求发送之前进行拦截处理
    // 在这里可以对请求进行修改或添加额外的头部信息
    // var data = {"code":0,"msg":"success","time":"2023-03-16T10:02:40.699Z", "data":null};
    const platform = MethodChannel('samples.flutter.io/requestApi');
    final String result = await platform.invokeMethod('requestApi',
        { 'queryParameters': options.uri.queryParameters,
          'extra': options.extra,
          'path': options.uri.path,
          'host': options.uri.host,
          'method': options.method,
          'headers':options.headers,
          'parameters': options.queryParameters,
          'url':options.baseUrl,
          'bodyParameters':options.data,
          'dnsIp':dnsIp,
        }
    );

    LogUtil.e("result===$result",tag: "原生返回数据=====", );

    return ResponseBody.fromString(result, 200);
  }



  /*@override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>> requestStream, Future cancelFuture) async{
    // 在请求发送之前进行拦截处理
    // 在这里可以对请求进行修改或添加额外的头部信息
    // var data = {"code":0,"msg":"success","time":"2023-03-16T10:02:40.699Z", "data":null};
    const platform = MethodChannel('samples.flutter.io/requestApi');
    final String result = await platform.invokeMethod('requestApi',
        { 'queryParameters': options.uri.queryParameters,
          'extra': options.extra,
          'path': options.uri.path,
          'host': options.uri.host,
          'method': options.method,
          'headers':options.headers,
          'parameters': options.queryParameters,
          'url':options.baseUrl,
          'bodyParameters':options.data,
          'dnsIp':dnsIp,
         }
    );

      LogUtil.e("result===$result",tag: "原生返回数据=====", );

    var data = result;
    return ResponseBody.fromString(result, 200);
  }*/

}
