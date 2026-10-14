import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/entities/pagination_model.dart';
import 'package:comics_app/common/entities/video_model/tags_model.dart';
import 'package:comics_app/common/entities/video_model/video_model.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/short_video/page_view/short_video_page_view.dart';
import 'package:comics_app/short_video/player/short_video_player.dart';
import 'package:comics_app/pages/short_video_main/play/short_video_play_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/loading_widget.dart';

class ShortVideoVerticalTabView extends StatefulWidget {
  const ShortVideoVerticalTabView({
    super.key,
    required this.module,
    this.moduleSort,
    this.useFollowList = false,
  });

  final ModuleModel module;
  final int? moduleSort;
  final bool useFollowList;

  @override
  State<ShortVideoVerticalTabView> createState() =>
      _ShortVideoVerticalTabViewState();
}

class _ShortVideoVerticalTabViewState extends State<ShortVideoVerticalTabView>
    with AutomaticKeepAliveClientMixin {
  static const int _pageSize = 20;

  late final String _tag =
      'short_video_vertical_${widget.module.id}_${widget.moduleSort}_$hashCode';

  int _pageNumber = 1;
  bool _isLoading = true;
  bool _hasError = false;
  bool _hasNext = true;
  List<VideoModel> _initialList = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    if (Get.isRegistered<ShortVideoPlayLogic>(tag: _tag)) {
      Get.delete<ShortVideoPlayLogic>(tag: _tag);
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final list = await _fetchPage(1);
      if (!mounted) return;
      _pageNumber = 1;
      _hasNext = list.length >= _pageSize;
      _initialList = list.map(_videoFromHomeMedia).toList();

      if (_initialList.isNotEmpty) {
        _initPlayLogic();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _initPlayLogic() {
    if (Get.isRegistered<ShortVideoPlayLogic>(tag: _tag)) return;

    Get.put<ShortVideoPlayLogic>(
      ShortVideoPlayLogic(
        initialList: _initialList,
        videoProvider: _videoProvider,
        controllerTag: _tag,
      ),
      tag: _tag,
    );
  }

  Future<List<MediaVideoModel>> _fetchPage(int pageNumber) async {
    if (widget.useFollowList) {
      return MediaApi.getShortFollowsList(
        page: pageNumber,
        pageSize: _pageSize,
      );
    }

    return HomeApis.getHomeMediaList(
      videoType: VideoType.shortVideo.value,
      sortType: widget.moduleSort,
      pageNumber: pageNumber,
      pageSize: _pageSize,
    );
  }

  Future<PaginationModel<VideoModel>> _videoProvider() async {
    if (!_hasNext) return PaginationModel();

    _pageNumber++;
    final list = await _fetchPage(_pageNumber);
    _hasNext = list.length >= _pageSize;
    return PaginationModel(
      list: list.map(_videoFromHomeMedia).toList(),
      hasNext: _hasNext,
    );
  }

  VideoModel _videoFromHomeMedia(MediaVideoModel model) {
    final picInfo = model.vodPicInfo;
    final verticalCover = _pickNonEmpty([
      model.vodPic,
      picInfo?.verticalLarge,
      picInfo?.verticalSmall,
    ]);
    final cover = _pickNonEmpty([
      picInfo?.horizontalLarge,
      picInfo?.horizontalSmall,
      verticalCover,
    ]);
    final gold = _toInt(model.gold) ?? 0;
    return VideoModel(
      id: model.id,
      newsType: 'SP',
      title: model.title,
      sourceUrl: model.vodSerialNumber?.toString(),
      playTime: model.vodDuration,
      cover: cover,
      verticalCover: verticalCover,
      playCount: model.readNumber,
      coins: gold,
      originCoins: gold,
      freeArea: !model.isVip && gold <= 0,
      isRecommend: (model.recommend ?? 0) > 0,
      tags: _parseTags(model.tags),
    );
  }

  String? _pickNonEmpty(List<String?> values) {
    for (final value in values) {
      final text = value?.trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  List<TagsModel> _parseTags(dynamic raw) {
    if (raw == null) return const [];
    if (raw is String) {
      final name = raw.trim();
      if (name.isEmpty) return const [];
      return [
        TagsModel.fromJson({'name': name})
      ];
    }
    if (raw is! List) return const [];

    return raw.map((item) {
      if (item is Map) {
        return TagsModel.fromJson(Map<String, dynamic>.from(item));
      }
      return TagsModel.fromJson({'name': item.toString()});
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(
        child: LoadingWidget(),
      );
    }

    if (_hasError) {
      return _StatusView(
        text: '加载失败，点击重试',
        onTap: _loadInitialData,
      );
    }

    if (_initialList.isEmpty) {
      return _StatusView(
        text: widget.useFollowList ? '你还未关注' : '暂无短视频',
        onTap: _loadInitialData,
      );
    }

    return ShortVideoPageView<ShortVideoPlayLogic>(
      tag: _tag,
      bottomOverlayHeight: Screen.bottomSafeHeight + 58.w,
      playerPageType: ShortVideoPlayerPageType.primary,
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Text(
            text,
            style: TextStyle(
              color: AppColor.white.withOpacity(0.65),
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}
