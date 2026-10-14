import 'package:flutter/material.dart';

/// 统一的 Sliver 容器组件（历史命名：Ciew）。
class CustomSliverCiew extends StatelessWidget {
  const CustomSliverCiew({
    Key? key,
    required this.slivers,
    this.controller,
    this.physics,
  }) : super(key: key);

  final List<Widget> slivers;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      physics: physics,
      slivers: slivers,
    );
  }
}
