import 'package:comics_app/common/entities/user/user_account_model.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';
import 'state.dart';

class MyFollowPage extends GetView<MyFollowLogic> {
  const MyFollowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar(
        '我的关注',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.w),
          child: Align(
            alignment: Alignment.center,
            child: TabBar(
              controller: controller.state.tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              indicatorWeight: 0,
              indicatorPadding: EdgeInsets.only(bottom: 5.h),
              indicatorSize: TabBarIndicatorSize.label,

              // 实心指示条：仅上侧圆角，底边平直贴齐 Tab 区域底（参见 tab_indicator.dart）
              indicator: UnderlineTabIndicator(
                insets: EdgeInsets.symmetric(horizontal: 10.w),
                borderSide: BorderSide(
                  width: 3.w,
                  color: AppColor.tabIndicatorColor,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(3.r),
                ),
              ),
              labelColor: AppColor.primaryText,
              unselectedLabelColor: AppColor.tabUnselLabelColor,
              labelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                for (final t in MyFollowState.tabs) Tab(text: t),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 12.w),
        child: TabBarView(
          controller: controller.state.tabController,
          children: const [
            _UserListPane(isFans: false),
            _UserListPane(isFans: true),
          ],
        ),
      ),
    );
  }
}

class _UserListPane extends StatelessWidget {
  const _UserListPane({required this.isFans});

  final bool isFans;

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<MyFollowLogic>();
    return GetBuilder<MyFollowLogic>(
      builder: (_) {
        final state = logic.state;
        final List<UserAccountModel> data =
            isFans ? state.fansList : state.followList;
        final PullRefreshController pr =
            isFans ? state.fansPullRefresh : state.followPullRefresh;

        return PullRefreshView(
          controller: pr,
          onRefresh: () =>
              isFans ? logic.onRefreshFans() : logic.onRefreshFollow(),
          onLoading: () =>
              isFans ? logic.onLoadMoreFans() : logic.onLoadMoreFollow(),
          retryOnTap: () =>
              isFans ? logic.onRefreshFans() : logic.onRefreshFollow(),
          emptyText: isFans ? '暂无粉丝' : '你还没有关注任何人',
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 24.w),
            itemBuilder: (context, index) => _UserRow(
              item: data[index],
              isFans: isFans,
            ),
            separatorBuilder: (_, __) => SizedBox(height: 12.w),
            itemCount: data.length,
          ),
        );
      },
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.item, required this.isFans});

  final UserAccountModel item;
  final bool isFans;

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<MyFollowLogic>();
    final int uid = item.id ?? 0;
    final String name =
        (item.nickName?.isNotEmpty == true) ? item.nickName! : '匿名用户';
    final int fans = item.fansNum ?? 0;
    final int works = (item.vnum ?? 0) + (item.pnum ?? 0);
    final String avatar = item.avatar ?? '';
    final bool follow = item.follow ?? false;
    final bool isMe = uid == logic.myUid && uid != 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (uid <= 0) return;
        Get.toNamed(
          AppRoutes.USER_CENTER,
          arguments: <String, dynamic>{
            'uid': uid,
            'author': <String, dynamic>{
              'id': uid,
              'avatar': avatar,
              'nickName': name,
              'follow': follow,
              'fansNum': fans,
              'vnum': item.vnum,
              'pnum': item.pnum,
            },
          },
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipOval(
            child: CustomImage(
              url: item.avatar ?? '',
              width: 48.w,
              height: 48.w,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6.w),
                Row(
                  children: [
                    Text(
                      '${getShowCountStr(fans)}粉丝',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      '${getShowCountStr(works)}作品',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 自己不显示关注按钮（粉丝 Tab 偶发可能列出自己）。
          if (!isMe)
            GetBuilder<MyFollowLogic>(
              id: 'focus_$uid',
              builder: (_) {
                final bool followed = item.follow ?? false;
                final bool pending = logic.isPendingFor(uid);
                return _FollowChip(
                  followed: followed,
                  loading: pending,
                  onTap: () => logic.toggleFollow(item, isFans: isFans),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FollowChip extends StatelessWidget {
  const _FollowChip({
    required this.followed,
    required this.loading,
    required this.onTap,
  });

  final bool followed;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72.w,
        height: 28.w,
        alignment: Alignment.center,
        decoration: followed
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20.r),
              )
            : BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFFF6E00),
                    Color(0xFFE41A00),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
        child: loading
            ? SizedBox(
                width: 14.w,
                height: 14.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!followed) ...[
                    Icon(Icons.add, size: 14.w, color: Colors.white),
                    SizedBox(width: 2.w),
                  ],
                  Text(
                    followed ? '已关注' : '关注',
                    style: TextStyle(
                      color: followed
                          ? Colors.white.withOpacity(0.6)
                          : Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
