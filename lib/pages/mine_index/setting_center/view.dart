import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../image/network/custom_image_network.dart';
import 'logic.dart';

/// 设置中心
class SettingCenterPage extends StatelessWidget {
  const SettingCenterPage({Key? key}) : super(key: key);

  static Color get _cardBg => Colors.white.withOpacity(.05);

  static Color get _divider => Colors.white.withOpacity(.15);

  static Color get _subText => Colors.white.withOpacity(.50);

  @override
  Widget build(BuildContext context) {
    // 路由关闭过程中 GetX 可能已删除 Logic，但本页仍可能被再 build 一次，勿用 GetView.controller。
    if (!Get.isRegistered<SettingCenterLogic>()) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColor.scaffoldBackground,
      appBar: commonAppBar("设置中心"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: GetBuilder<SettingCenterLogic>(
          builder: (l) {
            final u = UserStore.to.getUserInfoModel;
            final id = u?.uid ?? 0;
            final name = (u?.name?.isNotEmpty == true) ? u!.name! : '未设置';
            final portrait = u?.avatarUrl ?? '';
            final genderLabel = _genderLabel(u?.gender);
            final mobile = u?.mobile ?? '';
            final phoneTrailing = u?.bindStatus == 1 ? mobile : '绑定手机';
            final invite =
                (u?.invitationCode ?? '').isNotEmpty ? u!.invitationCode! : '';

            return Container(
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                children: [
                  _AvatarRow(
                    portrait: portrait,
                    onTap: l.openSelectAvatar,
                  ),
                  _line(),
                  _ChevronRow(
                      title: '昵称', value: name, onTap: l.openEditNickname),
                  _line(),
                  _IdRow(
                    id: id.toString(),
                    onCopy: id.toString().isNotEmpty
                        ? () {
                            Clipboard.setData(
                                ClipboardData(text: id.toString()));
                            showToast(msg: '已复制');
                          }
                        : null,
                  ),
                  _line(),
                  _ChevronRow(
                    title: '性别',
                    value: genderLabel,
                    onTap: l.openEditGender,
                  ),
                  _line(),
                  _ChevronRow(
                    title: '手机号码',
                    value: phoneTrailing,
                    onTap: l.openBindPhone,
                  ),
                  _line(),
                  _ChevronRow(
                    title: '账号找回',
                    onTap: () => Get.toNamed(AppRoutes.ACCOUNT_SAFE),
                  ),
                  _line(),
                  _ChevronRow(
                    title: '邀请码',
                    value: invite.isEmpty ? '未设置' : invite,
                    onTap: () {
                      l.openBindInvite();
                    },
                  ),
                  _line(),
                  _ChevronRow(
                    title: '常见问题',
                    onTap: () => Get.toNamed(AppRoutes.MINE_COMMON_PROBLEM),
                  ),
                  _line(),
                  _ChevronRow(
                    title: '账号凭证',
                    onTap: () => Get.toNamed(AppRoutes.ACCOUNT_CREDENTIALS),
                  ),
                  _line(),
                  _ChevronRow(
                    title: '清除缓存',
                    value: l.state.cacheSizeLabel,
                    onTap: l.markCacheCleared,
                  ),
                  _line(),
                  _ChevronRow(
                    title: '检查更新',
                    value: 'v${ConfigStore.to.version}',
                    onTap: l.checkAppUpdate,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _line() => Container(
        margin: EdgeInsets.only(left: 16.w),
        height: 1,
        color: _divider,
      );

  String _genderLabel(int? g) {
    if (g == null) return '未设置';
    return g == 1
        ? '男'
        : g == 0
            ? '女'
            : '保密';
  }
}

class _AvatarRow extends StatelessWidget {
  const _AvatarRow({required this.portrait, required this.onTap});

  final String portrait;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
        child: Row(
          children: [
            Text(
              '头像',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            CustomImage(
              url: portrait,
              width: 25.w,
              height: 25.w,
              borderRadius: BorderRadius.circular(12.5.r),
            ),
            SizedBox(width: 4.w),
            AssetsGen.images.mine.mineLineBack.image(
              width: 16.w,
              height: 16.w,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChevronRow extends StatelessWidget {
  const _ChevronRow({
    required this.title,
    this.value,
    required this.onTap,
  });

  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sub = SettingCenterPage._subText;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.w),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (value != null) ...[
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  value!,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: sub,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ] else
              const Spacer(),
            SizedBox(width: 6.w),
            AssetsGen.images.mine.mineLineBack.image(
              width: 16.w,
              height: 16.w,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _IdRow extends StatelessWidget {
  const _IdRow({required this.id, this.onCopy});

  final String id;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final sub = SettingCenterPage._subText;
    return InkWell(
      onTap: onCopy,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 17.w),
        child: Row(
          children: [
            Text(
              '萝幼院ID',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                id,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: sub,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            AssetsGen.images.mine.mineCopy.image(
              width: 16.w,
              height: 16.w,
            ),
          ],
        ),
      ),
    );
  }
}
