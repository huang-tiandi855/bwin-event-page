import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'income_detail_logic.dart';

class IncomeDetailPage extends StatelessWidget {
  const IncomeDetailPage({Key? key}) : super(key: key);

  static const Color _pageBg = Color(0xFF061313);

  @override
  Widget build(BuildContext context) {
    final IncomeDetailLogic logic = Get.find<IncomeDetailLogic>();
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: commonAppBar(
        '收益明细',
        bgColor: Colors.black,
        isShowLine: false,
      ),
      body: GetBuilder<IncomeDetailLogic>(
        builder: (_) {
          return getBgColorsView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                16.h.verticalSpace,
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: logic.state.records.isEmpty
                          ? getEmptyWidget(emptyText: '暂无数据')
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
