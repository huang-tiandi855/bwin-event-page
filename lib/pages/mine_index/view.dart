import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_icon_group.dart';
import 'package:comics_app/common/utils/ads_manage/getAdv.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:comics_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'logic.dart';

/// 底部留白：安全区 + 主导航，避免内容被遮挡
double _mineIndexBottomInset(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom + 26.w;

class MineIndexPage extends StatelessWidget {
  const MineIndexPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0C0B),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Builder(
        builder: (context) {
          final top = MediaQuery.paddingOf(context).top;
          final bottomPad = _mineIndexBottomInset(context);
          final logic = Get.find<MineIndexLogic>();

          // 只接管下拉刷新（[PullRefreshView.enablePullUp] = false）：
          // 「我的」页是单页静态信息，没有「下一页」语义，禁掉上拉加载，
          // 仅靠 [MineIndexLogic.refreshUserInfo] 刷新用户资料。
          return PullRefreshView(
            controller: logic.pullRefreshController,
            onRefresh: logic.refreshUserInfo,
            retryOnTap: logic.refreshUserInfo,
            enablePullUp: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: bottomPad),
              child: Stack(
                children: [
                  AssetsGen.images.mine.mineBg.image(
                    fit: BoxFit.fill,
                    alignment: Alignment.topCenter,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: top + 6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 顶栏：消息、设置、客服
                        const _TopActionsRow(),
                        SizedBox(height: 10.w),
                        // 用户信息：头像、昵称/VIP、ID 与复制、签到
                        _UserHeaderBlock(
                          onCopyId: () {
                            final id = UserStore.to.getUserInfoModel?.uid ?? 0;
                            if (id <= 0) {
                              showToast(msg: '暂无 ID');
                              return;
                            }
                            Clipboard.setData(
                                ClipboardData(text: id.toString()));
                            showToast(msg: '已复制');
                          },
                          onSignIn: () => Get.toNamed(AppRoutes.SIGNIN_WELFARE),
                        ),
                        SizedBox(height: 14.w),
                        Padding(
                          padding: EdgeInsets.only(left: 16.w, right: 16.w),
                          child: Column(
                            children: [
                              // VIP （倒计时、立即开通）
                              const _VipPromoBanner(),
                              SizedBox(height: 16.w),
                              // 观影券、AI 脱衣、AI 换脸
                              const _StatsRow(),
                              SizedBox(height: 16.w),
                              // 会员中心 + 金币钱包
                              const _MemberWalletRow(),
                              SizedBox(height: 16.w),
                              // 快捷入口：收藏、购买、关注、历史
                              const _QuickActionsCard(),
                              SizedBox(height: 16.w),
                              // 广告：我的页面 banner + icon 组合广告位
                              const AdsBannerIconGroup(
                                // bannerType: AdsType.bannerMy,
                                iconType: AdsType.dbLineHeadMy,
                              ),
                              SizedBox(height: 16.w),
                              // 功能宫格：创造中心、账号安全等
                              _MenuGridCard(
                                logic: logic,
                              ),
                              SizedBox(height: 16.w),
                              // 锁屏密码开关
                              const _LockPasswordRow(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopActionsRow extends StatelessWidget {
  const _TopActionsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
            onPressed: () => Get.toNamed(AppRoutes.MESSAGE_CENTER),
            icon: AssetsGen.images.mine.mineMessage.image(
              width: 24.w,
              height: 24.w,
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
            onPressed: () => Get.toNamed(AppRoutes.SETTING_CENTER),
            icon: AssetsGen.images.mine.mineSetting.image(
              width: 24.w,
              height: 24.w,
              fit: BoxFit.contain,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
            onPressed: () => Get.toNamed(AppRoutes.MINE_COMMON_PROBLEM),
            icon: AssetsGen.images.mine.mineTopServive.image(
              width: 24.w,
              height: 24.w,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserHeaderBlock extends StatelessWidget {
  const _UserHeaderBlock({
    required this.onCopyId,
    required this.onSignIn,
  });

  final VoidCallback onCopyId;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final u = UserStore.to.getUserInfoModel;
      final name = (u?.name?.isNotEmpty == true) ? u!.name! : '游客';
      final id = u?.uid ?? 0;
      final portrait = u?.avatarUrl;
      final vip = u?.isVip ?? false;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16.w),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.SETTING_CENTER),
            child: ClipOval(
              child: CustomImage(
                url: portrait ?? '',
                width: 62.w,
                height: 62.w,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(31.r),
              ),
            ),
          ),
          SizedBox(width: 22.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 21.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    if (vip)
                      AssetsGen.images.mine.mineVip.image(
                        width: 24.w,
                        height: 24.w,
                        fit: BoxFit.contain,
                      )
                    else
                      AssetsGen.images.mine.mineVipNone.image(
                        width: 24.w,
                        height: 24.w,
                        fit: BoxFit.contain,
                      )
                  ],
                ),
                SizedBox(height: 6.w),
                Row(
                  children: [
                    Text(
                      id <= 0 ? 'ID —' : 'ID $id',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    if (id > 0) ...[
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: onCopyId,
                        child: Text(
                          '复制',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 5.w),
          GestureDetector(
            onTap: onSignIn,
            child: AssetsGen.images.mine.mineSign.image(height: 32.w),
          ),
        ],
      );
    });
  }
}

class _VipPromoBanner extends StatelessWidget {
  const _VipPromoBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.MEMBER_CENTER),
      child: Stack(
        children: [
          Positioned.fill(
            child: AssetsGen.images.mine.mineVipBg.image(
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(
            height: 67.w,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  SizedBox(width: 50.w),
                  Expanded(
                    child: GetBuilder<MineIndexLogic>(
                        id: "timer",
                        builder: (MineIndexLogic logic) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    Color(0xffFCDEB5),
                                    Color(0xffFFF6E8),
                                    Color(0xffFECDA2),
                                  ],
                                ).createShader(Rect.fromLTRB(
                                        0, 0, bounds.width, bounds.height)),
                                child: Text(
                                  logic.state.isVip
                                      ? logic.state.vipName
                                      : logic.state.isNewUser
                                          ? '新人限时特惠 畅享全场'
                                          : '开通会员  享专属特权',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (logic.state.isNewUser ||
                                  logic.state.isVip) ...[
                                SizedBox(height: 4.w),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '倒计时 ',
                                      style: TextStyle(
                                          fontSize: 12.5.sp,
                                          color: Colors.white),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.w, vertical: 1.w),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff875417),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                      child: Text(
                                        logic.state.countdownText,
                                        style: TextStyle(
                                            fontSize: 12.5.sp,
                                            color: AppColor.primaryYellowColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ]
                            ],
                          );
                        }),
                  ),
                  GetBuilder<MineIndexLogic>(
                      id: 'timer',
                      builder: (logic) {
                        return logic.state.isVip
                            ? AssetsGen.images.mine.mineUpVip
                                .image(height: 30.w)
                            : AssetsGen.images.mine.mineOpenVip
                                .image(height: 30.w);
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final u = UserStore.to.getUserInfoModel;
      final ticket = u?.movieTickets ?? 0;
      final aiStrip = u?.aiUndressTimes ?? 0;
      final aiFace = u?.aiFaceSwapTimes ?? 0;

      Widget cell(String value, String label) => Expanded(
            child: Column(
              children: [
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.w),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.50),
                  ),
                ),
              ],
            ),
          );

      return Row(
        children: [
          cell('$ticket', '观影券'),
          _vDivider(),
          cell('$aiStrip', 'AI图文次数'),
          _vDivider(),
          cell('$aiFace', 'AI视频次数'),
        ],
      );
    });
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 18.w,
        color: Colors.white.withOpacity(0.3),
      );
}

class _MemberWalletRow extends StatelessWidget {
  const _MemberWalletRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.MEMBER_CENTER),
            child: AssetsGen.images.mine.mineVipCenter.image(),
          ),
        ),
        Expanded(
          child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.WALLET),
              child: AssetsGen.images.mine.mineWallet.image()),
        ),
      ],
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    final items = <_QuickItem>[
      _QuickItem(
        '我的收藏',
        AssetsGen.images.mine.mineCollection,
        () => Get.toNamed(AppRoutes.MINE_MY_COLLECTION),
      ),
      _QuickItem(
        '我的购买',
        AssetsGen.images.mine.mineBuy,
        () => Get.toNamed(AppRoutes.MINE_MY_PURCHASE),
      ),
      _QuickItem(
        '我的关注',
        AssetsGen.images.mine.mineFocusOn,
        () => Get.toNamed(AppRoutes.MINE_MY_FOLLOW),
      ),
      _QuickItem(
        '历史记录',
        AssetsGen.images.mine.mineHistory,
        () => Get.toNamed(AppRoutes.MINE_INDEX_HISTORY),
      ),
    ];

    return _CommonBgCard(
        child: Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: 4.w),
          Expanded(child: _QuickTile(item: items[i])),
        ],
      ],
    ));
  }
}

