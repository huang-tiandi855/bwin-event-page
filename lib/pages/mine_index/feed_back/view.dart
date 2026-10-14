import 'dart:io';

import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

/// 意见反馈
class FeedBackPage extends StatefulWidget {
  const FeedBackPage({Key? key}) : super(key: key);

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  late final FeedBackLogic logic;
  late final FeedBackState state;

  @override
  void initState() {
    super.initState();
    logic = Get.put(FeedBackLogic());
    state = logic.state;
  }

  @override
  void dispose() {
    logic.disposeFeedbackInput();
    if (Get.isRegistered<FeedBackLogic>()) {
      Get.delete<FeedBackLogic>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.scaffoldBackground,
        appBar: commonAppBar('意见反馈'),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '遇到的问题',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.w),
                    GetBuilder<FeedBackLogic>(
                      id: 'categories',
                      builder: (_) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12.w,
                            crossAxisSpacing: 5.w,
                            childAspectRatio: 82 / 30,
                          ),
                          itemCount: FeedBackState.categories.length,
                          itemBuilder: (context, index) {
                            final selected =
                                logic.state.selectedCategoryIndex == index;
                            return GestureDetector(
                              onTap: () => logic.selectCategory(index),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColor.primaryButtonColor
                                      : Colors.white.withOpacity(.05),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Center(
                                  child: Text(
                                    FeedBackState.categories[index].title ?? '',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 12.w),
                    GetBuilder<FeedBackLogic>(
                      id: 'input',
                      builder: (_) {
                        final len = logic.state.feedbackController.text.length;
                        const counterReserve = 26.0;
                        return Container(
                          height: 160.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.05),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    16.w,
                                    10.w,
                                    16.w,
                                    counterReserve.w,
                                  ),
                                  child: TextField(
                                    controller: logic.state.feedbackController,
                                    maxLines: null,
                                    expands: true,
                                    maxLength: FeedBackState.maxFeedbackLength,
                                    textAlignVertical: TextAlignVertical.top,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                      height: 1.45,
                                    ),
                                    decoration: InputDecoration(
                                      isCollapsed: true,
                                      border: InputBorder.none,
                                      counterText: '',
                                      hintMaxLines: 12,
                                      hintText:
                                          'APP使用过程中遇到问题请截图上传并文字详细，这样能快速排查问题并解决问题，感谢您对我们的支持！',
                                      hintStyle: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.white.withOpacity(0.38),
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 16.w,
                                bottom: 10.w,
                                child: Text(
                                  '$len/${FeedBackState.maxFeedbackLength}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    height: 1.2,
                                    color: Colors.white.withOpacity(0.45),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    GetBuilder<FeedBackLogic>(
                        id: 'imagePaths',
                        builder: (_) {
                          return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.only(top: 12.w),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1,
                                mainAxisSpacing: 10.w,
                                crossAxisSpacing: 10.w,
                              ),
                              itemBuilder: (context, index) {
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Image.file(
                                        File(state.imagePaths[index]),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    Positioned(
                                      right: 4.w,
                                      top: 5.w,
                                      child: GestureDetector(
                                        onTap: () => logic.removeImage(index),
                                        child: AssetsGen
                                            .images.circle.publishClose
                                            .image(width: 20.w, height: 20.w),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              itemCount: state.imagePaths.length);
                        }),
                    SizedBox(height: 40.w),
                    Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            child: InkWell(
                              onTap: logic.insertImage,
                              borderRadius: BorderRadius.circular(20.r),
                              child: Container(
                                height: 40.w,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AssetsGen.images.mine.upImgIcon.image(
                                      width: 24.w,
                                      height: 24.w,
                                    ),
                                    SizedBox(
                                      height: 24.w,
                                      child: Text(
                                        '插入图片',
                                        style: TextStyle(
                                          height: 1.6,
                                          fontSize: 14.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: Material(
                            color: AppColor.primaryButtonColor,
                            borderRadius: BorderRadius.circular(24.r),
                            child: InkWell(
                              onTap: logic.submit,
                              borderRadius: BorderRadius.circular(24.r),
                              child: SizedBox(
                                height: 40.w,
                                child: Center(
                                  child: Text(
                                    '提交',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: bottom + 27.w, top: 8.w),
              child: Center(
                child: GestureDetector(
                  onTap: logic.openCustomerService,
                  behavior: HitTestBehavior.opaque,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      children: const <InlineSpan>[
                        TextSpan(text: '点击联系 '),
                        TextSpan(
                          text: '在线客服',
                          style: TextStyle(
                            color: AppColor.primaryButtonColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
