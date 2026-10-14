import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoGridView extends StatelessWidget {
  const VideoGridView._({
    required this.crossAxisCount,
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
  }) : assert(
          !(isSliver && (firstAspectRatio != null || allowScroll)),
          'When isSliver is true, firstAspectRatio must be null and allowScroll must be false',
        );

  factory VideoGridView({
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
    return VideoGridView._(
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
    );
  }

  /// NestedScrollView->RefreshView->GridView嵌套会出现GridView无法关联外层滚动
  /// 目前没空看原因，改为采用sliver构建方式
  factory VideoGridView.sliver({
    required int crossAxisCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    double? aspectRatio,
    EdgeInsets? padding,
  }) {
    return VideoGridView._(
      crossAxisCount: crossAxisCount,
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      aspectRatio: aspectRatio,
      padding: padding,
      isSliver: true,
    );
  }

  final Axis scrollDirection;
  final int crossAxisCount;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? aspectRatio;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;

  final bool allowScroll;

  final double? firstAspectRatio;

  final EdgeInsets? padding;

  final bool isSliver;

  double get _aspectRatio {
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

  Widget _buildSliverGridView(BuildContext context) {
    return SliverPadding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: 10.w,
          ),
      sliver: SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemBuilder: itemBuilder,
        itemCount: itemCount,
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
      shrinkWrap: !allowScroll || allowScroll && scrollDirection == Axis.horizontal,
      scrollDirection: scrollDirection,
      physics: allowScroll ? null : const NeverScrollableScrollPhysics(),
      gridDelegate: gridDelegate,
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
