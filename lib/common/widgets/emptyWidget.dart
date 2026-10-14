//空数据
import 'package:comics_app/common/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget Empty() {
  return Container(
    alignment: Alignment.center,
    child: SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: <Widget>[
          Text(
            "空空如也～",
            style: TextStyle(fontSize: 18.sp, color: AppColor.c44415b),
          ),
        ],
      ),
    ),
  );
}