import 'dart:typed_data';

import 'package:comics_app/common/widgets/custom_picture_management.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// 发布页·图片展示样式（与后端 `displayStyle` 字段对齐）。
enum PublishImageStyle {
  /// 平铺
  tile(0, '平铺展示'),

  /// 九宫格
  nineGrid(1, '九宫格展示');

  const PublishImageStyle(this.value, this.label);

  /// 与后端约定的整型值。
  final int value;

  /// 列表 / 底部弹窗中展示的文案。
  final String label;
}

class PublishState {
  ScrollController scrollController = ScrollController();

  TextEditingController textEditingController = TextEditingController();

  TextEditingController textContentEditingController = TextEditingController();

  TextEditingController textEditingCoinController = TextEditingController();

  late List<String> picList = [];

  late List<String> videoPicList = [];

  late List<Uint8List> picWebList = [];

  late String videoPath = "";

  late UploadType uploadType;

  /// 图片展示样式；`null` 表示用户尚未选择。
  PublishImageStyle? imageDisplayStyle;

  int? playTime;
  int? size;

  int? width;
  int? height;

  double? aspectRatio;
  String? filename;
  String? mimeType;
  String? ratio;

  String? videoFileId = "";
  String? videoRemotePath = "";

  String? videoRemoteCoverPath = "";

  List<int> selectedCoins = [
    10,
    20,
    30,
    40,
    50,
    70,
    80,
    90,
  ];

  int? selectedCoin = 0;

  List<String> uploadImagesLists = [];

  PublishState() {
    ///Initialize variables
    uploadType = Get.arguments?["type"] ?? UploadType.UPLOAD_IMG;
  }
}
