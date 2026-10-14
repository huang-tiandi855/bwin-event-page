import 'package:comics_app/common/entities/modules_config/modules_config.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/http/http_request.dart';

class ModuleApi {
  /// 获取各模块分类列表数据
  /// [videoType] 0 普通视频， 1， 短视频， 2，暗网视频
  static Future<ModulesConfig> getHomeModuleList(int videoType) async {
    final param = <String, dynamic>{
      'videoType': videoType,
    };
    param.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean =
        await HttpRequest().get('cms/groups', queryParameters: param);
    final dynamic data = baseRespBean.data;
    if (data is List<dynamic>) {
      return ModulesConfig.fromGroupList(data, videoType);
    }
    if (data is Map<String, dynamic>) {
      return ModulesConfig.fromJson(
        Map<String, Object?>.from(data),
        videoType: videoType,
      );
    }
    if (data is Map) {
      return ModulesConfig.fromJson(
        Map<String, Object?>.from(data),
        videoType: videoType,
      );
    }
    return ModulesConfig();
  }

  static Future<BaseRespBean> getVidModuleDetail(
    String id, {
    String? coverSort,
    String? coverType,
    int? moduleSort,
    String? subModuleId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final param = <String, dynamic>{
      'pageSize': pageSize,
      'page': pageNumber,
      'moduleSort': moduleSort,
      'coverType': coverType,
      'coverSort': coverSort,
      'subModuleId': subModuleId
    };
    param.removeWhere((k, v) => v == null);
    BaseRespBean baseRespBean =
        await HttpRequest().get('/vid/module/$id', queryParameters: param);

    return baseRespBean;
  }

}
