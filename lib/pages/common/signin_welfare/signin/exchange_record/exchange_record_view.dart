import 'package:comics_app/common/entities/sign_in/points_exchange_record_entity.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:comics_app/common/widgets/general_widget/full_bg.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'exchange_record_logic.dart';

class ExchangeRecordPage extends StatelessWidget {
  const ExchangeRecordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ExchangeRecordLogic logic = Get.find<ExchangeRecordLogic>();
    return FullBg(
      height: 211.h,
      bgImage: AssetsGen.images.signin.icSigninExchangeBg,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: commonAppBar(
          '会员兑换',
          bgColor: Colors.transparent,
          isShowLine: false,
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: GetBuilder<ExchangeRecordLogic>(
            builder: (_) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  23.h.verticalSpace,
                  _PointsCard(points: logic.state.currentPoints),
                  16.h.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      '兑换记录',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  10.h.verticalSpace,
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
                      child: _RecordPanel(records: logic.state.records),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        gradient: const LinearGradient(
          colors: _ExchangeRecordColors.card,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '当前积分',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          10.h.verticalSpace,
          Text(
            '$points',
            style: TextStyle(
              color: AppColor.primaryButtonColor,
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordPanel extends StatelessWidget {
  const _RecordPanel({required this.records});

  final List<PointsExchangeRecordModel> records;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        children: [
          const _RecordHeader(),
          if (records.isEmpty)
            Expanded(
              child: getEmptyWidget(emptyText: '暂无数据'),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: records.length,
                itemBuilder: (context, index) {
                  return _RecordRow(
                    record: records[index],
                    odd: index.isOdd,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _RecordHeader extends StatelessWidget {
  const _RecordHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.02),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
      ),
      child: const Row(
        children: [
          Expanded(child: _HeaderCell('奖品名称')),
          Expanded(child: _HeaderCell('消耗能量')),
          Expanded(child: _HeaderCell('兑换时间')),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.record,
    required this.odd,
  });

  final PointsExchangeRecordModel record;
  final bool odd;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      color: odd ? Colors.transparent : _ExchangeRecordColors.rowAlt,
      child: Row(
        children: [
          Expanded(child: _BodyCell(record.displayName)),
          Expanded(child: _BodyCell('${record.displayCostPoints}')),
          Expanded(child: _BodyCell(_formatDate(record.displayTimeMillis))),
        ],
      ),
    );
  }

  static String _formatDate(int? millis) {
    if (millis == null || millis <= 0) return '-';
    final DateTime d = DateTime.fromMillisecondsSinceEpoch(millis);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withOpacity(.45),
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ExchangeRecordColors {
  const _ExchangeRecordColors._();

  static const List<Color> card = [
    Color(0xFF0F2024),
    Color(0xFF303131),
  ];
  static const Color rowAlt = Color(0xFF1A2B2E);
}
