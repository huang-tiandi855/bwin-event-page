import 'package:comics_app/common/style/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'search_page_logic.dart';
import 'search_discovery/view.dart';
import 'search_video_library/view.dart';

class SearchPagePage extends StatefulWidget {
  const SearchPagePage({Key? key}) : super(key: key);

  @override
  State<SearchPagePage> createState() => _SearchPagePageState();
}

class _SearchPagePageState extends State<SearchPagePage>
    with SingleTickerProviderStateMixin {
  late final SearchPageLogic logic;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    logic = Get.put(SearchPageLogic());
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColor.scaffoldBackground,
          body: Column(
            children: [
              _SearchTopBar(
                controller: _tabController,
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    SearchDiscoveryPage(),
                    SearchVideoLibraryPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchTopBar extends StatelessWidget {
  const _SearchTopBar({
    required this.controller,
  });

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 44.h,
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.back(),
              child: SizedBox(
                width: 36.w,
                height: 44.w,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 22.w,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: TabBar(
                  controller: controller,
                  isScrollable: false,
                  tabAlignment: TabAlignment.fill,
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  indicatorWeight: 0,
                  indicator: const BoxDecoration(),
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(.3),
                  labelStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: const [
                    Tab(text: '搜一搜'),
                    Tab(text: '视频库'),
                  ],
                ),
              ),
            ),
            SizedBox(width: 36.w),
          ],
        ),
      ),
    );
  }
}
