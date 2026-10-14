import 'package:comics_app/common/apis/signin_apis.dart';
import 'package:comics_app/common/entities/sign_in/points_exchange_entity.dart';
import 'package:comics_app/common/entities/sign_in/sign_in_overview_entity.dart';
import 'package:comics_app/common/entities/sign_in/welfare_task_entity.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/utils/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'state.dart';

class SigninLogic extends GetxController {
  final SigninState state = SigninState();

  /// SigninPage 外层 [SingleChildScrollView] 的 ScrollController。
  ///
  /// 暴露在 logic 上的目的：让外链跳转 / 任务回跳等场景能调用
  /// [consumePendingAnchor] 走 [Scrollable.ensureVisible] 把整页滚到
  /// 「福利任务 / 积分兑换」区域，而不必让 view 持有任何状态。
  final ScrollController contentScrollController = ScrollController();

  /// 标记「福利任务 / 积分兑换」整块（`_WelfarePointsBlock`）位置的
  /// GlobalKey，配合 [Scrollable.ensureVisible] 实现 anchor 滚动定位。
  final GlobalKey welfareSectionKey =
      GlobalKey(debugLabel: 'SigninWelfareSection');

  /// 来自路由 arguments 的 `welfareAnchor`（`task` / `reward`），由外链
  /// `proxinner://signin_welfare_task` / `proxinner://signin_welfare_reward`
  /// 在 [AppNavigator] 跳转时透传。SigninPage 首帧建完后通过
  /// [consumePendingAnchor] 消费一次。
  String? _pendingAnchor;

  bool get hasPendingAnchor => _pendingAnchor != null;

  bool _signInBusy = false;
  bool _exchangeBusy = false;

  static String _signInResultMessage(BaseRespBean bean) {
    final String s = (bean.tip ?? bean.msg ?? '').trim();
    if (bean.isSuccess) {
      return '签到成功';
    }
    return s.isNotEmpty ? s : '签到失败';
  }

  @override
  void onInit() {
    super.onInit();
    _readAnchorFromArguments();
    _syncUserFromStore();
    getSignInData();
    getTaskList();
    getExchangeList();
  }

  @override
  void onClose() {
    contentScrollController.dispose();
    super.onClose();
  }

  /// 从当前路由 arguments 解析 `welfareAnchor`：与
  /// [SigninWelfareState] 读 `index` 同源，每次 SIGNIN_WELFARE 路由 push
  /// 都会重建 [SigninLogic]，故在 [onInit] 取一次即可。
  void _readAnchorFromArguments() {
    final dynamic arg = Get.arguments;
    if (arg is Map) {
      final String? a = arg['welfareAnchor']?.toString().trim();
      if (a != null && a.isNotEmpty) {
        _pendingAnchor = a;
      }
    }
  }

