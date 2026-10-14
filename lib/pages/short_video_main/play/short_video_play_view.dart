import 'package:comics_app/common/entities/pagination_model.dart';
import 'package:comics_app/common/entities/video_model/ishort_video_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/short_video/page_view/short_video_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'short_video_play_logic.dart';
import 'short_video_play_state.dart';

class ShortVideoPlayPage extends StatelessWidget {
  const ShortVideoPlayPage({
    super.key,
    this.videoProvider,
    this.initialList = const [],
    this.initialIndex,
  });

  final List<VideoModel> initialList;
  final int? initialIndex;
  final Future<PaginationModel<VideoModel>> Function()? videoProvider;

  String get tag => hashCode.toString();

  ShortVideoPlayLogic get logic => Get.find<ShortVideoPlayLogic>(
        tag: tag,
      );

  ShortVideoPlayState<ShortVideoModel> get state => logic.state;

  @override
  Widget build(BuildContext context) {
    Get.put<ShortVideoPlayLogic>(
      ShortVideoPlayLogic(
        videoProvider: videoProvider,
        initialIndex: initialIndex,
        initialList: initialList,
      ),
      tag: tag,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.scaffoldBackground,
      body: ShortVideoPageView<ShortVideoPlayLogic>(tag: tag),
    );
  }
}
