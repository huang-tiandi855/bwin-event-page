import 'package:comics_app/common/store/user.dart';
import 'package:dio/dio.dart';


enum GraphicsType { vip, coin }

///数据埋点 管理类
// 泡芙: 1
// 色中色: 7
// 蜜桃: 15
// 黑料: 13
// 妖精: 14
// 红杏: 16
// 无忧: 17
// 五月天: 18
// 瑶池: 19
// 知音: 20
// 春水: 21
const int appId = 14;

class EventTrackingManager {
  static final EventTrackingManager _instance = EventTrackingManager._();

  factory EventTrackingManager() {
    return _instance;
  }

  EventTrackingManager._();

  static late Dio dio;
  //视频埋点列表 videoId : true
  Map videos = {};

  ///类型 视频：1
  addVideoDatas(videoId, videoTitle) {
    if ((videos[videoId] ?? false)) {
      return;
    }
    videos[videoId] = true;
    final _data = {
      'dataType': 1,
      'videoDatas': {
        'appId': appId,
        'videoId': videoId,
        'videoTitle': videoTitle,
        'userType': UserStore.to.isVip() ? 1 : 2
      }
    };
    _post(_data, '视频');
  }

  ///类型 视频：1
  addEpisodeVideoDatas(videoId, videoTitle) {
    final _data = {
      'dataType': 1,
      'videoDatas': {
        'appId': appId,
        'videoId': videoId,
        'videoTitle': videoTitle,
        'userType': UserStore.to.isVip() ? 1 : 2
      }
    };
    _post(_data, '视频');
  }

  ///类型 标签：2
  addTagsDatas(tagsName) {
    final _data = {
      'dataType': 2,
      'tagDatas': {
        'appId': appId,
        'tagsName': tagsName,
        'userType': UserStore.to.isVip() ? 1 : 2
      }
    };
    _post(_data, '标签');
  }

  ///类型 充值：3
  //graphicsId  视频传视频id   横幅传banner   用户自己传user
  //graphicsType 充值类型 1 金币 2 VIP
  static String _graphicsId = 'user';
  static String _graphicsTitle = 'user';
  static GraphicsType _graphicsType = GraphicsType.coin;
  addVideoVipGraphicss(videoId, videoTitle, GraphicsType graphicsType) {
    _graphicsId = videoId;
    _graphicsTitle = videoTitle;
    _graphicsType = graphicsType;
    // _addVipGraphicss(videoId, videoTitle, graphicsType);
  }

  addBannerVipGraphicss(GraphicsType graphicsType) {
    _graphicsId = 'banner';
    _graphicsTitle = 'banner';
    _graphicsType = graphicsType;
    // _addVipGraphicss('banner', 'banner', graphicsType);
  }

  addUserVipGraphicss(GraphicsType graphicsType) {
    _graphicsId = 'user';
    _graphicsTitle = 'user';
    _graphicsType = graphicsType;
    // _addVipGraphicss('user', 'user', graphicsType);
  }

  addVipGraphicss() {
    final _data = {
      'dataType': 3,
      'VipGraphicss': {
        'appId': appId,
        'graphicsId': _graphicsId,
        'graphicsTitle': _graphicsTitle,
        'graphicsType': _graphicsType == GraphicsType.coin ? 1 : 2,
        'userType': UserStore.to.isVip() ? 1 : 2
      }
    };
    _post(_data,
        '$_graphicsTitle${_graphicsType == GraphicsType.coin ? '金币' : 'VIP'}充值');
  }

  _post(data, dataType) async {
    /*if (ConfigStore.to.configBean.dataBuriedPoint!.isEmpty) {
      return;
    }
    try {

     // BaseResponse resp = await HttpManager().post(ConfigStore.to.configBean.dataBuriedPoint, params: data);

      dio = Dio();

      var response = await dio.post(
        ConfigStore.to.configBean.dataBuriedPoint ?? "",
        data: data,
        //queryParameters: queryParameters,
        options: Options(
           method: "post",
          // 响应流上前后两次接受到数据的间隔，单位为毫秒。
          receiveTimeout: 4000000,
          // 发送数据 单位为毫秒。
          sendTimeout: 15000,
          responseType: ResponseType.json,
          contentType: 'application/json; charset=utf-8',
        ),
      );

      l.d(data.toString(),tag: "$dataType埋点成功");
      l.d("------------",tag: "$dataType埋点成功");
      l.d(response.toString(),tag: "$dataType埋点成功");
    } catch (e) {
      l.d('EventTracking',tag:  "event tracking...error:$e");
    }*/
  }
}
