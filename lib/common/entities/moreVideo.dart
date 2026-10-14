import '../values/enum.dart';

class MoreVideo {
  int? pageNumber;
  int? pageSize;
  String? tagId;
  MoreVideoType? type;

  MoreVideo({
    this.pageNumber,
    this.pageSize,
    this.type,
    this.tagId,
  }) {
    pageNumber = pageNumber;
    pageNumber = pageNumber;
    type = type;
    tagId = tagId;
  }

  MoreVideo.fromJson(dynamic json) {
    pageNumber = json['page'];
    pageSize = json['pageSize'];
    type = json['type'];
    tagId = json['tagId'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['page'] = pageNumber;
    map['pageSize'] = pageSize;
    map['type'] = type;
    map['tagId'] = tagId;
    return map;
  }
}
