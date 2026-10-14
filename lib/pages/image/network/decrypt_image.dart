import 'dart:typed_data';

import 'package:get/get.dart';

import 'package:comics_app/common/store/config.dart';

import 'network_image_codec.dart';

/// 磁盘缓存 / Dio 拉流后的统一解码入口（与 Web XOR + 旧 CDN 兼容）。
Uint8List decryptImage(Uint8List imgBytes) {
  bool xor = false;
  if (Get.isRegistered<ConfigStore>()) {
    xor = ConfigStore.to.configBean.imageSecret == '1';
  }
  return decodeFetchedBody(imgBytes, xorEnabled: xor);
}
