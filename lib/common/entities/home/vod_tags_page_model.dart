import 'package:comics_app/common/entities/home/hot_tag_models.dart';

int? _vodTagsToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

bool? _vodTagsToBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase();
  if (s == 'true') return true;
  if (s == 'false') return false;
  return null;
}

List<int> _vodTagsToIntList(dynamic v) {
  if (v is! List) return const [];
  return v.map(_vodTagsToInt).whereType<int>().toList();
}

/// `cms/vod/recommendTags` 分页响应（PageHelper 结构）。
class VodTagsPageModel {
  const VodTagsPageModel({
    this.pageNum,
    this.pageSize,
    this.size,
    this.startRow,
    this.endRow,
    this.total,
    this.pages,
    this.list = const [],
    this.prePage,
    this.nextPage,
    this.isFirstPage,
    this.isLastPage,
    this.hasPreviousPage,
    this.hasNextPage,
    this.navigatePages,
    this.navigatepageNums = const [],
    this.navigateFirstPage,
    this.navigateLastPage,
    this.firstPage,
    this.lastPage,
  });

  factory VodTagsPageModel.fromJson(Map<String, dynamic> json) {
    final List<HotTagItemModel> tags = [];
    final rawList = json['list'];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map) {
          tags.add(HotTagItemModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return VodTagsPageModel(
      pageNum: _vodTagsToInt(json['pageNum']),
      pageSize: _vodTagsToInt(json['pageSize']),
      size: _vodTagsToInt(json['size']),
      startRow: _vodTagsToInt(json['startRow']),
      endRow: _vodTagsToInt(json['endRow']),
      total: _vodTagsToInt(json['total']),
      pages: _vodTagsToInt(json['pages']),
      list: tags,
      prePage: _vodTagsToInt(json['prePage']),
      nextPage: _vodTagsToInt(json['nextPage']),
      isFirstPage: _vodTagsToBool(json['isFirstPage']),
      isLastPage: _vodTagsToBool(json['isLastPage']),
      hasPreviousPage: _vodTagsToBool(json['hasPreviousPage']),
      hasNextPage: _vodTagsToBool(json['hasNextPage']),
      navigatePages: _vodTagsToInt(json['navigatePages']),
      navigatepageNums: _vodTagsToIntList(json['navigatepageNums']),
      navigateFirstPage: _vodTagsToInt(json['navigateFirstPage']),
      navigateLastPage: _vodTagsToInt(json['navigateLastPage']),
      firstPage: _vodTagsToInt(json['firstPage']),
      lastPage: _vodTagsToInt(json['lastPage']),
    );
  }

  static const VodTagsPageModel empty = VodTagsPageModel();

  final int? pageNum;
  final int? pageSize;
  final int? size;
  final int? startRow;
  final int? endRow;
  final int? total;
  final int? pages;
  final List<HotTagItemModel> list;
  final int? prePage;
  final int? nextPage;
  final bool? isFirstPage;
  final bool? isLastPage;
  final bool? hasPreviousPage;
  final bool? hasNextPage;
  final int? navigatePages;
  final List<int> navigatepageNums;
  final int? navigateFirstPage;
  final int? navigateLastPage;
  final int? firstPage;
  final int? lastPage;

  bool get hasMore => hasNextPage == true;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'pageNum': pageNum,
      'pageSize': pageSize,
      'size': size,
      'startRow': startRow,
      'endRow': endRow,
      'total': total,
      'pages': pages,
      'list': list.map((e) => e.toJson()).toList(),
      'prePage': prePage,
      'nextPage': nextPage,
      'isFirstPage': isFirstPage,
      'isLastPage': isLastPage,
      'hasPreviousPage': hasPreviousPage,
      'hasNextPage': hasNextPage,
      'navigatePages': navigatePages,
      'navigatepageNums': navigatepageNums,
      'navigateFirstPage': navigateFirstPage,
      'navigateLastPage': navigateLastPage,
      'firstPage': firstPage,
      'lastPage': lastPage,
    };
  }

  /// 解析接口 `data`（分页对象）。
  static VodTagsPageModel fromData(dynamic data) {
    if (data is Map) {
      return VodTagsPageModel.fromJson(Map<String, dynamic>.from(data));
    }
    return VodTagsPageModel.empty;
  }
}
