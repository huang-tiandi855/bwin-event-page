import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/utils/toast_util.dart';
import '../search_page_logic.dart';
import 'search_result_state.dart';

class SearchResultLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  SearchResultLogic({
    String? initialKeyword,
    TextEditingController? textEditingController,
  }) : state = SearchResultState(
          initialKeyword: initialKeyword,
          textEditingController: textEditingController,
        );

  final SearchResultState state;
  int _lastKindIndex = 0;

  @override
  void onInit() {
    super.onInit();
    _lastKindIndex = state.selectedKindIndex;
    state.tabController = TabController(
      length: state.tabs.length,
      vsync: this,
      initialIndex: state.selectedKindIndex,
    )..addListener(_handleKindTabChanged);
    searchResult(state.keyWord);
  }

  @override
  void onClose() {
    state.tabController.removeListener(_handleKindTabChanged);
    state.tabController.dispose();
    super.onClose();
  }

  void _handleKindTabChanged() {
    if (state.tabController.indexIsChanging) return;
    final index = state.tabController.index;
    if (index == _lastKindIndex) return;
    _lastKindIndex = index;
    selectKind(index);
  }

  void clear() {
    state.textEditingController.clear();
    update();
  }

  Future<void> searchResult(String? keyWord) async {
    final text = keyWord?.trim() ?? '';
    if (text.isEmpty) {
      showToast(msg: "请输入要搜索的内容");
      return;
    }
    state.keyWord = text;
    state.textEditingController.text = text;
    update();
  }

  Future<void> onSearch([text]) async {
    text ??= state.textEditingController.text;
    if (text.toString().trim().isEmpty) {
      showToast(msg: "请输入要搜索的内容");
    } else {
      if (Get.isRegistered<SearchPageLogic>()) {
        Get.find<SearchPageLogic>().state.saveKeywords(text);
      }
      await searchResult(text);
    }
  }

  Future<void> selectKind(int index) async {
    if (state.selectedKindIndex == index) return;
    state.selectedKindIndex = index;
    _lastKindIndex = index;
    update();
  }
}
