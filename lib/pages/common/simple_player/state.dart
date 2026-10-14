import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class SimplePlayerState {
  /// 视频源 URL；为空时点击仅 Toast 提示，不会进入加载流程。
  late String videoUrl;

  /// 封面图（接口字段 `screen`），允许为空，空时仅渲染深色占位底。
  late String coverUrl;

  /// 16:9 容器；初始化完成后 [ChewieController] 也会按此比例渲染，
  /// 避免视频起播瞬间因实际比例不同造成滚动列表里的 layout shift。
  double? aspectRatio;

  bool initializing = false;

  VideoPlayerController? video;
  ChewieController? chewie;

  SimplePlayerState() {
    videoUrl = Get.arguments?['videoUrl'] ?? '';
    coverUrl = Get.arguments?['coverUrl'] ?? '';
    aspectRatio = Get.arguments?['aspectRatio'];
  }
}
