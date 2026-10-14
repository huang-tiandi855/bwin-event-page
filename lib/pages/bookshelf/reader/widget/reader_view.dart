import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/readerOverlayer.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/entities/readerChapterModel.dart';

class ReaderView extends StatelessWidget {
  final ReaderChapterModel? article;
  final int page;
  final double topSafeHeight;
  final TextStyle textStyle;
  final Color bottomOverlayerColor;

  const ReaderView(
      {Key? key,
      required this.topSafeHeight,
      required this.page,
      required this.article,
      required this.textStyle,
      required this.bottomOverlayerColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ReaderOverlayer(
            article: article,
            page: page,
            topSafeHeight: topSafeHeight,
            bottomOverlayerColor: bottomOverlayerColor),
        body(),
      ],
    );
  }

  Widget body() {
    var content = article?.stringAtPageIndex(page);
    return Container(
      alignment: Alignment.topLeft,
      color: Colors.transparent,
      margin: EdgeInsets.fromLTRB(15.w, topSafeHeight + ReaderUtils.topOffset,
          15.w, Screen.bottomSafeHeight + ReaderUtils.bottomOffset),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: content, style: textStyle),
          ],
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
