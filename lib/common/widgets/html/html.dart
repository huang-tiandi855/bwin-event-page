import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'html_parser.dart';

class Html extends StatelessWidget {
  const Html({
    Key? key,
    required this.data,
    this.padding,
    this.backgroundColor,
    this.defaultTextStyle = const TextStyle(color: Colors.black),
    required this.onLinkTap,
    this.renderNewlines = false,
  }) : super(key: key);

  final String data;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final TextStyle? defaultTextStyle;
  final Function(String) onLinkTap;
  final bool renderNewlines;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Container(
      padding: padding,
      color: backgroundColor,
      width: width,
      child: DefaultTextStyle.merge(
        style: defaultTextStyle,
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.start,
              children: HtmlParser(
                width: width,
                onLinkTap: onLinkTap,
                renderNewlines: renderNewlines,
              ).parse(data),
            ),
            SizedBox(height: 30.h),
            // Image.asset(
            //   "assets/images/avcommentary_bottom_logo.png",
            //   width: 134,
            //   height: 43,
            // ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}
