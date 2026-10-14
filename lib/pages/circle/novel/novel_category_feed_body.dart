import 'package:comics_app/common/widgets/novel_style.dart';
import 'package:comics_app/common/widgets/novel_card/novel_card.dart';
import 'package:comics_app/pages/circle/common/circle_category_feed_header_slivers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 小说 · 二级 Tab 内：公共头 + 三列封面列表。
class NovelCategoryFeedBody extends StatefulWidget {
  const NovelCategoryFeedBody({
    super.key,
    required this.pageStorageKey,
    this.scrollController,
  });

  final String pageStorageKey;
  final ScrollController? scrollController;

  @override
  State<NovelCategoryFeedBody> createState() => _NovelCategoryFeedBodyState();
}

class _NovelCategoryFeedBodyState extends State<NovelCategoryFeedBody> {
  int _sortIndex = 0;

  static const List<String> _sortLabels = ['最新', '最热', '最畅'];

  static const List<NovelCardData> _mockItems = [
    NovelCardData(id: 'mock_novel_1', title: '这是文案这是标题占位略长', meta: '共37话 · 连载中'),
    NovelCardData(id: 'mock_novel_2', title: '都市言情示例书名两行省略', meta: '共120话 · 已完结'),
    NovelCardData(id: 'mock_novel_3', title: '玄幻修仙占位', meta: '共24话 · 连载中'),
    NovelCardData(id: 'mock_novel_4', title: '有声剧原著示例', meta: '共16章 · 连载中'),
    NovelCardData(id: 'mock_novel_5', title: '短篇合集标题文案', meta: '共8话 · 已完结'),
    NovelCardData(id: 'mock_novel_6', title: '穿越重生类占位名', meta: '共56话 · 连载中'),
    NovelCardData(id: 'mock_novel_7', title: '悬疑推理示例', meta: '共42话 · 连载中'),
    NovelCardData(id: 'mock_novel_8', title: '校园甜宠占位', meta: '共18话 · 已完结'),
    NovelCardData(id: 'mock_novel_9', title: '科幻短篇示例文案', meta: '共9话 · 已完结'),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: PageStorageKey<String>(widget.pageStorageKey),
      controller: widget.scrollController,
      slivers: [
        ...CircleCategoryFeedHeaderSlivers.build(
          featuredCards: null,
          sortLabels: _sortLabels,
          selectedSortIndex: _sortIndex,
          onSortSelected: (i) => setState(() => _sortIndex = i),
        ),
        getNovelSixGridStyle(
          items: _mockItems,
          onItemTap: (_, item) => jumpNovelDetail(item.id),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 16.w)),
      ],
    );
  }
}