class _CommonBgCard extends StatelessWidget {
  const _CommonBgCard({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0x33B18552), Color(0x00B18552), Color(0x12B18552)]),
        borderRadius: BorderRadius.all(Radius.circular(10.r)),
      ),
      child: Container(
        padding: padding ?? EdgeInsets.symmetric(vertical: 16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF1A1814),
                Color(0xFF171411),
                Color(0xFF16120F)
              ]),
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
        ),
        child: child,
      ),
    );
  }
}

class _QuickItem {
  _QuickItem(this.label, this.asset, this.onTap);
  final String label;
  final AssetGenImage asset;
  final VoidCallback onTap;
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({required this.item});

  final _QuickItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          item.asset.image(width: 24.w, height: 24.w, fit: BoxFit.contain),
          SizedBox(height: 6.w),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MenuGridCard extends StatelessWidget {
  final MineIndexLogic logic;
  const _MenuGridCard({required this.logic});
  @override
  Widget build(BuildContext context) {
    final entries = <_MenuEntry>[
      _MenuEntry('创作中心', AssetsGen.images.mine.mineCreateCenter,
          () => Get.toNamed(AppRoutes.CREATE_CENTER)),
      _MenuEntry('账号安全', AssetsGen.images.mine.mineAccountSafe,
          () => Get.toNamed(AppRoutes.ACCOUNT_SAFE)),
      _MenuEntry('福利中心', AssetsGen.images.mine.mineWelfareCenter,
          () => Get.toNamed(AppRoutes.SIGNIN_WELFARE, arguments: {'index': 0})),
      _MenuEntry('意见反馈', AssetsGen.images.mine.mineFeedback,
          () => Get.toNamed(AppRoutes.FEEDBACK)),
      _MenuEntry(
        '我的喜欢',
        AssetsGen.images.mine.mineLike,
        () => Get.toNamed(AppRoutes.MINE_MY_LIKES),
      ),
      _MenuEntry('分享邀请', AssetsGen.images.mine.mineShare,
          () => Get.toNamed(AppRoutes.SHARE_INVITE)),
      _MenuEntry('领取兑换', AssetsGen.images.mine.mineExchange,
          () => Get.toNamed(AppRoutes.EXCHANGE_CODE)),
      _MenuEntry('加群开车', AssetsGen.images.mine.mineGroup,
          () => Get.toNamed(AppRoutes.GROUPS)),
      _MenuEntry('应用推荐', AssetsGen.images.mine.mineApplication,
          () => Get.toNamed(AppRoutes.SIGNIN_WELFARE, arguments: {'index': 2})),
      _MenuEntry(
        '账号凭证',
        AssetsGen.images.mine.mineAccountCredentials,
        () => Get.toNamed(AppRoutes.ACCOUNT_CREDENTIALS),
      ),
      _MenuEntry('在线客服', AssetsGen.images.mine.mineService,
          () => Get.toNamed(AppRoutes.MINE_COMMON_PROBLEM)),
      _MenuEntry('线路切换', AssetsGen.images.home.icPicLines,
          () => logic.showPictureLineSwitchSheet(context)),
    ];

    return _CommonBgCard(
      padding: EdgeInsets.fromLTRB(8.w, 21.w, 8.w, 21.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellW = constraints.maxWidth / 4;
          return Wrap(
            spacing: 0,
            runSpacing: 12.w,
            children: entries
                .map(
                  (e) => SizedBox(
                    width: cellW,
                    child: _MenuTile(entry: e),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class _MenuEntry {
  _MenuEntry(this.label, this.asset, this.onTap);
  final String label;
  final AssetGenImage asset;
  final VoidCallback onTap;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.entry});

  final _MenuEntry entry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: entry.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          entry.asset.image(width: 24.w, height: 24.w, fit: BoxFit.contain),
          SizedBox(height: 6.w),
          Text(
            entry.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _LockPasswordRow extends StatelessWidget {
  const _LockPasswordRow();

  @override
  Widget build(BuildContext context) {
    return _CommonBgCard(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.w),
      child: Row(
        children: [
          AssetsGen.images.mine.mineLock.image(
            width: 24.w,
            height: 24.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              '锁屏密码',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          GetBuilder<MineIndexLogic>(
              id: "lockScreenPassword",
              builder: (MineIndexLogic logic) {
                return InkWell(
                  onTap: () => logic.toggleLockScreenFromMine(),
                  child: Container(
                    width: 48.w,
                    height: 24.w,
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    alignment: logic.state.lockScreenPasswordOn
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: logic.state.lockScreenPasswordOn
                          ? AppColor.primaryButtonColor
                          : Colors.white.withOpacity(.3),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
