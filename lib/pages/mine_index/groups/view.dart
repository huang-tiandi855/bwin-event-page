import 'package:comics_app/common/routers/app_navigator.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/entities/group_model.dart';
import 'logic.dart';

/// 加群开车
class GroupsPage extends StatelessWidget {
  GroupsPage({Key? key}) : super(key: key);

  final GroupsLogic logic = Get.put(GroupsLogic());

  @override
  Widget build(BuildContext context) {
    final state = logic.state;
    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar('加群开车'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Section(
              title: '官方社群',
              subtitle: '一起看片一起分享心得',
              groups: state.officialCommunity,
            ),
            SizedBox(height: 24.w),
            _Section(
              title: '商务合作',
              subtitle: '代理合作/商务合作',
              groups: state.businessCooperation,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.groups,
  });

  final String title;
  final String subtitle;
  final List<GroupModel> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.w),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(.5),
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 12.w),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.05),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            children: [
              for (int i = 0; i < groups.length; i++)
                _GroupRow(group: groups[i]),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.w),
      child: Row(
        children: [
          CustomImage(
            url: group.iconUrl,
            width: 42.w,
            height: 42.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              group.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _joinButton(),
        ],
      ),
    );
  }

  Widget _joinButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final url = group.jumpUrl;
        if (url == null || url.isEmpty) return;
        AppNavigator.to.go(url);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.w),
        decoration: BoxDecoration(
          color: group.jumpUrl!.isEmpty
              ? AppColor.primaryButtonColor.withOpacity(.5)
              : AppColor.primaryButtonColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          '立即加入',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
