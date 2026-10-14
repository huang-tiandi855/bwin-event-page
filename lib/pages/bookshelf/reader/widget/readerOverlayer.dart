import 'package:comics_app/common/entities/readerChapterModel.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/utils/date_util.dart';

class ReaderOverlayer extends StatelessWidget {
  final ReaderChapterModel? article;
  final int page;
  final double topSafeHeight;
  final Color bottomOverlayerColor;

  const ReaderOverlayer(
      {super.key, required this.article,
      required this.page,
      required this.topSafeHeight,
      required this.bottomOverlayerColor});

  @override
  Widget build(BuildContext context) {
    var time = DataFormats.formatDateHn(DateTime.now());
    return Container(
      padding: EdgeInsets.fromLTRB(
          15, 5.h + topSafeHeight, 15, 10.h + Screen.bottomSafeHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${article?.name}",
              style: TextStyle(fontSize: 14.w, color: bottomOverlayerColor)),
          Expanded(child: Container()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //  BatteryView(bottomOverlayerColor: bottomOverlayerColor,),
              // const SizedBox(width: 3),
              Text(time,
                  style:
                      TextStyle(fontSize: 11.sp, color: bottomOverlayerColor)),
              Expanded(child: Container()),
              Text('${page + 1}/${article?.pageCount}',
                  style:
                      TextStyle(fontSize: 11.sp, color: bottomOverlayerColor)),
            ],
          ),
        ],
      ),
    );
  }
}
