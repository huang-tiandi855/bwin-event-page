import 'package:comics_app/common/entities/circle/game_data_model.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';

class GameDetailsState {
  final ScrollController scrollController = ScrollController();

  int gameId = 0;
  GameDataModel? game;

  /// 相关推荐。
  List<GameDataModel> relatedGames = <GameDataModel>[];

  /// 相关推荐分页。
  final PullRefreshController relatedPullController =
      PullRefreshController(isRequest: false);
  int relatedPage = 1;
  bool relatedHasMore = true;
  int? relatedCategoryId;
  static const int relatedPageSize = 10;

  bool isLike = false;
  bool isCollect = false;

  /// 简介是否展开。
  bool introExpanded = false;

  /// 下载区是否已揭示（解锁成功或接口已带回下载信息）。
  bool downloadRevealed = false;

  bool loading = true;
  bool loadFailed = false;

  String gameName = '';
  String intro = '';
  String version = '';
  String fileSize = '';
  String categoryLabel = '';
  String languageLabel = '';
  List<String> platforms = const <String>[];
  List<String> detailTags = const <String>[];
  String downloadUrl = '';
  List<GamingDownloadItem> downloadLinks = const <GamingDownloadItem>[];
  String extractPassword = '';
  List<String> coverUrls = const <String>[];
}
