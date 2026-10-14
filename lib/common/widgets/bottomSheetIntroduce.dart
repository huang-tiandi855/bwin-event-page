import 'package:comics_app/common/entities/media_info_entity.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void bottomSheetIntroduce(MediaInfoEntity mediaInfoEntity) async {
  String summary = mediaInfoEntity.summary ?? "";
  String title = mediaInfoEntity.title ?? "";
  List tagNames = mediaInfoEntity.tagNames ?? [];
  await Get.bottomSheet(
      Container(
        color: Colors.white,
        height: 439.w,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppLocation.appHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 18.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('简介',
                        style:
                            TextStyle(fontSize: 18.sp, color: AppColor.black)),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child:
                          Icon(Icons.close, size: 24.sp, color: AppColor.black),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis),
                        maxLines: 1),
                    SizedBox(height: 5.w),
                    Text.rich(
                      TextSpan(
                          children: List.generate(
                              tagNames.length,
                              (index) => TextSpan(
                                  text: '${tagNames[index]}  ',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColor.warmGrey)))),
                      maxLines: 2,
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: AppColor.warmGrey,
                          height: 1.6,
                          fontSize: 14.sp),
                    ),
                    SizedBox(height: 12.w),
                    Text(summary, style: TextStyle(fontSize: 12.sp))
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
      backgroundColor: AppColor.white);
}
