import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/tab_widgets/tab_gradient_indicator_widget.dart';
import 'package:comics_app/pages/common/signin_welfare/agent_promotion/view.dart';
import 'package:comics_app/pages/common/signin_welfare/recommend_application/view.dart';
import 'package:comics_app/pages/common/signin_welfare/signin/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

class SigninWelfarePage extends StatelessWidget {
  const SigninWelfarePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<SigninWelfareLogic>();
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      body: GetBuilder<SigninWelfareLogic>(
        builder: (_) {
          return SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: [
                SizedBox(
                  height: ScreenUtil().screenHeight,
                  width: ScreenUtil().screenWidth,
                  child: TabBarView(
                    controller: logic.tabController,
                    children: const [
                      AgentPromotionPage(),
                      SigninPage(),
                      RecommendApplicationPage(),
                    ],
                  ),
                ),
                _buildHeader(logic),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(SigninWelfareLogic logic) {
    return Positioned(
      top: ScreenUtil().statusBarHeight,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 44.h,
        width: ScreenUtil().screenWidth,
        child: Stack(alignment: Alignment.center, children: [
          TabGradientIndicatorTabBar(
            controller: logic.tabController,
            tabs: [
              for (final t in SigninWelfareState.primaryTabs) Tab(text: t),
            ],
          ),
          Align(alignment: Alignment.centerLeft, child: commonBack()),
        ]),
      ),
    );
  }
}
