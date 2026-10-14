import 'dart:convert';

import 'package:comics_app/common/entities/country_code.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

export '../routers/app_navigator.dart';
export 'history/history_operation.dart';

/// 保存数据到相册
Future<bool> savePngDataToAblumn(Uint8List pngBytes) async {
  /*Map<Permission, PermissionStatus> statuses = await [
    Permission.photos,
    Permission.storage,
  ].request();*/

  AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
  String? androidVersion = androidInfo.version.release;

  PermissionStatus status;

  if (int.parse(androidVersion) <= 12) {
    status = await Permission.storage.request();
  } else {
    status = await Permission.mediaLibrary.request();
    //status = await Permission.photos.request();
  }

  if (status.isDenied) {
    await Permission.storage.request();
    showToast(msg: "请检查权限是否开启");
    return false;
  }

  var map = await ImageGallerySaver.saveImage(pngBytes);
  if (null != map && map["isSuccess"] == true) {
    showToast(msg: "保存成功");
    return true;
  } else {
    showToast(msg: "保存失败，请手动截图");
    return false;
  }
}

///获取城市列表
Future<List<CountryCode>> getCountryCodes() async {
  String jsonString =
      await rootBundle.loadString("assets/json/country_code.json");
  Map<String, dynamic> jsonResultList = json.decode(jsonString);
  List<CountryCode> list = CountryCodeEntity.fromJson(jsonResultList);
  return list;
}

closeKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);

  /// 键盘是否是弹起状态
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
