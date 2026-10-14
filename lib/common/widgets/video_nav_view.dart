import 'package:comics_app/common/entities/config.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoNavView extends StatelessWidget {
  const VideoNavView({
    super.key,
    this.children = const [],
    this.isSliver = false,
  });

  int get itemCount => children.length;

  final List<VideoNavItemView> children;

  final bool isSliver;

  @override
  Widget build(BuildContext context) {
    Widget child = LayoutBuilder(builder: (context, constraints) {
      final spacing = (constraints.maxWidth - 5 * 60.w) ~/ (5 - 1);
      return Wrap(
        spacing: spacing.toDouble(),
        children: List.generate(itemCount, (index) {
          return children[index];
        }),
      );
    });
    if (isSliver) {
      return SliverToBoxAdapter(
        child: child,
      );
    }
    return child;
  }
}

class VideoNavItemView extends StatelessWidget {
  const VideoNavItemView({
    super.key,
    required this.data,
  });

  final ListElementTemp data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (data.linkUrl?.isNotEmpty ?? false) {
          AppNavigator.to.jumpUrl(
            url: data.linkUrl!,
            moduleType: 2,
            linkType: data.linkType ?? 1,
            id: data.id,
            title: data.name,
          );
        }
      },
      child: SizedBox(
        width: 50.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomImage(
              url: data.img,
              width: 50.w,
              height: 50.w,
            ),
            16.verticalSpaceFromWidth,
            Text(
              data.name ?? '',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF777777),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
