import 'package:comics_app/common/entities/modules_config/module_model.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/assets.gen.dart';

/// 推荐位横滑条下方常见的三列大卡片区。
///
/// 数据直接吃后端 [ModuleModel]：标题取 `groupName ?? name`；
/// 后端模型暂时没有副标题字段，先用占位文案保持原有双行 UI。
///
/// 支持单选高亮：传入 [selectedId] 命中某张卡片的 `id` 时画一圈强调边框；
/// 配合 [onTap] 即可作为「二级筛选条」使用，详见 community 信息流。
class CircleFeaturedStrip extends StatelessWidget {
  const CircleFeaturedStrip({
    super.key,
    required this.cards,
    this.aspectRatio = 108 / 60,
    this.selectedId,
    this.onTap,
  });

  final List<ModuleModel> cards;
  final double aspectRatio;

  /// 当前选中的卡片 id；为 `null` 时全部以未选中样式渲染。
  final int? selectedId;

  /// 卡片点击回调；为 `null` 时卡片不可点击。
  final ValueChanged<ModuleModel>? onTap;

  @override
  Widget build(BuildContext context) {
    final bgList = [
      AssetsGen.images.circle.circleTopicBg1,
      AssetsGen.images.circle.circleTopicBg2,
      AssetsGen.images.circle.circleTopicBg3,
      AssetsGen.images.circle.circleTopicBg4,
      AssetsGen.images.circle.circleTopicBg5,
      AssetsGen.images.circle.circleTopicBg6,
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: GridView.builder(
          shrinkWrap: true,
          primary: false,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.w,
            crossAxisSpacing: 10.w,
            childAspectRatio: aspectRatio,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final item = cards[index];
            final title = (item.groupName ?? item.name ?? '').trim();
            final bg = bgList[index % bgList.length];
            final card = Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  width: 1.w,
                  color: selectedId == item.id
                      ? AppColor.primaryButtonColor
                      : Colors.transparent,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(child: bg.image()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${item.pnums ?? 0}个帖子',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
            if (onTap == null) return card;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap!(item),
              child: card,
            );
          },
        ),
      ),
    );
  }
}
