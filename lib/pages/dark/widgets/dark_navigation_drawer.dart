import 'package:comics_app/common/apis/home_apis.dart';
import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_widget.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/application/application_logic.dart';
import 'package:comics_app/pages/dark/logic.dart';
import 'package:comics_app/pages/home_index/topic_more_detail/topic_more_detail_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<void> showDarkNavigationDrawer(
  BuildContext context,
  DarkLogic logic,
) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _DarkNavigationDrawerRoute(
        animation: animation,
        logic: logic,
      );
    },
  );
}

class _DarkNavigationDrawerRoute extends StatefulWidget {
  const _DarkNavigationDrawerRoute({
    required this.animation,
    required this.logic,
  });

  final Animation<double> animation;
  final DarkLogic logic;

  @override
  State<_DarkNavigationDrawerRoute> createState() =>
      _DarkNavigationDrawerRouteState();
}

class _DarkNavigationDrawerRouteState
    extends State<_DarkNavigationDrawerRoute> {
  static const int _tagPreviewLimit = 6;

  bool _darkTagsShowAll = false;
  bool _hotTagsShowAll = false;

  /// 「热门」宫格的数据源 = 后端 `cms/group/hot` 返回的分类列表。
  /// 保留完整模型，点击时用 [ModuleModel.id] / [ModuleModel.groupName] /
  /// [ModuleModel.videoType] 跳 [AppRoutes.TOPIC_MORE_DETAIL] 专题详情页。
  List<ModuleModel> _hotGroups = const [];

  DarkLogic get logic => widget.logic;

  @override
  void initState() {
    super.initState();
    _loadHotTags();
  }

  Future<void> _loadHotTags() async {
    final List<ModuleModel> groups = await HomeApis.getHotGroup();
    if (!mounted) return;
    setState(() => _hotGroups = groups);
  }

  /// 宫格里展示的标签文案：优先 `groupName`，回退 `name`。
  List<String> get _hotTagLabels => [
        for (final g in _hotGroups) ((g.groupName ?? g.name) ?? '').trim(),
      ];

  void _popThen(VoidCallback action) {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  List<Widget> _navigationRows(ApplicationLogic appLogic) {
    final tabs = appLogic.state.tabs.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final out = <Widget>[];
    for (final tab in tabs) {
      if (out.isNotEmpty) {
        out.add(SizedBox(height: 10.h));
      }
      if (tab.index == 3) {
        out.add(_darkSection(tab.title));
        out.add(_buildDrawerBanner());
      } else {
        out.add(_navRow(
          icon: _drawerNavIcon(tab.index),
          label: tab.title,
          onTap: () => _popThen(() => appLogic.handleNavBarTap(tab.index)),
        ));
      }
    }
    return out;
  }

  Widget _drawerNavIcon(int index) {
    switch (index) {
      case 0:
        return AssetsGen.images.home.icDrawerHome.image(
          width: 20.w,
          height: 20.w,
          fit: BoxFit.contain,
        );
      case 1:
        return AssetsGen.images.home.icDrawerDouyin.image(
          width: 20.w,
          height: 20.w,
          fit: BoxFit.contain,
        );
      case 2:
        return AssetsGen.images.home.icDrawerAi.image(
          width: 20.w,
          height: 20.w,
          fit: BoxFit.contain,
        );
      case 3:
        return AssetsGen.images.home.icDrawerDark.image(
          width: 20.w,
          height: 20.w,
          fit: BoxFit.contain,
        );
      case 4:
        return AssetsGen.images.home.icDrawerCommity.image(
          width: 20.w,
          height: 20.w,
          fit: BoxFit.contain,
        );
      case 5:
        return AssetsGen.images.home.icDrawerMine.image(
          width: 20.w,
          height: 20.w,
          fit: BoxFit.contain,
        );
      default:
        return SizedBox(width: 20.w, height: 20.w);
    }
  }

  /// 侧边导航栏广告位
  Widget _buildDrawerBanner() {
    return AspectRatio(
      aspectRatio: 217 / 93,
      child: AdsBannerWidget(
        radius: 8.r,
        adsType: AdsType.sideBanner,
        padding: EdgeInsets.only(top: 10.h),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final drawerW = (media.size.width * 0.72).clamp(260.0, 320.0);
    final appLogic = Get.find<ApplicationLogic>();
    final slide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
    ));

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: getPhotoMaskView(
                width: media.size.width,
                height: media.size.height,
                alignment: Alignment.center,
                sigmaXY: 5,
                opacity: .5,
                color: const Color(0xFF181818).withOpacity(.7),
                child: const SizedBox.shrink(),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(),
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
                SlideTransition(
                  position: slide,
                  child: SizedBox(
                    width: drawerW,
                    child: ColoredBox(
                      color: AppColor.scaffoldBackground,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                '导航列表',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            10.h.verticalSpace,
                            ..._navigationRows(appLogic),
                            SizedBox(height: 10.h),
                            _hotSection(),
                            SizedBox(height: 10.h),
                            _otherSection(
                              onMember: () => _popThen(
                                  () => Get.toNamed(AppRoutes.MEMBER_CENTER)),
                              // 金币钱包 = 独立的 [WalletPage] 路由，与「我的」
                              // 页里的金币入口保持一致；不再错跳 MEMBER_CENTER 的 tab。
                              onWallet: () =>
                                  _popThen(() => Get.toNamed(AppRoutes.WALLET)),
                              // 福利中心 = 签到/福利页 [AppRoutes.SIGNIN_WELFARE]，
                              // 与「我的」页里的福利中心入口保持一致。
                              onWelfare: () => _popThen(() => Get.toNamed(
                                  AppRoutes.SIGNIN_WELFARE,
                                  arguments: {'index': 0})),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _darkSection(String title) {
    return GetBuilder<DarkLogic>(
      builder: (_) {
        final modules = logic.state.categoryModules;
        final selected = modules.isEmpty
            ? 0
            : logic.state.primaryTabIndex.clamp(0, modules.length - 1);
        final labels = <String>[];
        final moduleIndices = <int>[];
        for (var i = 0; i < modules.length; i++) {
          final title =
              (modules[i].moduleName ?? modules[i].groupName ?? '').trim();
          if (title.isNotEmpty) {
            labels.add(title);
            moduleIndices.add(i);
          }
        }
        var selectedLabelIndex = -1;
        for (var i = 0; i < moduleIndices.length; i++) {
          if (moduleIndices[i] == selected) {
            selectedLabelIndex = i;
            break;
          }
        }

        return _expandableCard(
          title: title,
          titleIcon: _drawerNavIcon(3),
          showFooterToggle: false,
          expanded: true,
          onToggle: () {},
          body: labels.isEmpty
              ? null
              : _tagGridSection(
                  labels: labels,
                  selectedIndex: selectedLabelIndex,
                  showAll: _darkTagsShowAll,
                  onToggleShowAll: () => setState(() {
                    _darkTagsShowAll = !_darkTagsShowAll;
                  }),
                  onSelected: (i) {
                    if (i < 0 || i >= moduleIndices.length) {
                      return;
                    }
                    Navigator.of(context).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      logic.setPrimaryTab(moduleIndices[i]);
                      logic.update();
                    });
                  },
                ),
        );
      },
    );
  }

  Widget _hotSection() {
    return _expandableCard(
      title: '热门',
      titleIcon: AssetsGen.images.home.icDrawerHot.image(
        width: 20.w,
        height: 20.w,
        fit: BoxFit.contain,
      ),
      showFooterToggle: false,
      expanded: true,
      onToggle: () {},
      body: _hotGroups.isEmpty
          ? null
          : _tagGridSection(
              labels: _hotTagLabels,
              selectedIndex: -1,
              showAll: _hotTagsShowAll,
              onToggleShowAll: () => setState(() {
                _hotTagsShowAll = !_hotTagsShowAll;
              }),
              onSelected: (i) {
                final g = _hotGroups[i];
                // 走 [TopicMoreDetailRoute.push] 让每次抽屉点击都拿到独立
                // logic 实例（栈上叠多份 TopicMoreDetail 时 state 不互相覆盖）。
                _popThen(() {
                  TopicMoreDetailRoute.push(
                    topicId: g.id,
                    topicName: g.groupName ?? g.name ?? '',
                    videoType: g.videoType,
                  );
                });
              },
            ),
    );
  }

  Widget _cardDecoration({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0XFF191919),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: child,
    );
  }

  Widget _expandableCard({
    String? title,
    required Widget titleIcon,
    required bool expanded,
    required VoidCallback onToggle,
    bool showFooterToggle = true,
    Widget? body,
  }) {
    final titleText = title?.trim();
    final showBody = body != null && (showFooterToggle ? expanded : true);
    return _cardDecoration(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
            child: Row(
              children: [
                titleIcon,
                if (titleText != null && titleText.isNotEmpty) ...[
                  4.w.horizontalSpace,
                  Text(
                    titleText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 10.h),
          if (showBody) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: body,
            ),
          ],
          if (showFooterToggle) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Center(
                  child: Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white54,
                    size: 22.sp,
                  ),
                ),
              ),
            ),
          ] else if (showBody) ...[
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }

  Widget _tagGridSection({
    required List<String> labels,
    required int selectedIndex,
    required bool showAll,
    required VoidCallback onToggleShowAll,
    required ValueChanged<int> onSelected,
  }) {
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }
    final needsExpandArrow = labels.length > _tagPreviewLimit;
    final visible = needsExpandArrow && !showAll
        ? labels.sublist(0, _tagPreviewLimit)
        : labels;
    final effectiveSelected =
        needsExpandArrow && !showAll && selectedIndex >= _tagPreviewLimit
            ? -1
            : selectedIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _tagGrid(
          labels: visible,
          selectedIndex: effectiveSelected,
          onSelected: onSelected,
        ),
        if (needsExpandArrow) ...[
          SizedBox(height: 6.h),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleShowAll,
            child: Center(
              child: Icon(
                showAll ? Icons.expand_less : Icons.expand_more,
                color: Colors.white54,
                size: 22.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tagGrid({
    required List<String> labels,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 6.w,
        childAspectRatio: 62 / 40,
      ),
      itemCount: labels.length,
      itemBuilder: (context, i) {
        final selected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelected(i),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected
                  ? AppColor.primaryButtonColor
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                labels[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navRow({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _cardDecoration(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              icon,
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otherSection({
    required VoidCallback onMember,
    required VoidCallback onWallet,
    required VoidCallback onWelfare,
  }) {
    return _cardDecoration(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AssetsGen.images.home.icDrawerOther.image(
                  width: 20.w,
                  height: 20.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 4.w),
                Text(
                  '其他',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _otherButton('会员中心', onMember),
            SizedBox(height: 8.h),
            _otherButton('金币钱包', onWallet),
            SizedBox(height: 8.h),
            _otherButton('福利中心', onWelfare),
          ],
        ),
      ),
    );
  }

  Widget _otherButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4.r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
