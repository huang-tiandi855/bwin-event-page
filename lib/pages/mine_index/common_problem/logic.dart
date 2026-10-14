import 'package:comics_app/common/apis/mine_apis.dart';
import 'package:comics_app/common/entities/mine/question_tree_model.dart';
import 'package:comics_app/common/routers/app_navigator.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'state.dart';

class CommonProblemLogic extends GetxController {
  final state = CommonProblemState();

  /// 当前选中分类；分类未加载时返回 null，view 层据此显示加载/空态。
  QuestionTreeModel? get currentCategory {
    if (state.categories.isEmpty) return null;
    final index = state.currentTab.clamp(0, state.categories.length - 1);
    return state.categories[index];
  }

  @override
  void onInit() {
    super.onInit();
    fetchQuestionTree();
  }

  /// 拉取 `chat/question/tree`，直接使用 [QuestionTreeModel] 填充状态。
  Future<void> fetchQuestionTree() async {
    state.loading = true;
    update();
    try {
      final nodes = await MineApis.getQuestionTree();
      state.categories = nodes;
      if (state.categories.isEmpty) {
        state.currentTab = 0;
      } else {
        state.currentTab =
            state.currentTab.clamp(0, state.categories.length - 1);
      }
    } catch (e, st) {
      debugPrint('common problem fetchQuestionTree error: $e\n$st');
      state.categories = <QuestionTreeModel>[];
    } finally {
      state.loading = false;
      update();
    }
  }

  /// 切换分类（保留已有聊天记录）
  void switchTab(int index) {
    if (index < 0 || index >= state.categories.length) return;
    if (state.currentTab == index) return;
    state.currentTab = index;
    update();
  }

  /// 点击某条问答：追加 用户气泡 + 客服气泡
  void onQuestionTap(QuestionTreeModel qa) {
    state.messages
      ..add(CommonProblemChatItem.user(qa.question ?? ''))
      ..add(CommonProblemChatItem.bot(qa));
    update();
  }

  /// 召唤 / 人工客服
  void goCustomerService() {
    AppNavigator.to.commonToCustomerService();
  }
}
