import 'package:comics_app/common/widgets/community_style.dart';
import 'package:comics_app/common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'post_search_result_logic.dart';

class PostSearchResultPage extends StatefulWidget {
  const PostSearchResultPage({super.key, this.index = 0, this.keyWord});

  final int index;
  final String? keyWord;

  @override
  State<PostSearchResultPage> createState() => _PostSearchResultPageState();
}

class _PostSearchResultPageState extends State<PostSearchResultPage> {
  late final PostSearchResultLogic logic;
  late final String _logicTag;

  @override
  void initState() {
    super.initState();
    _logicTag = 'post_search_${widget.index}';
    // 防御性清理：同 tag 残留实例会被 `Get.put` 复用，导致新关键字搜不出来。
    // 这里先强制删除再注册一份新的，确保拿到最新初始关键字。
    if (Get.isRegistered<PostSearchResultLogic>(tag: _logicTag)) {
      Get.delete<PostSearchResultLogic>(tag: _logicTag, force: true);
    }
    logic = Get.put(
      PostSearchResultLogic(index: widget.index),
      tag: _logicTag,
    );
  }

  @override
  void didUpdateWidget(covariant PostSearchResultPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyWord != widget.keyWord) {
      logic.updateKeyword(widget.keyWord);
    }
  }

  @override
  void dispose() {
    Get.delete<PostSearchResultLogic>(tag: _logicTag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostSearchResultLogic>(
      tag: _logicTag,
      builder: (_) {
        final state = logic.state;
        return PullRefreshView(
          controller: state.pullRefreshController,
          onRefresh: logic.onRefresh,
          onLoading: logic.onLoadMore,
          retryOnTap: logic.onRefresh,
          emptyText: '暂无相关结果',
          child: getPostListStyle(
            items: state.postCardList,
            isSliver: false,
          ),
        );
      },
    );
  }
}
