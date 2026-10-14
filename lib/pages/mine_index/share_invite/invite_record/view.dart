import 'package:comics_app/common/entities/mine/invite_record_model.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';

class InviteRecordPage extends GetView<InviteRecordLogic> {
  const InviteRecordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar('邀请记录'),
      body: GetBuilder<InviteRecordLogic>(
        builder: (_) {
          final state = controller.state;
          return PullRefreshView(
            controller: state.pullRefreshController,
            onRefresh: controller.onRefresh,
            onLoading: controller.onLoadMore,
            retryOnTap: controller.onRefresh,
            emptyWidget: const _EmptyView(),
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.w, 16.w, 24.w),
              physics: const BouncingScrollPhysics(),
              itemCount: state.records.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.w),
              itemBuilder: (_, index) => _RecordItem(
                text: '已邀请${_displayLabel(state.records[index], index)}',
              ),
            ),
          );
        },
      ),
    );
  }

  /// 单条记录展示文案：优先昵称，其次账号、手机号脱敏，最后回落到用户 id / 序号。
  String _displayLabel(InviteUserModel item, int index) {
    final nick = item.nickName?.trim();
    if (nick != null && nick.isNotEmpty) return nick;
    final account = item.account?.trim();
    if (account != null && account.isNotEmpty) return account;
    final phone = item.phone?.trim();
    if (phone != null && phone.isNotEmpty) return _maskPhone(phone);
    if (item.id != null) return '用户${item.id}';
    return '${index + 1}人';
  }

  String _maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }
}

/// 单条邀请记录：高度 40，#FFFFFF0D 背景 + 圆角 10。
class _RecordItem extends StatelessWidget {
  const _RecordItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.w,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: const Color(0x80FFFFFF),
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

/// 空数据视图：高 477，左右上各 16，使用 invite_empty_img 插图 + 「暂无数据」。
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 477.w,
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
        decoration: BoxDecoration(
          color: const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AssetsGen.images.mine.inviteEmptyImg.image(
              width: 206.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 23.w),
            Text(
              '暂无数据',
              style: TextStyle(
                color: AppColor.primaryButtonColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
