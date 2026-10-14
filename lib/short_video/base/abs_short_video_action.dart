part of short_video_play_logic_impl;

abstract class AbsShortVideoAction<T extends ShortVideoModel>
    extends GetxController {
  AbsShortVideoPlayState<T> get state;

  void onTapComment(T videoInfo);

  void onTapFollow(T videoInfo);

  void onTapLike(T videoInfo);

  void onTapCollect(T videoInfo);

  void onTapShare(T videoInfo);

  void onTapTag(TagsModel tag);

  void onTapReward(T videoInfo);

  void navigateToPublisher(T videoInfo);

  void onTapVisible();

  void switchLine();
}
