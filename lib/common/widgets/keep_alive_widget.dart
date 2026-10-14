import 'package:flutter/material.dart';

/// 保持widget 活跃
/// 使用：KeepAliveWidget(widget);
class KeepAliveWidget extends StatefulWidget {
  final Widget child;

  const KeepAliveWidget(this.child, {super.key});

  @override
  KeepAliveState createState() => KeepAliveState();
}

class KeepAliveState extends State<KeepAliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

Widget keepAliveWrapper(Widget child) {
  return KeepAliveWidget(child);
}
