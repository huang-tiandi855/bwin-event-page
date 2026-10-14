/// announcement : [{"id":"62eb833da896f01ad1c1f9ad","content":"新人年卡特惠限时抢购！ 24小时限时特价100元即可365天全年畅游全站vip动漫/漫画。","position":1,"positionDesc":"1","createdAt":"2022-08-04T16:28:45.52+08:00"}]

class AnnounceMent {
  AnnounceMent({
      List<Announcement>? announcement,}){
    _announcement = announcement;
}

  AnnounceMent.fromJson(dynamic json) {
    if (json['announcement'] != null) {
      _announcement = [];
      json['announcement'].forEach((v) {
        _announcement?.add(Announcement.fromJson(v));
      });
    }
  }
  List<Announcement>? _announcement;

  List<Announcement>? get announcement => _announcement;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_announcement != null) {
      map['announcement'] = _announcement?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : "62eb833da896f01ad1c1f9ad"
/// content : "新人年卡特惠限时抢购！ 24小时限时特价100元即可365天全年畅游全站vip动漫/漫画。"
/// position : 1
/// positionDesc : "1"
/// createdAt : "2022-08-04T16:28:45.52+08:00"

class Announcement {
  Announcement({
      String? id, 
      String? content, 
      int? position, 
      String? positionDesc, 
      String? link,
      String? createdAt,}){
    _id = id;
    _content = content;
    _position = position;
    _positionDesc = positionDesc;
    _link = link;
    _createdAt = createdAt;
}

  Announcement.fromJson(dynamic json) {
    _id = json['id'];
    _content = json['content'];
    _position = json['position'];
    _link = json['link'];
    _positionDesc = json['positionDesc'];
    _createdAt = json['createdAt'];
  }
  String? _id;
  String? _content;
  int? _position;
  String? _positionDesc;
  String? _createdAt;
  String? _link;

  String? get id => _id;
  String? get content => _content;
  int? get position => _position;
  String? get positionDesc => _positionDesc;
  String? get createdAt => _createdAt;
  String? get link => _link;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['content'] = _content;
    map['position'] = _position;
    map['positionDesc'] = _positionDesc;
    map['createdAt'] = _createdAt;
    map['link'] = _link;
    return map;
  }

}