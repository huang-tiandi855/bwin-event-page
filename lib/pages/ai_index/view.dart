import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../common/routers/app_routes.dart';
import '../../common/utils/ads_manage/ads_banner_widget.dart';
import '../../common/utils/ads_manage/getAdv.dart';
import '../../common/utils/screen.dart';
import '../../common/utils/toast_util.dart';
import '../../gen/assets.gen.dart';
import 'logic.dart';
import 'state.dart';

class AiIndexPage extends StatelessWidget {
  AiIndexPage({super.key});

  final AiIndexLogic logic = Get.put(AiIndexLogic());

  final String _background = AssetsGen.images.ai.aiHomeBg.path;
  final String _logo = AssetsGen.images.ai.aiHomeLogo;
  final String _historyIcon = AssetsGen.images.ai.aiHomeHistory;
  final String _disclaimerIcon = AssetsGen.images.ai.aiDisclaimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 284.w,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.black, Colors.transparent],
                stops: [0, .68, 1],
              ).createShader(bounds),
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  _background,
                  width: 1.sw,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: logic.loadHome,
              color: const Color(0xFFAD46FF),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 8.w),
                child: Column(
                  children: [
                    _buildTop(),
                    SizedBox(height: 23.w),
                    _buildBanner(),
                    _buildModelList(),
                    SizedBox(height: 20.w),
                    _buildDisclaimer(),
                    SizedBox(height: Screen.bottomSafeHeight + 78.w),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTop() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: SizedBox(
        height: 28.w,
        child: Row(
          children: [
            SvgPicture.asset(_logo, width: 28.w, height: 28.w),
            SizedBox(width: 5.w),
            Text(
              'AI创造',
              style: TextStyle(
                height: 1,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.AI_RECORD),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 28.w,
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(49.5.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB516FF), Color(0xFF631EFF)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      _historyIcon,
                      width: 17.w,
                      height: 16.w,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      '我的生成',
                      style: TextStyle(
                        height: 1,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return AdsBannerWidget(
      padding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 15.w),
      adsType: AdsType.aiBanner,
      radius: 16.w,
      height: 128.w,
      showDicator: false,
    );
  }

  Widget _buildModelList() {
    return GetBuilder<AiIndexLogic>(
      id: 'modelList',
      builder: (logic) {
        if (logic.state.loading && logic.state.displayRules.isEmpty) {
          return SizedBox(
            height: 208.w,
            child: const Center(
              child: LoadingWidget(),
            ),
          );
        }

        final rules = logic.state.displayRules;
        if (rules.isEmpty) {
          return SizedBox(
            height: 208.w,
            child: Center(
              child: Text(
                '暂无可用功能',
                style: TextStyle(fontSize: 14.sp, color: Colors.white54),
              ),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          itemCount: rules.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 167 / 208,
            mainAxisSpacing: 11.w,
            crossAxisSpacing: 11.w,
          ),
          itemBuilder: (context, index) => AiIndexModelItem(item: rules[index]),
        );
      },
    );
  }

  Widget _buildDisclaimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(_disclaimerIcon, width: 12.w, height: 12.w),
        SizedBox(width: 3.w),
        Text(
          'AI生成内容仅供娱乐，请合理使用',
          style: TextStyle(
            height: 1,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF8D8D8D),
          ),
        ),
      ],
    );
  }
}

class AiIndexModelItem extends StatelessWidget {
  const AiIndexModelItem({super.key, required this.item});

  final AiBillingRuleVo item;

  void _onTap() {
    final route = AiIndexState.routeOf(item.ruleCode);
    if (route == null || route.isEmpty) {
      showToast(msg: '功能开发中');
      return;
    }
    Get.toNamed(route, arguments: {'rule': item});
  }

  @override
  Widget build(BuildContext context) {
    final cover = AiIndexState.coverOf(item.ruleCode);
    final icon = AiIndexState.iconOf(item.ruleCode);
    final backendTitle = item.name?.trim() ?? '';
    final backendDescription = item.clientIntro?.trim() ?? '';
    final title = backendTitle.isNotEmpty
        ? backendTitle
        : AiIndexState.fallbackTitleOf(item.ruleCode);
    final description = backendDescription.isNotEmpty
        ? backendDescription
        : AiIndexState.fallbackDescriptionOf(item.ruleCode);
    final badge = _AiCardBadge.of(item.ruleCode);

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(cover, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x33000000),
                    Color(0xE6000000),
                  ],
                  stops: [0, .5, 1],
                ),
              ),
            ),
            if (badge != null)
              Positioned(
                top: 10.w,
                left: 10.w,
                child: Container(
                  width: 34.w,
                  height: 20.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badge.color,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Text(
                    badge.text,
                    style: TextStyle(
                      height: 1,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF09090B),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 10.w,
              right: 10.w,
              child: Container(
                width: 28.w,
                height: 28.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0x66000000),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x1AFFFFFF)),
                ),
                child: SvgPicture.asset(icon, width: 14.w, height: 14.w),
              ),
            ),
            Positioned(
              left: 10.w,
              right: 10.w,
              bottom: 8.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5.w),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      height: 1,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8D8D8D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiCardBadge {
  const _AiCardBadge(this.text, this.color);

  final String text;
  final Color color;

  static _AiCardBadge? of(String? ruleCode) {
    switch (ruleCode) {
      case 'ai_undress':
      case 'ai_image_expand':
      case 'ai_image_to_video':
        return const _AiCardBadge('HOT', Color(0xFF3AF26E));
      case 'ai_text_to_image':
      case 'ai_text_to_video':
        return const _AiCardBadge('NEW', Color(0xFF00F6F8));
      case 'ai_custom':
        return const _AiCardBadge('PRO', Color(0xFFFFDD9A));
      default:
        return null;
    }
  }
}
