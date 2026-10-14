import 'package:comics_app/common/entities/readerChapterModel.dart';
import 'package:comics_app/common/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common/res/r.dart';

Widget drawer(
    List<ReaderChapterModel> readerList,
    int curChapterNum,
    String? title,
    bool directoryReverseOrder,
    Function(int index) onToggleChapter,
    void Function() hideMenu,
    void Function() setDirectoryReverseOrder,
    {required Color drawerColor,
    required Color drawerActiveColor,
    required Color drawerBg,
    required Color drawerLine,
    required Color drawerColorSeTitle,
    required BuildContext context}) {
  int length = readerList.length;

  return Drawer(
    backgroundColor: drawerBg,
    width: 210.w,
    child: SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 110.w,
            child: Column(children: [
              SizedBox(height: 30.w),
              Container(
                width: 210.w,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                alignment: Alignment.center,
                child: Text(
                  title ?? "未知小说",
                  style: TextStyle(
                      color: drawerColorSeTitle,
                      fontSize: 18.sp,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10.w),
              Container(
                color: AppColor.bluishPurple,
                width: 210.w,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                height: 24.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("共$length章",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500)),
                    GestureDetector(
                      onTap: () {
                        setDirectoryReverseOrder();
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 2.w),
                            child: SvgPicture.asset(
                                directoryReverseOrder
                                    ? R.positiveSequence
                                    : R.reverseOrder,
                                width: 12.w,
                                color: Colors.white),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            directoryReverseOrder ? "正序" : "倒序",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.w),
            ]),
          ),
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            alignment: Alignment.topLeft,
            child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                  reverse: directoryReverseOrder,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    index = index;
                    String name = readerList[index].name;
                    return InkWell(
                      onTap: () {
                        onToggleChapter(index);
                        hideMenu();
                      },
                      child: Padding(
                          padding: EdgeInsets.only(bottom: 16.w),
                          child: Text(
                            "${index + 1}-$name",
                            style: TextStyle(
                                color: (curChapterNum - 1) == index
                                    ? drawerActiveColor
                                    : drawerColor,
                                fontSize: 15.sp,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                          )),
                    );
                  },
                  itemCount: length,
                )),
          )),
        ],
      ),
    ),
  );
}
