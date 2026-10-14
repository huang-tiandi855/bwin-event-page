/*
 * @author admin.
 * @date: 2021/6/24 9:52 上午
 * @description: flutter
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomSheetView extends StatelessWidget {
  ///标题文字描述
  final String? title;

  ///选项列表
  final List<String>? options;

  ///标题文字样式
  final TextStyle? titleTextStyle;

  ///选项内容文字样式
  final TextStyle? optionTextStyle;

  ///取消按钮文字样式
  final TextStyle? cancelTextStyle;

  ///确定选中选项
  final Function(String option) didOptionSelected;

  const BottomSheetView({
    Key? key,
    @required this.title,
    @required this.options,
    required this.didOptionSelected,
    this.titleTextStyle,
    this.optionTextStyle,
    this.cancelTextStyle,
  }) : super(key: key);

  final TextStyle defaultTextStyle = const TextStyle(
    color: Color(0xFF3F454F),
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: CupertinoActionSheet(
        title: Text(
          title.toString(),
          style: titleTextStyle ?? defaultTextStyle,
        ),
        actions: options
            ?.map(
              (e) => CupertinoActionSheetAction(
                onPressed: () {
                  didOptionSelected.call(e);
                },
                child: Text(
                  e,
                  style: optionTextStyle,
                ),
              ),
            )
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            '取消',
            style: cancelTextStyle,
          ),
        ),
      ),
    );
  }
}
