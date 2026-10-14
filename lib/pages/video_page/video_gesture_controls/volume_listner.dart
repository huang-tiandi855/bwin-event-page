import 'dart:async';

import 'package:flutter_volume_controller/flutter_volume_controller.dart';

class VolumeListener {
  late StreamController<double> _volumeStreamController;
  Stream<double> get onCurrentVolumeChanged => _volumeStreamController.stream;

  // 单例
  static VolumeListener? _instance;

  factory VolumeListener() {
    _instance ??= VolumeListener._();
    return _instance!;
  }

  VolumeListener._() {
    _volumeStreamController = StreamController.broadcast();
    FlutterVolumeController.addListener((v) {
      _volumeStreamController.add(v);
    });
  }
}
