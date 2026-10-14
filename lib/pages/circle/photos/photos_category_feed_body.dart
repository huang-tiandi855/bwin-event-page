import 'package:comics_app/common/widgets/photo_card/photo_card.dart';
import 'package:comics_app/common/widgets/photos_style.dart';
import 'package:comics_app/pages/circle/common/circle_category_feed_header_slivers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 图集 · 二级 Tab 内滚动区：公共头 + 双列竖版封面网格。
class PhotosCategoryFeedBody extends StatefulWidget {
  const PhotosCategoryFeedBody({
    super.key,
    required this.pageStorageKey,
    this.scrollController,
  });

  final String pageStorageKey;
  final ScrollController? scrollController;

  @override
  State<PhotosCategoryFeedBody> createState() => _PhotosCategoryFeedBodyState();
}

class _PhotosCategoryFeedBodyState extends State<PhotosCategoryFeedBody> {
  int _sortIndex = 0;

  static const List<String> _sortLabels = ['最新', '最热', '精华'];

  static const List<PhotoCardData> _mockItems = [
    PhotoCardData(
      id: 'mock_photo_1',
      title: '高清写真合集示例标题略长展示两行省略',
      views: '3.6w',
      imgCount: '100',
    ),
    PhotoCardData(
      id: 'mock_photo_2',
      title: '夜景人像摄影作品占位文案',
      views: '1.2w',
      imgCount: '100',
    ),
    PhotoCardData(
      id: 'mock_photo_3',
      title: '室内光影组图预览标题',
      views: '8921',
      imgCount: '100',
    ),
    PhotoCardData(
      id: 'mock_photo_4',
      title: '春日外景九宫格示例',
      views: '6400',
      imgCount: '100',
    ),
    PhotoCardData(
      id: 'mock_photo_5',
      title: '黑白人像精选占位',
      views: '2.1w',
      imgCount: '100',
    ),
    PhotoCardData(
      id: 'mock_photo_6',
      title: '汉服外景组图预览文案',
      views: '9800',
      imgCount: '100',
    ),
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
        getPhotosFourGridStyle(
          items: _mockItems,
          onItemTap: (_, item) => jumpPhotoDetail(item.id),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 16.w)),
      ],
    );
  }
}
