import 'package:comics_app/common/routers/app_navigator.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/history/history_operation.dart';
import 'package:comics_app/common/widgets/common_dialog/need_vip_dialog.dart';
import 'package:get/get.dart';

import '../../../../common/apis/circle_api.dart';
import '../../../../common/apis/media_api.dart';
import '../../../../common/entities/circle/posting_list_models.dart';
import '../../../../common/http/base_resp_bean.dart';
import '../../../../common/http/code.dart';
import '../../../../common/utils/logger.dart';
import '../../../../common/utils/toast_util.dart';
import 'post_details_state.dart';

/// 社区帖子详情页业务逻辑。
class PostDetailsLogic extends GetxController {
  final PostDetailsState state = PostDetailsState();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    state.postId = args is Map && args['postId'] != null
        ? int.parse('${args['postId']}')
        : 0;
  }

  @override
  void onReady() {
    super.onReady();
    _getPostDetails();
    _recordWatch();
  }

  /// 拉取帖子详情：复用 `posting/list` 的 `id` 单条查询能力（接口约定列表只有
  /// 一条），成功后顺手把作者的关注初值同步到 [PostDetailsState.isFollow]，
  /// 并写一条浏览记录。
  Future<void> _getPostDetails() async {
    final PostingListPage? page =
        await CircleApi.getPostingList(PostingListQuery(id: state.postId));
    state.postModel = page?.list.firstOrNull;
    state.isFollow = state.postModel?.account?.follow ?? false;
    state.isLike = state.postModel?.isPerfect ?? false;
    state.isCollect = state.postModel?.isCollect ?? false;
    update();
    _recordBrowseHistory();
  }

  void _recordWatch() async {
    bool isSuccess = await CircleApi.postWatch(state.postId);
    l.d('recordWatch: $isSuccess');
  }

  void _recordBrowseHistory() {
    HistoryOperation.getInstance()?.addPost(info: state.postModel);
  }

  @override
  void onClose() {
    state.scrollController.dispose();
    super.onClose();
  }

  /// 关注 / 取关：接口未就绪时仅在本地翻转 [PostDetailsState.isFollow] 并
  /// 通过 `update(['focus'])` 局部刷新关注按钮，避免整个 header 重建。
  void focus() async {
    if (state.postModel?.account?.id == null) return;
    bool isFollow = state.isFollow;
    BaseRespBean resp;
    if (isFollow) {
      resp = await MediaApi.onCancleFocus(state.postModel?.account?.id ?? 0);
    } else {
      resp = await MediaApi.onFocus(state.postModel?.account?.id ?? 0);
    }
    if (resp.isSuccess && Code.isDocSuccess(resp.bizCode)) {
      state.isFollow = !isFollow;
      state.postModel?.account?.follow = state.isFollow;
      update(['focus']);
    } else {
      showToast(msg: resp.tip ?? (isFollow ? '取消关注失败' : '关注失败'));
    }
  }

  /// 跳作者用户中心。等用户中心 pop 时把 payload 里的 `isFollow` 同步回来 ——
  /// 用户在用户中心点过关注/取关后，详情页本地的关注按钮也要跟随翻转，
  /// 否则两端会出现「中心显示已关注、详情仍是 + 关注」的对不上。
  ///
  /// 跳转参数沿用 user_center 入口约定（uid + author 子 map），与
  /// [post_card.dart] / [video_comment_item.dart] 等其它入口结构保持一致。
  Future<void> openAuthorCenter() async {
    final author = state.postModel?.account;
    final int uid = author?.id ?? 0;
    if (uid <= 0) return;
    final dynamic result = await AppNavigator.to.go(
      AppRoutes.USER_CENTER,
      arguments: <String, dynamic>{
        'uid': uid,
        'author': <String, dynamic>{
          'id': uid,
          'avatar': author?.avatar ?? '',
          'nickName': author?.nickName ?? '',
          'follow': author?.follow ?? false,
          'fansNum': author?.fansNum ?? 0,
          'vnum': author?.vnum ?? 0,
          'pnum': author?.pnum ?? 0,
        },
      },
    );
    _applyUserCenterPopResult(result);
  }

  /// 处理用户中心 pop 透传的 payload，仅在 `isFollow` 实际变化时刷新
  /// 本地态与关注按钮（id 为 `focus` 的 [GetBuilder]）。
  ///
  /// 兼容 user_center 侧 `buildPopResult` 的几种取值：bool / num / 字符串。
  /// 其它字段（如 `fansNum`）当前详情页 UI 不展示，暂不消费。
  void _applyUserCenterPopResult(dynamic result) {
    if (result is! Map) return;
    final m = Map<String, dynamic>.from(result);
    final dynamic raw = m['isFollow'];
    final bool? next = raw is bool
        ? raw
        : (raw is num
            ? raw != 0
            : (raw is String ? (raw == 'true' || raw == '1') : null));
    if (next == null || next == state.isFollow) return;
    state.isFollow = next;
    update(['focus']);
  }

  void onLike() async {
    if (state.postModel?.account?.id == null) return;
    bool isSuccess = await CircleApi.postLike(
        state.postModel?.id ?? 0, state.isLike ? 0 : 1);
    if (isSuccess) {
      state.isLike = !state.isLike;
      state.postModel?.isPerfect = state.isLike;
      state.postModel?.perfect = state.isLike
          ? (state.postModel?.perfect ?? 0) + 1
          : (state.postModel?.perfect ?? 0) - 1;
      update(['like']);
    }
  }

  void onCollect() async {
    if (state.postModel?.account?.id == null) return;
    bool isSuccess = await CircleApi.postCollection(
        [state.postModel?.id ?? 0], state.isCollect ? 0 : 1);
    if (isSuccess) {
      state.isCollect = !state.isCollect;
      update(['bottom_bar']);
    }
  }

  void onUnlock() async {
    BaseRespBean resp = await CircleApi.postUnlock(state.postModel?.id ?? 0);
    if (resp.isSuccess && Code.isDocSuccess(resp.bizCode)) {
      _getPostDetails();
      UserStore.to.refreshUser();
      update();
    } else if (resp.bizCode == Code.DOC_INSUFFICIENT_GOLD) {
      showNeedVipDialog(
        bodyLine1: '金币不足',
        bodyLine2: '请前往钱包充值',
        sureText: '立即充值',
        onOpenVip: () => Get.toNamed(AppRoutes.WALLET),
      );
    } else {
      showToast(msg: resp.tip ?? '解锁失败');
    }
  }

  void onSend(String result) async {
    final content = result.trim();
    if (content.isEmpty) {
      showToast(msg: '请输入评论内容');
      return;
    }
    bool isSuccess =
        await CircleApi.postCommentAdd(state.postModel?.id ?? 0, content);
    if (isSuccess) {
      showToast(msg: '发表成功');
    } else {
      showToast(msg: '发表失败');
    }
  }
}