  /// 由 [SigninPage] 在首帧 addPostFrameCallback 中调用一次：把
  /// `welfareAnchor` 翻译成 segment（`task`→0，`reward`→1），切到对应
  /// segment，再下一帧用 [welfareSectionKey] 滚到目标区域。
  ///
  /// 每次进入页面只消费一次：第一行就置空 [_pendingAnchor]，重复 build
  /// 不会再触发滚动，安全可重入。
  void consumePendingAnchor() {
    final String? anchor = _pendingAnchor;
    if (anchor == null || anchor.isEmpty) return;
    _pendingAnchor = null;
    final int segment;
    switch (anchor) {
      case 'task':
        segment = 0;
        break;
      case 'reward':
        segment = 1;
        break;
      default:
        return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setWelfareSegment(segment);
      // 等 setWelfareSegment 触发的 GetBuilder 重建完成后，下一帧再
      // ensureVisible，否则 welfareSectionKey 对应的 RenderBox 还可能
      // 是旧 segment 的高度，定位会偏。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final BuildContext? ctx = welfareSectionKey.currentContext;
        if (ctx == null) return;
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      });
    });
  }

  void _syncUserFromStore() {
    final u = UserStore.to.getUserInfoModel;
    if (u == null) {
      return;
    }
    state.userName =
        (u.name?.trim().isNotEmpty == true) ? u.name!.trim() : '用户';
    state.userPortrait =
        u.avatarUrl?.trim().isNotEmpty == true ? u.avatarUrl : null;
    state.viewCount = u.maxFreeUserPlay ?? 0;
  }

  Future<void> getSignInData() async {
    try {
      state.overview = await SignInApis.getSignInData();
    } finally {
      update();
    }
  }

  Future<void> getExchangeList() async {
    try {
      state.exchangeItems = await SignInApis.getPointsExchangeList();
    } finally {
      update();
    }
  }

  Future<void> getTaskList() async {
    try {
      state.welfareCenter = await SignInApis.getWelfaretaskList();
    } finally {
      update();
    }
  }

  void onTapWelfareTask(WelfareTaskItemModel task) {
    final String url = task.jumpUrl?.trim() ?? '';
    // const String url = 'proxinner://customer_service';
    if (url.isEmpty) {
      showToast(msg: '敬请期待');
      return;
    }
    AppNavigator.to.jumpUrl(url: url);
  }

  void setWelfareSegment(int index) {
    if (index == state.welfareSegment) return;
    if (index < 0 || index > 1) return;
    state.welfareSegment = index;
    update();
  }

  void openSignRecordPage({required bool member}) {
    Get.toNamed(
      AppRoutes.SIGNIN_RECORDS,
      arguments: <String, dynamic>{
        'initialIndex': member ? 1 : 0,
      },
    );
  }

  void openExchangeRecordPage() {
    Get.toNamed(
      AppRoutes.SIGNIN_EXCHANGE_RECORDS,
      arguments: <String, dynamic>{
        'currentPoints': state.myPoints,
      },
    );
  }

  Future<void> onTapExchangeReward(PointsExchangeProductModel product) async {
    if (_exchangeBusy) {
      return;
    }
    final int? productId = product.id;
    if (productId == null) {
      showToast(msg: '奖品信息异常');
      return;
    }
    if ((product.costPoints ?? 0) > state.myPoints) {
      return showToast(msg: '积分不足，兑换失败');
    }
    _exchangeBusy = true;
    update();
    try {
      final String idempotencyKey = await SignInApis.getPointsExchangeKey();
      if (idempotencyKey.isEmpty) {
        showToast(msg: '获取兑换凭证失败，请稍后重试');
        return;
      }
      final BaseRespBean bean = await SignInApis.exchangeRewardByKeyId(
        productId: productId,
        idempotencyKey: idempotencyKey,
      );

      showToast(
        msg: bean.isSuccess ? '兑换成功' : '兑换失败',
      );
      if (bean.isSuccess) {
        // 兑换成功后需要同时刷新两块：
        // 1. [getExchangeList]：商品列表（库存 / 上下架可能随兑换变化）；
        // 2. [getTaskList]：用户积分 [state.myPoints] —— 头部展示的积分数
        //    来源就是任务接口而不是兑换接口，光刷兑换列表会留着旧积分。
        // 两个接口互不依赖，并行节省一次往返时间。
        await Future.wait<void>([
          getExchangeList(),
          getTaskList(),
          getSignInData(),
          UserStore.to.refreshUser(),
        ]);
      }
    } catch (_) {
      showToast(msg: '网络异常，请稍后重试');
    } finally {
      _exchangeBusy = false;
      update();
    }
  }

  /// 免费日签
  Future<void> onTapSignIn() async {
    if (_signInBusy) {
      return;
    }
    final SignInChannelOverviewModel? free = state.overview?.free;
    if (free?.eligible == false) {
      showToast(msg: '当前无法签到');
      return;
    }
    if (free?.signedToday == true) {
      showToast(msg: '今日已签到');
      return;
    }
    _signInBusy = true;
    update();
    try {
      final BaseRespBean bean = await SignInApis.clickFreeSignIn();
      showToast(msg: _signInResultMessage(bean));
      if (bean.isSuccess) {
        await getSignInData();
        await getTaskList();
      }
    } catch (_) {
      showToast(msg: '网络异常，请稍后重试');
    } finally {
      _signInBusy = false;
      update();
    }
  }

  /// 会员专属签到（`activation/signin/v2/vip`） —— 对应「会员专属」卡片
  /// （[_MemberExclusiveCard]），与「连续打卡」里的会员行（[o.member]）
  /// **不是同一通道**：
  ///
  /// - 「连续打卡 → 会员行」 → [SignInOverviewResultModel.member]
  /// - 「会员专属」整张卡 → [SignInOverviewResultModel.vipExclusive] ✅ 本入口
  ///
  /// 历史实现错读了 [member]，导致用户在连续打卡里完成会员签到后，会员
  /// 专属那张卡也被误判成「今日已签到」，按钮失效。这里改回正确的
  /// [vipExclusive]，两套签到状态相互独立。
  Future<void> onTapVipSignIn() async {
    if (_signInBusy) {
      return;
    }
    if (state.overview?.vip != true) {
      showToast(msg: '开通会员后可参与会员签到');
      return;
    }
    final SignInChannelOverviewModel? vipExclusive =
        state.overview?.vipExclusive;
    if (vipExclusive?.eligible == false) {
      showToast(msg: '当前无法签到');
      return;
    }
    if (vipExclusive?.signedToday == true) {
      showToast(msg: '今日已签到');
      return;
    }
    _signInBusy = true;
    update();
    try {
      final BaseRespBean bean = await SignInApis.clickVipSignIn();
      showToast(msg: _signInResultMessage(bean));
      if (bean.isSuccess) {
        await getSignInData();
      }
    } catch (_) {
      showToast(msg: '网络异常，请稍后重试');
    } finally {
      _signInBusy = false;
      update();
    }
  }

  void onTapVip() {
    AppNavigator.to.go(AppRoutes.MEMBER_CENTER);
  }
}
