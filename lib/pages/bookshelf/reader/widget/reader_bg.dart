import 'package:comics_app/common/style/style.dart';
import 'package:flutter/material.dart';

import '../../../../common/res/r.dart';

enum BgType {
  yellowBg, //黄色
  night, // 夜晚模式
  greenBg, //绿色
}

class ReaderBg extends StatefulWidget {
  final BgType bgType;

  const ReaderBg({Key? key, this.bgType = BgType.yellowBg}) : super(key: key);

  @override
  State<ReaderBg> createState() => _ReadBgState();
}

class _ReadBgState extends State<ReaderBg> {
  @override
  Widget build(BuildContext context) {
    Widget bodyItem;
    switch (widget.bgType) {
      case BgType.night:
        bodyItem = nightWidget();
        break;
      case BgType.greenBg:
        bodyItem = greenWidget();
        break;
      default:
        bodyItem = yellowBgWidget();
    }
    return Positioned(left: 0, top: 0, right: 0, bottom: 0, child: bodyItem);
  }

  Widget yellowBgWidget() {
    return Image.asset(R.readBbg1, fit: BoxFit.cover);
  }

  Widget nightWidget() {
    return Container(
      alignment: Alignment.center,
      color: const Color(0xFF1A1A1A),
    );
  }

  Widget greenWidget() {
    return Container(
      alignment: Alignment.center,
      color: AppColor.cf5f5f5,
    );
  }
}
