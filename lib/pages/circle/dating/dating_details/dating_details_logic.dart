import 'package:comics_app/common/apis/dating_api.dart';
import 'package:comics_app/common/entities/circle/dating_models.dart';
import 'package:comics_app/common/http/code.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/common_dialog/need_vip_dialog.dart';
import 'package:comics_app/pages/circle/dating/dating_details/dating_details_state.dart';
import 'package:comics_app/pages/circle/dating/dating_details/dating_insufficient_gold_dialog.dart';
import 'package:comics_app/pages/circle/dating/dating_details/dating_report_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DatingDetailsLogic extends GetxController {
  final DatingDetailsState state = DatingDetailsState();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    state.datingId = args is Map && args['datingId'] != null
        ? int.tryParse('${args['datingId']}') ?? 0
        : 0;
    _loadDetail();
    _loadReportTypes();
  }

  @override
  void onClose() {
    state.scrollController.dispose();
    state.relatedPullController.dispose();
    super.onClose();
  }

  Future<void> _loadReportTypes() async {
    final types = await DatingApi.getReportTypes();
    if (isClosed || types == null) return;
    state.reportTypes = types;
  }

  Future<void> _loadDetail() async {
    if (state.datingId <= 0) {
      state.loading = false;
      state.loadFailed = true;
      update();
      return;
    }
    state.loading = true;
    state.loadFailed = false;
    update();

    final vo = await DatingApi.getDetail(state.datingId);
    if (isClosed) return;

    if (vo == null) {
      state.loading = false;
      state.loadFailed = true;
      update();
      return;
    }

    state.card = vo;
    state.loading = false;
    update();
    _loadRelated(vo);
  }

  Future<void> _loadRelated(DatingCardModel vo) async {
    state.relatedPage = 1;
    state.relatedHasMore = true;
    state.relatedCards = const <DatingCardModel>[];
    state.relatedPullController.requesting();
    await loadRelatedPage(refresh: true, seed: vo);
  }

  Future<void> loadRelatedPage({
    required bool refresh,
    DatingCardModel? seed,
  }) async {
    final card = seed ?? state.card;
    if (card == null) return;
    final page = refresh ? 1 : state.relatedPage + 1;
    final provinceId =
        card.cities.isNotEmpty ? card.cities.first.provinceId : null;
    final result = await DatingApi.getList(
      DatingListQuery(
        page: page,
        pageSize: DatingDetailsState.relatedPageSize,
        type: card.type,
        provinceId: provinceId,
        sortType: DatingSortType.latest,
      ),
    );
    if (isClosed) return;

    if (result == null) {
      state.relatedPullController.requestFail(isFirstPageNum: refresh);
      update(['related']);
      return;
    }

    final chunk = result.list.where((e) => e.id != state.datingId).toList();
    state.relatedCards = refresh
        ? chunk
        : (List<DatingCardModel>.from(state.relatedCards)..addAll(chunk));
    state.relatedPage = page;
    state.relatedHasMore = result.hasNextPage;
    state.relatedPullController.requestSuccess(
      isFirstPageNum: refresh,
      hasMore: state.relatedHasMore,
      isEmpty: state.relatedCards.isEmpty,
    );
    update(['related']);
  }

  Future<void> openRelated(DatingCardModel item) async {
    if (item.id <= 0 || item.id == state.datingId) return;
    state.datingId = item.id;
    state.card = null;
    state.relatedCards = const <DatingCardModel>[];
    if (state.scrollController.hasClients) {
      state.scrollController.jumpTo(0);
    }
    await _loadDetail();
  }

  bool get _isLoggedIn {
    final token = UserStore.to.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> onVipUnlockTap() async {
    final card = state.card;
    if (card == null || card.unlocked) return;
    if (!_isLoggedIn) {
      showToast(msg: '请先登录');
      return;
    }
    if (!card.canVipUnlock) {
      await _showNeedDatingVipDialog(card);
      return;
    }
    await _requestUnlock(DatingUnlockType.vip);
  }

  Future<void> onGoldUnlockTap() async {
    final card = state.card;
    if (card == null || card.unlocked) return;
    if (!_isLoggedIn) {
      showToast(msg: '请先登录');
      return;
    }
    if (card.gold <= 0) {
      showToast(msg: '暂不支持金币解锁');
      return;
    }
    final balance = UserStore.to.getUserInfoModel?.walletApp ?? 0;
    if (balance < card.gold) {
      await _showInsufficientGoldDialog(
        requiredGold: card.gold,
        currentBalance: balance,
      );
      return;
    }
    await _requestUnlock(DatingUnlockType.gold);
  }

  Future<void> _requestUnlock(DatingUnlockType unlockType) async {
    final resp = await DatingApi.unlock(
      id: state.datingId,
      unlockType: unlockType,
    );
    if (isClosed) return;

    if (resp.isSuccess && Code.isDocSuccess(resp.bizCode)) {
      final refreshed = DatingCardModel.fromAny(resp.result);
      if (refreshed != null) {
        state.card = refreshed;
      } else {
        state.card?.unlocked = true;
        state.card?.needPay = false;
      }
      UserStore.to.refreshUser();
      showToast(msg: '解锁成功');
      update();
      return;
    }

    if (resp.bizCode == Code.DOC_INSUFFICIENT_GOLD) {
      await UserStore.to.refreshUser();
      final card = state.card;
      final requiredGold = card?.gold ?? 0;
      final balance = UserStore.to.getUserInfoModel?.walletApp ?? 0;
      await _showInsufficientGoldDialog(
        requiredGold: requiredGold,
        currentBalance: balance,
      );
      return;
    }

    if (resp.bizCode == Code.DOC_NEED_VIP_FOR_FEATURES) {
      final c = state.card;
      if (c != null) {
        await _showNeedDatingVipDialog(c);
      } else {
        showToast(msg: resp.msg ?? resp.tip ?? '请开通对应 VIP 权限');
      }
      return;
    }

    if (resp.bizCode == Code.DOC_PARAM_ERROR) {
      showToast(msg: resp.msg ?? resp.tip ?? '暂不支持该解锁方式');
      return;
    }

    if (resp.bizCode == Code.DOC_TRY_AGAIN_LATER) {
      showToast(msg: resp.msg ?? resp.tip ?? '请稍后再试');
      return;
    }

    if (resp.bizCode == Code.DOC_UNAUTHORIZED) {
      showToast(msg: '请先登录');
      return;
    }

    showToast(msg: resp.msg ?? resp.tip ?? '解锁失败');
  }

  Future<void> _showNeedDatingVipDialog(DatingCardModel card) {
    return showNeedVipDialog(
      bodyLine1: "开通VIP会员",
      bodyLine2: '即可查看联系方式',
      sureText: '开通会员',
      onOpenVip: () => Get.toNamed(AppRoutes.MEMBER_CENTER),
    );
  }

  Future<void> _showInsufficientGoldDialog({
    required int requiredGold,
    required int currentBalance,
  }) {
    return showDatingInsufficientGoldDialog(
      requiredGold: requiredGold,
      currentBalance: currentBalance,
      onGetGold: () => Get.toNamed(AppRoutes.WALLET),
    );
  }

  Future<void> copyContact(String value) async {
    if (value.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    showToast(msg: '已复制');
  }

  Future<void> onReportTap(BuildContext context) async {
    if (!_isLoggedIn) {
      showToast(msg: '请先登录');
      return;
    }
    if (state.reportTypes.isEmpty) {
      showToast(msg: '举报类型加载中');
      return;
    }
    final result = await showDatingReportSheet(
      context,
      types: state.reportTypes,
    );
    if (result == null || isClosed) return;
    final resp = await DatingApi.report(
      id: state.datingId,
      type: result.type,
      content: result.content,
    );
    if (resp.isSuccess && Code.isDocSuccess(resp.bizCode)) {
      showToast(msg: '举报已提交');
      return;
    }
    if (resp.bizCode == Code.DOC_PARAM_ERROR) {
      showToast(msg: resp.msg ?? resp.tip ?? '举报类型无效');
      return;
    }
    if (resp.bizCode == Code.DOC_UNAUTHORIZED) {
      showToast(msg: '请先登录');
      return;
    }
    showToast(msg: resp.msg ?? resp.tip ?? '提交失败');
  }

  Future<void> onSwiperNext() async {
    state.swiperController.stopAutoplay();
    await state.swiperController.next();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (isClosed) return;
      state.swiperController.startAutoplay();
    });
  }

  Future<void> onSwiperPrevious() async {
    state.swiperController.stopAutoplay();
    await state.swiperController.previous();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (isClosed) return;
      state.swiperController.startAutoplay();
    });
  }

  void onSwiperIndexChanged(int index) {
    if (isClosed) return;
    state.selectedImageIndex = index;
    update(['gallery', 'swiperIndex']);
  }
}
