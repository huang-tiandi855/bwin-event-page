import 'dart:async';

import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_gen_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AiTaskProgressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AiTaskProgressLogic());
  }
}

class AiTaskProgressLogic extends GetxController {
  static const Color cardBg = Color(0xFF18181B);
  static const Color cardBorder = Color(0x33FFFFFF);
  static const Color tipBg = Color(0xFF221D11);
  static const Color progressTrack = Color(0xFF3F3F47);
  static const Color tagBg = Color(0xFF28282C);

  AiTaskVo? task;
  Timer? _timer;
  int progress = 10;

  bool get progressReady => progress >= 99;

  String get statusText => progressReady ? '已提交后台处理' : '生成中';

  String get relativeTime => '刚刚';

  String get taskLabel => task?.ruleName ?? task?.typeName ?? 'AI生成';

  String get tipTextContent => '作品仅保留3个月，请及时下载';

  String get costLabel {
    final times = task?.userCostTimes ?? 0;
    if (times > 0) return '消耗 $times 次';

    final gold = task?.userCostGold ?? 0;
    if (gold > 0) return '消耗 $gold 金币';

    final display = (task?.userCostDisplay ?? '').replaceAll('积分', '金币').trim();
    if (display.isNotEmpty) {
      return display.startsWith('消耗') ? display : '消耗 $display';
    }
    return '消耗 -- 金币';
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['task'] is AiTaskVo) {
      task = args['task'] as AiTaskVo;
    }
    _startFakeProgress();
  }

  void _startFakeProgress() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (progress >= 99) {
        _timer?.cancel();
        return;
      }
      final step = progress < 70 ? 3 : (progress < 90 ? 2 : 1);
      progress = (progress + step).clamp(0, 99).toInt();
      update();
    });
  }

  void goMyWorks() {
    if (!progressReady) return;
    Get.offNamed(AppRoutes.AI_RECORD);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

class AiTaskProgressPage extends GetView<AiTaskProgressLogic> {
  const AiTaskProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AiGenStyle.background,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 44.w,
          backgroundColor: AiGenStyle.background,
          surfaceTintColor: AiGenStyle.background,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leadingWidth: 54.w,
          leading: GestureDetector(
            onTap: () => Get.back(),
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: SvgPicture.asset(
                AssetsGen.images.ai.aiBack,
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
          title: Text(
            '生成进度',
            style: TextStyle(
              height: 1,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        body: GetBuilder<AiTaskProgressLogic>(
          builder: (logic) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(15.w, 15.w, 15.w, 24.w),
                    children: [
                      _TipBanner(text: logic.tipTextContent),
                      SizedBox(height: 15.w),
                      _ProgressCard(logic: logic),
                    ],
                  ),
                ),
                Container(height: 1, color: AiGenStyle.divider),
                _ProgressAction(
                  ready: logic.progressReady,
                  onTap: logic.goMyWorks,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TipBanner extends StatelessWidget {
  const _TipBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 42.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AiTaskProgressLogic.tipBg,
        borderRadius: BorderRadius.circular(49.5.r),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AssetsGen.images.ai.aiProgressTip,
            width: 16.w,
            height: 16.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AiGenStyle.accent,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.logic});

  final AiTaskProgressLogic logic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10.w, 12.w, 10.w, 14.w),
      decoration: BoxDecoration(
        color: AiTaskProgressLogic.cardBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AiTaskProgressLogic.cardBorder, width: .5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7.5.w,
                height: 7.5.w,
                decoration: const BoxDecoration(
                  color: AiGenStyle.accent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  logic.statusText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${logic.progress}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AiGenStyle.accent,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(49.5.r),
            child: SizedBox(
              height: 7.w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: AiTaskProgressLogic.progressTrack),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (logic.progress / 100).clamp(0.0, 1.0),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AiGenStyle.accent, Colors.white],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.w),
          Row(
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 110.w),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
                decoration: BoxDecoration(
                  color: AiTaskProgressLogic.tagBg,
                  borderRadius: BorderRadius.circular(49.5.r),
                  border: Border.all(
                    color: AiTaskProgressLogic.cardBorder,
                    width: .5,
                  ),
                ),
                child: Text(
                  logic.taskLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _CostText(label: logic.costLabel),
              ),
              Text(
                logic.relativeTime,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AiGenStyle.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostText extends StatelessWidget {
  const _CostText({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    if (match == null) {
      return Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.sp, color: AiGenStyle.muted),
      );
    }
    final number = match.group(1)!;
    final start = match.start;
    final end = match.end;
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 12.sp, color: AiGenStyle.muted),
        children: [
          TextSpan(text: label.substring(0, start)),
          TextSpan(
            text: number,
            style: const TextStyle(
              color: AiGenStyle.gold,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(text: label.substring(end)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _ProgressAction extends StatelessWidget {
  const _ProgressAction({
    required this.ready,
    required this.onTap,
  });

  final bool ready;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(15.w, 14.w, 15.w, 10.w),
        child: GestureDetector(
          onTap: ready ? onTap : null,
          child: Container(
            width: double.infinity,
            height: 50.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(49.5.r),
              gradient: ready
                  ? const LinearGradient(
                      colors: [Color(0xFFB815FF), Color(0xFF611EFF)],
                    )
                  : null,
              color: ready ? null : AiGenStyle.surface,
            ),
            child: Text(
              ready ? '去我的作品' : '生成中',
              style: TextStyle(
                height: 1,
                fontSize: 19.sp,
                fontWeight: FontWeight.w400,
                color: ready ? Colors.white : AiGenStyle.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
