import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/widgets/common_ui/common_ui.dart';
import '../../common/widgets/loading_widget.dart';
import '../common/mine/common/error_widget.dart';
import 'happy/Adv.dart';
import 'happy/HappyModel.dart';
import 'happy/community_image_indicator.dart';
import 'happy/happy_custom_view.dart';

class LouFengAdPage extends StatefulWidget {
  final bool? showAppbar;

  const LouFengAdPage({Key? key, this.showAppbar}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _LouFengAdPageState();
  }
}

class _LouFengAdPageState extends State<LouFengAdPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static HappyModel? dataModel;

  TabController? tabController;
  List<AdsInfoList> advApply = [];
  List<AdsInfoList> advGame = [];

  List<AdsInfoList> advYp = [];
  List<AdsInfoList> advQp = [];
  List<AdsInfoList> advZb = [];

  List<String> tabs = [];

  List<Widget> tabsView = [];

  bool get isEmptyData {
    return (dataModel?.adv?.isNotEmpty != true) &&
        (dataModel?.shuApp?.isNotEmpty != true) &&
        (dataModel?.qpApp?.isNotEmpty != true) &&
        (dataModel?.gameApp?.isNotEmpty != true) &&
        (dataModel?.ypApp?.isNotEmpty != true) &&
        (dataModel?.zbApp?.isNotEmpty != true);
  }

  bool isLoadingData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _getAdvList();
      _loadData();
    });
  }

  Future _getAdvList() async {
    advApply = getAdsByType(AdsType.banner);
    advGame = getAdsByType(AdsType.banner);

    advYp = getAdsByType(AdsType.banner);
    advQp = getAdsByType(AdsType.banner);
    advZb = getAdsByType(AdsType.banner);
  }

  void _loadData() async {
    try {
      if (isEmptyData) {
        dataModel = await UserApi.happyList();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    dataModel ??= HappyModel();

    List<Adv>? advsApply = [];

    List<Adv>? advsGame = [];

    List<Adv>? advsYp = [];

    List<Adv>? advsQP = [];

    List<Adv>? advsZb = [];

    dataModel?.adv?.forEach((element) {
      if (element.moduleType == 1) {
        advsApply.add(element);
      } else if (element.moduleType == 2) {
        advsGame.add(element);
      } else if (element.moduleType == 3) {
        advsYp.add(element);
      } else if (element.moduleType == 4) {
        advsQP.add(element);
      } else if (element.moduleType == 5) {
        advsZb.add(element);
      }
    });

    // tabs.add("应用");
    // tabsView.add(
    //   HappApplyView(advsApply, dataModel: dataModel),
    // );

    if (dataModel?.gameApp?.isNotEmpty == true || advsGame.isNotEmpty == true) {
      tabs.add("游戏");
      tabsView.add(HappyCustomView(advsGame, gameApp: dataModel?.gameApp));
    }

    if (dataModel?.ypApp?.isNotEmpty == true || advsYp.isNotEmpty == true) {
      tabs.add("约炮");
      tabsView.add(
        HappyCustomView(advsYp, gameApp: dataModel?.ypApp),
      );
    }

    if (dataModel?.qpApp?.isNotEmpty == true || advsQP.isNotEmpty == true) {
      tabs.add("棋牌");
      tabsView.add(
        HappyCustomView(advsQP, gameApp: dataModel?.qpApp),
      );
    }

    if (dataModel?.zbApp?.isNotEmpty == true || advsZb.isNotEmpty == true) {
      tabs.add("直播");
      tabsView.add(
        HappyCustomView(advsZb, gameApp: dataModel?.zbApp),
      );
    }
    tabController = TabController(length: tabs.length, vsync: this);
    isLoadingData = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
      appBar: widget.showAppbar == true
          ? commonAppBar(
              "娱乐",
              titleColor: Colors.white,
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (dataModel == null || isLoadingData) {
      return const LoadingWidget();
    } else if (isEmptyData) {
      return CErrorWidget(
        "暂无数据",
        retryOnTap: () {
          dataModel = null;
          setState(() {});
          _loadData();
        },
      );
    } else {
      return Column(
        children: [
          Container(
              width: ScreenUtil().screenWidth,
              padding:
                  EdgeInsets.fromLTRB(0, ScreenUtil().statusBarHeight, 0, 0),
              child: CommunityImageIndicator(
                controller: tabController,
                titleArr: tabs,
              )),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: tabsView,
            ),
          ),
        ],
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
