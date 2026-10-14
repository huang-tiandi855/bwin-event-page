import 'package:comics_app/common/entities/announce_ment.dart';
import 'package:comics_app/common/entities/config.dart';
import 'package:flutter/material.dart';

import '../../common/entities/modules_config/module_model.dart';
import '../../common/services/module_config_service.dart';

class HomeState {
  late List<String> tabs = [];

  late List<String> comicTabs = [];
  late List<String> xsTabs = [];

  // late List<Widget> tabsWidget = [];
  //
  // late List<Widget> comicTabsWidget = [];

  late List<Widget> comicTabsViewWidget = [];

  late List<Widget> cartoonTabsViewWidget = [];
  late List<Widget> xsTabsViewWidget = [];
  List<ModuleModel> comicLists = [];

  List<ModuleModel> cartoonLists = [];

  List<ModuleModel> xsLists = [];

  late TabController tabControllerTop;

  late TabController tabController;
  late TabController xsTabController;

  late TabController comicTabController;

  List<AdsInfoList>? banner = [];

  List<AdsInfoList>? bannerImage = [];

  List<AdsInfoList> floatingAds = [];
  bool shoFloatAds = true;

  final GlobalKey parentKey = GlobalKey();

  // ScrollController? scrollController = ScrollController();

  AnnounceMent? announcement;

  int adCurrentIndex = 0;

  /// Holds the state of the screen.
  bool? hasChanges = true;

  late List<AdsInfoList> homePageSpecialAds = [];

  var navBgOpacity = 0.0;

  List<AdsInfoList>? nineAdsTopBanner = [];

  HomeState() {
    comicTabs = [];

    ///Initialize variables
    tabs = [];
    xsTabs = [];
    comicLists = ModuleConfigService().homeModules.homeModules;
    cartoonLists = ModuleConfigService().homeModules.homeModules;
    xsLists = ModuleConfigService().homeModules.homeModules;
  }
}
