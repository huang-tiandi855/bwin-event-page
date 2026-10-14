import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:comics_app/common/widgets/common_dialog/publish_rule_dialog.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:comics_app/pages/circle/publish/publish_logic.dart';
import 'package:comics_app/pages/circle/publish/publish_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common/style/color.dart';
import '../../../common/widgets/custom_picture_management.dart';

class PublishPage extends StatelessWidget {
  PublishPage({super.key});

  final logic = Get.find<PublishLogic>();
  final state = Get.find<PublishLogic>().state;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        closeKeyboard(context);
      },
      onPanDown: (_) {
        closeKeyboard(context);
      },
      child: GetBuilder<PublishLogic>(builder: (logic) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Scaffold(
                backgroundColor: AppColor.scaffoldBackground,
                appBar: commonAppBar(
                  state.uploadType == UploadType.UPLOAD_IMG
                      ? "发布图片"
                      : state.uploadType == UploadType.UPLOAD_VIDEO
                          ? "发布视频"
                          : "发布图文",
                  actions: [
                    GestureDetector(
                      onTap: showPublishRuleDialog,
                      child: Container(
                        margin: const EdgeInsets.only(right: 18, top: 10),
                        child: Text(
                          '规则',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  controller: state.scrollController,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 100.w, top: 12.w),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题
                          _buildPublishTitleField(),
                          // 正文。介绍
                          _buildPublishIntroField(),
                          // // 选择图片展示样式
                          // _buildPublishImageStyleRow(logic),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 18.w),
                                // 选择图集
                                _buildVideoPictures(logic),
                                getHeight(16),
                                // 选择视频
                                _buildSelectMedia(),
                                // 设置价格
                                _buildPriceRow(context, logic),
                              ],
                            ),
                          ),
                        ]),
                  ),
                )),
            Positioned(
              bottom: 30,
              child: GestureDetector(
                onTap: () => logic.submitPublish(context),
                child: Container(
                  width: ScreenUtil().screenWidth,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    height: 48.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColor.primaryButtonColor,
                      borderRadius: BorderRadius.circular(25.w),
                    ),
                    child: Text(
                      '确定发布',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// 发布页顶部：选择图片展示样式（ 0 平铺， 1，九宫格）。
  ///
  /// `state.imageDisplayStyle == null` 时展示占位文案，选中后展示对应文案。
  Widget _buildPublishImageStyleRow(PublishLogic logic) {
    final PublishImageStyle? style = logic.state.imageDisplayStyle;
    final bool selected = style != null;
    return GestureDetector(
      onTap: () => _openPublishImageStyleBottomSheet(logic),
      child: Container(
        width: ScreenUtil().screenWidth,
        height: 50.w,
        padding: EdgeInsets.only(left: 16.w, right: 16.w),
        margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              selected ? style.label : '选择图片展示方式',
              style: TextStyle(
                color: selected ? Colors.white : Colors.white.withOpacity(.5),
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
            const Spacer(),
            Image.asset(
              "assets/images/png/right_arrow.png",
              width: 16.w,
              height: 16.w,
              color: selected ? Colors.white : Colors.white.withOpacity(.5),
            ),
          ],
        ),
      ),
    );
  }

  /// 打开「图片展示方式」选择底部弹层。
  void _openPublishImageStyleBottomSheet(PublishLogic logic) {
    final PublishImageStyle? current = logic.state.imageDisplayStyle;
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColor.scaffoldBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18.w)),
        ),
        padding: EdgeInsets.only(top: 12.w, bottom: 12.w),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              SizedBox(height: 10.w),
              Text(
                '选择图片展示方式',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(.5),
                ),
              ),
              SizedBox(height: 8.w),
              for (final PublishImageStyle style in PublishImageStyle.values)
                _PublishImageStyleTile(
                  label: style.label,
                  selected: current == style,
                  onTap: () {
                    logic.state.imageDisplayStyle = style;
                    logic.update();
                    Get.back();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 发布标题单行输入。
  Widget _buildPublishTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.only(left: 16.w, right: 16.w),
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
      ),
      width: ScreenUtil().screenWidth,
      height: 58.w,
      child: Center(
        child: TextField(
          cursorColor: Colors.white,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(255),
          ],
          maxLines: 1,
          controller: state.textEditingController,
          decoration: InputDecoration(
            hintText: "请填写标题",
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(.5),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// 发布正文 / 介绍多行输入。
  Widget _buildPublishIntroField() {
    return Visibility(
      visible: state.uploadType != UploadType.UPLOAD_IMG,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.05),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        margin: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 16.w,
        ),
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 6.w,
        ),
        width: ScreenUtil().screenWidth,
        child: TextField(
          cursorColor: Colors.white.withOpacity(.5),
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
          maxLength: 300,
          maxLines: 3,
          controller: state.textContentEditingController,
          decoration: InputDecoration(
            hintText: "有趣的介绍能够将你的逼格提高n个档次！...",
            border: InputBorder.none,
            counterStyle: TextStyle(
              color: Colors.white.withOpacity(.5),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(.5),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// 选择视频。
  Widget _buildSelectMedia() {
    return GetBuilder<PublishLogic>(builder: (logic) {
      return Visibility(
        visible: state.uploadType == UploadType.UPLOAD_VIDEO,
        child: PictureMangeWidget(
          videoPath: logic.state.videoPath,
          picList: logic.state.videoPicList,
          picWebList: logic.state.picWebList,
          uploadType: UploadType.UPLOAD_VIDEO,
          deleteItemCallback: (index) {
            logic.onDeleteItem(UploadType.UPLOAD_VIDEO, index);
          },
          addItemCallback: () async {
            logic.onSelectPicAndVideo(UploadType.UPLOAD_VIDEO);
          },
          key: UniqueKey(),
          width: 100.w,
          height: 100.w,
        ),
      );
    });
  }

  /// 选择图集。
  Widget _buildVideoPictures(PublishLogic logic) {
    return PictureMangeWidget(
      videoPath: "",
      picList: logic.state.picList,
      picWebList: logic.state.picWebList,
      uploadType: UploadType.UPLOAD_IMG,
      deleteItemCallback: (index) {
        logic.onDeleteItem(UploadType.UPLOAD_IMG, index);
      },
      addItemCallback: () async {
        logic.onSelectPicAndVideo(UploadType.UPLOAD_IMG);
      },
      key: UniqueKey(),
      width: 100.w,
      height: 100.w,
    );
  }

  /// 设置价格
  Widget _buildPriceRow(BuildContext context, PublishLogic logic) {
    return Visibility(
      visible: state.uploadType == UploadType.UPLOAD_VIDEO,
      child: GestureDetector(
        onTap: () => showCoinDialog(context, -1, logic),
        child: Container(
          height: 50.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          margin: EdgeInsets.only(top: 16.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(25.w),
          ),
          child: Row(
            children: [
              AssetsGen.images.circle.iconGlodenBean
                  .image(width: 28.w, height: 28.w),
              getWidth(5.w),
              Text(
                '设置价格',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              state.selectedCoin == 0
                  ? Text(
                      '免费',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Text(
                      state.selectedCoin.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
              getWidth(10.w),
              Image.asset(
                "assets/images/png/right_arrow.png",
                width: 16.w,
                height: 16.w,
                color: Colors.white,
              ),
              getWidth(10.w),
            ],
          ),
        ),
      ),
    );
  }

  void showCoinDialog(
      BuildContext context, int selectIndex, PublishLogic logic) {
    int selectedPresetIndex = selectIndex;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: Container(
                color: AppColor.scaffoldBackground,
                padding: EdgeInsets.fromLTRB(
                    16.w, 17.5.w, 16.w, 17.5.w + bottomInset),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 36.w,
                        height: 5.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 37.5.w),
                    Text(
                      '设置价格',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16.w),
                    SizedBox(
                      height: 170.w,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8.w,
                          mainAxisSpacing: 10.w,
                          childAspectRatio: 1,
                        ),
                        itemCount: state.selectedCoins.length,
                        itemBuilder: (context, index) {
                          final selected = selectedPresetIndex == index;
                          final coins = state.selectedCoins[index];
                          return GestureDetector(
                            onTap: () {
                              selectedPresetIndex = index;
                              setSheetState(() {});
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColor.primaryButtonColor
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: selected
                                      ? AppColor.primaryButtonColor
                                      : Colors.white.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AssetsGen.images.circle.iconGlodenBean
                                      .image(width: 28.w, height: 28.w),
                                  SizedBox(height: 6.w),
                                  Text(
                                    '$coins金币',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.w),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '自定义',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          height: 40.w,
                          width: 63.w,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: TextField(
                              onTap: () {
                                selectedPresetIndex = -1;
                                setSheetState(() {});
                              },
                              textAlign: TextAlign.center,
                              cursorColor: Colors.white70,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLength: 100,
                              maxLines: 1,
                              controller: state.textEditingCoinController,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: '0',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.35),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '金币',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.w),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColor.primaryButtonColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        onPressed: () {
                          if (selectedPresetIndex == -1) {
                            if (state.textEditingCoinController.text.isEmpty) {
                              showToast(msg: "请选择金额");
                              return;
                            }
                            if (state.textEditingCoinController.text
                                .contains("-")) {
                              showToast(msg: "必须输入正数");
                              return;
                            }
                            if (state.textEditingCoinController.text
                                .contains(".")) {
                              showToast(msg: "请输入整数");
                              return;
                            }
                            if (int.parse(
                                    state.textEditingCoinController.text) >
                                10000) {
                              showToast(msg: "必须小于10000");
                              return;
                            }
                            state.selectedCoin =
                                int.parse(state.textEditingCoinController.text);
                          } else {
                            if (selectedPresetIndex < 0 ||
                                selectedPresetIndex >=
                                    state.selectedCoins.length) {
                              showToast(msg: "请选择金额");
                              return;
                            }
                            state.selectedCoin =
                                state.selectedCoins[selectedPresetIndex];
                          }
                          Navigator.of(sheetContext).pop();
                          logic.update();
                        },
                        child: Text(
                          '确定设置',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// 「图片展示方式」底部弹层中的单项。
class _PublishImageStyleTile extends StatelessWidget {
  const _PublishImageStyleTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 52.w,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
