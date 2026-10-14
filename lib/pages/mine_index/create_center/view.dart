import 'package:comics_app/common/widgets/community_style.dart';
import 'package:comics_app/common/widgets/post_card/post_card.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../common/res/r.dart';
import '../../../common/routers/app_routes.dart';
import '../../../common/style/color.dart';
import '../../../common/widgets/select_publish_type_bottom_sheet.dart';
import 'logic.dart';
import 'state.dart';

class CreateCenterPage extends StatelessWidget {
  final CreateCenterLogic logic = Get.put(CreateCenterLogic());
  final CreateCenterState state = Get.find<CreateCenterLogic>().state;

  CreateCenterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int initialIndex =
        state.index.clamp(0, CreateCenterState.tabCount - 1);

    return DefaultTabController(
      length: CreateCenterState.tabCount,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: AppColor.scaffoldBackground,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AssetsGen.images.mine.createCenterBg.image(),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  //appbar
                  const _HeaderBar(onPublish: _goPublish),
                  SizedBox(height: 18.w),
                  //收入卡片
                  const _IncomeCard(),
                  SizedBox(height: 16.w),
                  _CreateCenterTabBar(
                    tabs: CreateCenterState.tabLabels,
                    logic: logic,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: logic.tabController,
                      children: List<Widget>.generate(
                        CreateCenterState.tabCount,
                        (int tabIndex) => _PostList(
                          logic: logic,
                          tabIndex: tabIndex,
                          statusLabel: CreateCenterState.tabLabels[tabIndex],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20.w,
              bottom: MediaQuery.paddingOf(context).bottom + 24.w,
              child: GestureDetector(
                onTap: _goPublish,
                child: AssetsGen.images.mine.createCenterPublish.image(
                  width: 40.w,
                  height: 40.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _goPublish() {
    showSelectPublishTypeBottomSheet();
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.onPublish});

  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
                onPressed: Get.back,
                icon: SvgPicture.asset(
                  R.back,
                  width: 24.w,
                )),
          ),
          Text(
            '创作中心',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Positioned(
            right: 12.w,
            child: GestureDetector(
              onTap: onPublish,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryButtonColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    AssetsGen.images.mine.createCenterAdd.image(
                      width: 14.w,
                      height: 14.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '去发布',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeCard extends StatelessWidget {
  const _IncomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF303131),
            Color(0xFF0F2024),
          ],
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          GetBuilder<CreateCenterLogic>(
              id: 'balance',
              builder: (logic) {
                return Row(
                  children: [
                    Expanded(
                        child: _IncomeValue(
                            title: '收益余额',
                            value: logic.state.posting.toString())),
                    Expanded(
                        child: _IncomeValue(
                            title: '累计收益',
                            value: logic.state.postingSum.toString())),
                  ],
                );
              }),
          SizedBox(height: 16.w),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.WITH_DRAWAL),
            child: Container(
              width: 140.w,
              height: 34.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.primaryButtonColor,
                borderRadius: BorderRadius.circular(17.r),
              ),
              child: Text(
                '提现',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeValue extends StatelessWidget {
  const _IncomeValue({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.w),
        Text(
          value,
          style: TextStyle(
            color: AppColor.primaryButtonColor,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CreateCenterTabBar extends StatelessWidget {
  const _CreateCenterTabBar({required this.tabs, required this.logic});

  final List<String> tabs;
  final CreateCenterLogic logic;
  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: logic.tabController,
      padding: EdgeInsets.symmetric(horizontal: 78.w),
      indicatorColor: Colors.transparent,
      labelPadding: EdgeInsets.zero,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withOpacity(.5),
      labelStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      tabs: tabs.map((e) => Tab(text: e)).toList(),
    );
  }
}

class _PostList extends StatelessWidget {
  const _PostList({
    required this.logic,
    required this.tabIndex,
    required this.statusLabel,
  });

  final CreateCenterLogic logic;
  final int tabIndex;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateCenterLogic>(
      id: CreateCenterLogic.tabBuilderId(tabIndex),
      builder: (CreateCenterLogic logic) {
        final List<PostCardData> posts = logic.state.posts[tabIndex];
        return PullRefreshView(
          controller: logic.state.pullControllers[tabIndex],
          onRefresh: () => logic.loadFirstPage(tabIndex),
          onLoading: () => logic.loadMore(tabIndex),
          retryOnTap: () => logic.loadFirstPage(tabIndex),
          emptyText: '暂无${CreateCenterState.tabLabels[tabIndex]}的帖子',
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(
              16.w,
              4.w,
              16.w,
              MediaQuery.paddingOf(context).bottom + 24.w,
            ),
            itemCount: posts.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () =>
                    tabIndex == 0 ? jumpPostDetail('${posts[index].id}') : null,
                child: PostCard(
                  post: posts[index],
                  singleImageAspectRatio: 343 / 193,
                  isCreationCenter: true,
                  statusLabelOverride: statusLabel,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
