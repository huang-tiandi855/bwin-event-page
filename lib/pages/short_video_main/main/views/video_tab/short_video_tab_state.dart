import 'package:comics_app/common/entities/home/home_media_list_models.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';

class ShortVideoTabState {
  ShortVideoTabState();

  final PullRefreshController pullRefreshController = PullRefreshController();

  List<MediaVideoModel>? mediaList;

  int pageNumber = 1;
}
