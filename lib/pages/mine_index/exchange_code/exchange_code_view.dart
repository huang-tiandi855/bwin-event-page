import 'package:comics_app/common/entities/user_redemption_model.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/date_time_util.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'exchange_code_logic.dart';

///兑换码
class ExchangeCodePage extends StatefulWidget {
  const ExchangeCodePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExchangeCodeState();
}

class _ExchangeCodeState extends State<ExchangeCodePage> {
  final logic = Get.find<ExchangeCodeLogic>();
  final state = Get.find<ExchangeCodeLogic>().state;

  @override
  void dispose() {
    // 显式释放 controller：必须在 super.dispose() 之前完成，
    // 且不要走 Get.delete（同步触发 onClose 容易抢在 widget unmount 之前）。
    state.editingController.dispose();
    state.pullRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColor.scaffoldBackground,
        appBar: commonAppBar("兑换码"),
        body: Column(
          children: [
            /// 输入兑换码
            _buildInputSection(),

            /// 兑换记录
            Expanded(child: _buildRecordSection()),

            /// 立即兑换按钮
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// 顶部：输入兑换码 + 提示 + 输入框（固定，不参与下拉刷新）
  Widget _buildInputSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('输入兑换码',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 12),
          Text('每个兑换码只能输入一次',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(.5),
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 12),
          GetBuilder<ExchangeCodeLogic>(
            id: "EditCode",
            builder: (controller) {
              return SizedBox(
                height: 50.w,
                child: Row(
                  children: [
                    Text('兑换码',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        )),
                    SizedBox(width: 38.w),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: state.editingController,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                          onChanged: (value) => logic.updateValue(value),
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(.5),
                              fontWeight: FontWeight.w400,
                            ),
                            hintText: "请输入兑换码（字母大写）",
                            hintMaxLines: 1,
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(12),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z0-9]'))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            height: 1,
            color: Colors.white.withOpacity(.15),
          ),
          SizedBox(height: 12.w),
          Text(
            "官方社群领取更多福利",
            style: TextStyle(
              color: Colors.white.withOpacity(.3),
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 16.w),
          Text(
            "兑换记录",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.w),
        ],
      ),
    );
  }

  /// 中间：兑换记录列表（下拉刷新 / 上拉加载更多）
  Widget _buildRecordSection() {
    return GetBuilder<ExchangeCodeLogic>(builder: (logic) {
      final isEmpty = state.list.isEmpty;
      // 空数据时也保留下拉刷新：列表里渲染一个占位行，不让 PullRefreshView 切到空态分支
      final itemCount = isEmpty ? 2 : state.list.length + 1;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: PullRefreshView(
          controller: state.pullRefreshController,
          onRefresh: () async => logic.onRefresh(),
          onLoading: () async => logic.onLoad(),
          retryOnTap: () async => logic.onRefresh(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.zero,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index == 0) return _buildListHeader();
              if (isEmpty) return _buildEmptyTip();
              return _buildRedemptionItemUI(
                state.list[index - 1],
                index - 1,
              );
            },
          ),
        ),
      );
    });
  }

  /// 空数据占位行（与表头共用同样的圆角拼接）
  Widget _buildEmptyTip() {
    return Container(
      height: 120.w,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(28, 37, 39, 1),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10.r)),
      ),
      alignment: Alignment.center,
      child: Text(
        '暂无兑换记录',
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.white.withOpacity(.5),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// 列表表头（兑换码 / 兑换类型 / 兑换时间）
  Widget _buildListHeader() {
    return Container(
      height: 40.w,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(19, 28, 30, 1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('兑换码',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 1,
            child: Text('兑换类型',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 1,
            child: Text('兑换时间',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Container _buildRedemptionItemUI(
    ExchangeRecordItemModel? item,
    int index,
  ) {
    // 兑换码
    final code = item?.redeemCode ?? '';
    // 兑换类型
    final type = TextUtil.formatReward(item?.rewardType ?? '',
        rewardPayload: item?.rewardPayload ?? '');
    // 兑换时间：服务端 `createdAt` 是毫秒时间戳（model 已 `?.toString()`），
    // 统一通过 [DateTimeUtil.timestamp2YearMonthDay] 转成本地 yyyy-MM-dd。
    final date = DateTimeUtil.timestamp2YearMonthDay(item?.createdAt);

    final cellStyle = TextStyle(
      fontSize: 14.sp,
      color: Colors.white.withOpacity(.5),
      fontWeight: FontWeight.w400,
    );

    return Container(
      height: 40.w,
      decoration: BoxDecoration(
        color: index % 2 == 0
            ? const Color.fromRGBO(28, 37, 39, 1)
            : const Color.fromRGBO(19, 28, 30, 1),
        borderRadius: index == state.list.length - 1
            ? BorderRadius.vertical(bottom: Radius.circular(10.r))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(code, textAlign: TextAlign.center, style: cellStyle),
          ),
          Expanded(
            flex: 1,
            child: Text(type, textAlign: TextAlign.center, style: cellStyle),
          ),
          Expanded(
            flex: 1,
            child: Text(date, textAlign: TextAlign.center, style: cellStyle),
          ),
        ],
      ),
    );
  }

  /// 底部：立即兑换 按钮
  Widget _buildSubmitButton() {
    return GetBuilder<ExchangeCodeLogic>(
      id: "canSubmit",
      builder: (controller) => Center(
        child: GestureDetector(
          onTap: () {
            logic.redemptionCodeReq();
          },
          child: Container(
            height: 48.w,
            margin: EdgeInsets.only(bottom: 36.w, left: 16.w, right: 16.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColor.primaryButtonColor,
              borderRadius: BorderRadius.circular(24.w),
            ),
            child: Text(
              '立即兑换',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
