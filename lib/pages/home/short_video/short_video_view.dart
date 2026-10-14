import 'package:comics_app/short_video/page_view/short_video_page_view.dart';
import 'package:comics_app/common/entities/moreVideo.dart';
import 'package:comics_app/common/entities/post_entity.dart';
import 'package:comics_app/common/entities/video_model/ishort_video_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'short_video_logic.dart';
import 'short_video_state.dart';

class ShortVideoPage extends StatelessWidget {
  const ShortVideoPage({
    Key? key,
    required this.videoInfo,
    this.isFromUserHome = false,
    this.isMore = true,
    this.moreVideoArgs,
  }) : super(key: key);

  final PostList videoInfo;
  final bool isFromUserHome;
  final bool isMore;
  final MoreVideo? moreVideoArgs;

  String get tag => hashCode.toString();

  ShortVideoLogic get logic => Get.find<ShortVideoLogic>(
        tag: tag,
      );

  ShortVideoState<ShortVideoModel> get state => logic.state;

  @override
  Widget build(BuildContext context) {
    Get.put<ShortVideoLogic>(
      ShortVideoLogic(
        videoInfo: videoInfo,
        isFromUserHome: isFromUserHome,
        isMore: isMore,
        moreVideoArgs: moreVideoArgs,
      ),
      tag: tag,
    );
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0C),
      resizeToAvoidBottomInset: false,
      body: ShortVideoPageView<ShortVideoLogic>(tag: tag),
    );
  }
}
