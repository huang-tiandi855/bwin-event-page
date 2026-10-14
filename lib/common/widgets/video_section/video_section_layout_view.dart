import 'package:cached_network_image/cached_network_image.dart';
import 'package:comics_app/pages/image/network/image_cache_manager.dart';
import 'package:comics_app/pages/image/network/network_image_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoSectionLayoutView extends StatelessWidget {
  const VideoSectionLayoutView({
    super.key,
    required this.child,
    this.title,
    this.bottom,
    this.isSliver = false,
    this.padding,
    this.showType,
    this.sectionCover,
  });

  final Widget? title;

  final Widget child;

  final Widget? bottom;

  final bool isSliver;

  final EdgeInsets? padding;

  final int? showType;

  final String? sectionCover;

  bool get renderTitle {
    return title != null;
  }

  bool get renderBottom {
    return bottom != null;
  }

  EdgeInsets get _padding =>
      padding ??
      (showType == 12 || showType == 13
          ? EdgeInsets.only(
              top: 10.w,
              bottom: 12.w,
            )
          : EdgeInsets.only(
              top: renderTitle ? 16.w : 0,
              bottom: renderBottom ? 16.w : 0,
            ));

  @override
  Widget build(BuildContext context) {
    Widget widget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (renderTitle) title!,
        Padding(
          padding: _padding,
          child: child,
        ),
        if (renderBottom) bottom!,
      ],
    );
    if (showType == 12 || showType == 13) {
      widget = Container(
        padding: EdgeInsets.only(
          top: 8.w,
        ),
        decoration: BoxDecoration(
          image: sectionCover?.isNotEmpty == true && showType == 12
              ? DecorationImage(
                  image: CachedNetworkImageProvider(
                    resolveCdnImageUrl(sectionCover),
                    cacheManager: ImgCacheMgr(),
                  ),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.center,
                )
              : null,
          color: showType == 13 ? const Color(0xFFB09FD9).withOpacity(0.2) : null,
        ),
        child: widget,
      );
    }

    if (isSliver) {
      return SliverToBoxAdapter(
        child: widget,
      );
    }
    return widget;
  }
}
