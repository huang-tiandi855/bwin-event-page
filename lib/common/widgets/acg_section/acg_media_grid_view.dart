import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:comics_app/common/utils/logger.dart';

class MediaGridView extends StatelessWidget {
  const MediaGridView._(
      {required this.crossAxisCount,
      required this.itemBuilder,
      required this.itemCount,
      this.scrollDirection = Axis.vertical,
      this.crossAxisSpacing,
      this.mainAxisSpacing,
      this.aspectRatio,
      this.allowScroll = false,
      this.firstAspectRatio,
      this.padding,
      this.isSliver = false,
      this.isStaggered = false,
      this.pattern})
      : assert(
          !(isSliver && (firstAspectRatio != null || allowScroll)),
          'When isSliver is true, firstAspectRatio must be null and allowScroll must be false',
        );

  factory MediaGridView({
    required int crossAxisCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    Axis scrollDirection = Axis.vertical,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    double? aspectRatio,
    bool allowScroll = false,
    double? firstAspectRatio,
    EdgeInsets? padding,
  }) {
    return MediaGridView._(
      crossAxisCount: crossAxisCount,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      scrollDirection: scrollDirection,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      aspectRatio: aspectRatio,
      allowScroll: allowScroll,
      firstAspectRatio: firstAspectRatio,
      padding: padding,
      isSliver: false,
      isStaggered: false,
    );
  }
  factory MediaGridView.staggeredGridView(
      {required int crossAxisCount,
      required Widget Function(BuildContext, int) itemBuilder,
      required int itemCount,
      double? crossAxisSpacing,
      double? mainAxisSpacing,
      double? aspectRatio,
      EdgeInsets? padding,
      List<WovenGridTile>? pattern,
      bool isSliver = false}) {
    return MediaGridView._(
      crossAxisCount: crossAxisCount,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      aspectRatio: aspectRatio,
      padding: padding,
      isStaggered: true,
      pattern: pattern,
      isSliver: isSliver,
    );
  }

  factory MediaGridView.sliver({
    required int crossAxisCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    double? aspectRatio,
    EdgeInsets? padding,
  }) {
    return MediaGridView._(
      crossAxisCount: crossAxisCount,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      aspectRatio: aspectRatio,
      padding: padding,
      isSliver: true,
      isStaggered: false,
    );
  }

  final Axis scrollDirection;
  final int crossAxisCount;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? aspectRatio;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final List<WovenGridTile>? pattern;
  final bool allowScroll;

  final double? firstAspectRatio;

  final EdgeInsets? padding;

  final bool isSliver;
  final bool isStaggered;

  double get _aspectRatio {
    if (aspectRatio != null && aspectRatio == 0) {
      return 173 / 148;
    }
    return aspectRatio ?? 173 / 148;
  }

  double get _crossAxisSpacing {
    return crossAxisSpacing ?? 0;
  }

  double get _mainAxisSpacing {
    return mainAxisSpacing ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (isSliver) {
      return _buildSliverGridView(context);
    }
    return _buildGridView(context);
  }

  SliverGridDelegate get gridDelegate {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: _crossAxisSpacing,
      mainAxisSpacing: _mainAxisSpacing,
      childAspectRatio: _aspectRatio,
    );
  }

  SliverWovenGridDelegate get gridStaggerDelegate {
    return SliverWovenGridDelegate.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: _crossAxisSpacing,
      mainAxisSpacing: _mainAxisSpacing,
      pattern: pattern ??
          [
            const WovenGridTile(1),
            const WovenGridTile(1),
          ],
    );
  }

  Widget _buildSliverGridView(BuildContext context) {
    l.d("_buildSliverGridView");
    return SliverPadding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: 10.w,
          ),
      sliver: isStaggered
          ? SliverToBoxAdapter(
              child: _buildStaggeredView(),
            )
          : SliverGrid.builder(
              gridDelegate: gridDelegate,
              itemBuilder: itemBuilder,
              itemCount: itemCount,
            ),
    );
  }

  Widget _buildStaggeredView() {
    return SizedBox(
      width: 1.sw,
      height: 512,
      child: MasonryGridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: _mainAxisSpacing,
        crossAxisSpacing: _crossAxisSpacing,
        itemBuilder: itemBuilder,
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    final firstBig = firstAspectRatio != null;
    Widget child = GridView.builder(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: 10.w,
          ),
      shrinkWrap:
          !allowScroll || allowScroll && scrollDirection == Axis.horizontal,
      scrollDirection: scrollDirection,
      physics: allowScroll ? null : const NeverScrollableScrollPhysics(),
      gridDelegate: isStaggered ? gridStaggerDelegate : gridDelegate,
      itemBuilder: (context, index) {
        return itemBuilder(context, firstBig ? index + 1 : index);
      },
      itemCount: firstBig ? max(itemCount - 1, 0) : itemCount,
    );

    if (firstBig) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (firstBig && itemCount > 0 && !allowScroll)
            Container(
              margin: itemCount > 1 ? EdgeInsets.only(bottom: 10.w) : null,
              padding: padding ??
                  EdgeInsets.symmetric(
                    horizontal: 10.w,
                  ),
              child: AspectRatio(
                aspectRatio: firstAspectRatio ?? 355 / 251,
                child: itemBuilder(context, 0),
              ),
            ),
          Flexible(
            child: child,
          ),
        ],
      );
    }
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: child,
    );
  }
}
