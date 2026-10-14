import 'package:comics_app/short_video/base/abs_short_video_play_logic.dart';
import 'package:comics_app/common/entities/video_model/ishort_video_model.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/short_video/player/short_video_player.dart';
import 'package:video_player/video_player.dart';

import '../../../common/entities/moreVideo.dart';
import '../../../common/entities/post_entity.dart';
import '../../../common/http/base_resp_bean.dart';
import '../../../common/values/address.dart';
import '../../../common/values/enum.dart';
import 'short_video_state.dart';

class ShortVideoLogic extends AbsShortVideoPlayLogic {
  ShortVideoLogic({
    required PostList videoInfo,
    bool isFromUserHome = false,
    bool isMore = true,
    MoreVideo? moreVideoArgs,
  }) : super(
          initialList: [ShortVideoModel.fromPostModel(videoInfo)],
        ) {
    _state.videoInfo = videoInfo;
    _state.videoList = [videoInfo];
    _state.isFromUserHome = isFromUserHome;
    _state.isMore = isMore;
    _state.moreVideo = MoreVideo(
      pageNumber: moreVideoArgs?.pageNumber ?? 0,
      pageSize: moreVideoArgs?.pageSize ?? 10,
      type: moreVideoArgs?.type,
      tagId: moreVideoArgs?.tagId ?? '',
    );
  }

  final _state = ShortVideoState<ShortVideoModel>();

  @override
  ShortVideoState<ShortVideoModel> get state => _state;

  @override
  Future<List<VideoController<ShortVideoModel>>> onMore() {
    switch (state.moreVideo.type) {
      case MoreVideoType.user:
        return getUserShortVideo();
      case MoreVideoType.tagHot:
        return getTagData(1);
      case MoreVideoType.tagNew:
        return getTagData(0);
      case MoreVideoType.halfCircle:
        return getCircleData();
      case MoreVideoType.focusCircles:
        return getCircleFocusData();
      default:
        return randomVideo();
    }
  }

  ///随机
  Future<List<VideoController<ShortVideoModel>>> randomVideo() async {
    state.pageNumber++;
    try {
      BaseRespBean baseRespBean = BaseRespBean(0);
      // BaseRespBean baseRespBean = await CircleApi.getRecommedVidList(data);
      if (baseRespBean.isSuccess) {
        PostEntity postEntity = PostEntity.fromJson(baseRespBean.data);
        List<PostList> list = postEntity.vInfos ?? [];
        return list
            .map((e) => VideoController<ShortVideoModel>(
                  builder: () => VideoPlayerController.network(
                      Address.buildH5VideoUrl(e.sourceURL,
                          token: UserStore.to.getToken(), withCdn: false)),
                  videoInfo: ShortVideoModel.fromPostModel(e),
                ))
            .toList();
      }
      return [];
    } finally {}
  }

  ///获取用户主页数据
  Future<List<VideoController<ShortVideoModel>>> getUserShortVideo() async {
    try {
      BaseRespBean baseRespBean = BaseRespBean(0);
      // BaseRespBean baseRespBean = await CircleApi.getMineCollcetion(data);
      if (baseRespBean.isSuccess) {
        PostEntity postEntity = PostEntity.fromJson(baseRespBean.data);
        List<PostList> list = postEntity.list ?? [];
        int index =
            list.indexWhere((element) => element.id == state.videoInfo?.id);
        if (index >= 0) {
          list = list.sublist(index + 1);
        }
        state.moreVideo.pageNumber = (state.moreVideo.pageNumber ?? 0) + 1;
        return list
            .map((e) => VideoController<ShortVideoModel>(
                  builder: () => VideoPlayerController.network(
                      Address.buildH5VideoUrl(e.sourceURL,
                          token: UserStore.to.getToken(), withCdn: false)),
                  videoInfo: ShortVideoModel.fromPostModel(e),
                ))
            .toList();
      }
      return [];
    } finally {}
  }

  ///获取标签更多数据
  Future<List<VideoController<ShortVideoModel>>> getTagData(int sort) async {
    try {
      BaseRespBean baseRespBean = BaseRespBean(0);
      // BaseRespBean baseRespBean = await CircleApi.getCommunityTagList(data);
      if (baseRespBean.isSuccess) {
        PostEntity postEntity = PostEntity.fromJson(baseRespBean.data);
        List<PostList> list = postEntity.list ?? [];
        list = list
            .where((element) =>
                element.newsType == "SP" || element.newsType == "MOVIE")
            .toList();
        int index =
            list.indexWhere((element) => element.id == state.videoInfo?.id);
        if (index >= 0) {
          list = list.sublist(index + 1);
        }
        state.moreVideo.pageNumber = (state.moreVideo.pageNumber ?? 0) + 1;
        return list
            .map((e) => VideoController<ShortVideoModel>(
                  builder: () => VideoPlayerController.network(
                      Address.buildH5VideoUrl(e.sourceURL,
                          token: UserStore.to.getToken(), withCdn: false)),
                  videoInfo: ShortVideoModel.fromPostModel(e),
                ))
            .toList();
      }
      return [];
    } finally {}
  }

  ///获取圈子发现数据
  Future<List<VideoController<ShortVideoModel>>> getCircleData() async {
    try {
      BaseRespBean baseRespBean = BaseRespBean(0);
      // BaseRespBean baseRespBean = await CircleApi.getCommunityList(data);
      if (baseRespBean.isSuccess) {
        PostEntity postEntity = PostEntity.fromJson(baseRespBean.data);
        List<PostList> list = postEntity.list ?? [];
        list = list
            .where((element) =>
                element.newsType == "SP" || element.newsType == "MOVIE")
            .toList();
        int index =
            list.indexWhere((element) => element.id == state.videoInfo?.id);
        if (index >= 0) {
          list = list.sublist(index + 1);
        }
        state.moreVideo.pageNumber = (state.moreVideo.pageNumber ?? 0) + 1;
        return list
            .map((e) => VideoController<ShortVideoModel>(
                  builder: () => VideoPlayerController.network(
                      Address.buildH5VideoUrl(e.sourceURL,
                          token: UserStore.to.getToken(), withCdn: false)),
                  videoInfo: ShortVideoModel.fromPostModel(e),
                ))
            .toList();
      }
      return [];
    } finally {}
  }

  ///获取关注数据
  Future<List<VideoController<ShortVideoModel>>> getCircleFocusData() async {
    try {
      BaseRespBean baseRespBean = BaseRespBean(0);
      // BaseRespBean baseRespBean = await CircleApi.carePostList(data);
      if (baseRespBean.isSuccess) {
        PostEntity postEntity = PostEntity.fromJson(baseRespBean.data);
        List<PostList> list = postEntity.list ?? [];
        list = list
            .where((element) =>
                element.newsType == "SP" || element.newsType == "MOVIE")
            .toList();
        int index =
            list.indexWhere((element) => element.id == state.videoInfo?.id);
        if (index >= 0) {
          list = list.sublist(index + 1);
        }
        state.moreVideo.pageNumber = (state.moreVideo.pageNumber ?? 0) + 1;
        return list
            .map((e) => VideoController<ShortVideoModel>(
                  builder: () => VideoPlayerController.network(
                      Address.buildH5VideoUrl(e.sourceURL,
                          token: UserStore.to.getToken(), withCdn: false)),
                  videoInfo: ShortVideoModel.fromPostModel(e),
                ))
            .toList();
      }
      return [];
    } finally {}
  }
}
