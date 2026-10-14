abstract class IPagination<T> {
  final bool hasNext;
  final List<T> list;

  int get count => list.length;

  bool get isEmpty {
    return list.isEmpty;
  }

  const IPagination({
    this.hasNext = false,
    this.list = const [],
  });
}

class PaginationModel<T> extends IPagination<T> {
  PaginationModel({
    super.hasNext,
    super.list,
  });

  factory PaginationModel.fromJson({
    required T Function(Map<String, dynamic>) itemFactory,
    required Map<String, dynamic> json,
  }) {
    return PaginationModel(
      hasNext: json['hasNext'] as bool? ?? false,
      list: (json['list'] as List<dynamic>?)?.map((e) => itemFactory(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  factory PaginationModel.fromJsonCustomize({
    required T Function(Map<String, dynamic>) itemFactory,
    required Map<String, dynamic> json,
    required String key,
  }) {
    return PaginationModel(
      hasNext: json['hasNext'] as bool? ?? false,
      list: (json[key] as List<dynamic>?)?.map((e) => itemFactory(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  PaginationModel<T> apply(PaginationModel<T> other) {
    return PaginationModel(
      hasNext: other.hasNext,
      list: [...list, ...other.list],
    );
  }

  PaginationModel<T> copyWith({
    List<T>? list,
    bool? hasNext,
  }) {
    return PaginationModel(
      hasNext: hasNext ?? this.hasNext,
      list: list ?? this.list,
    );
  }
}
