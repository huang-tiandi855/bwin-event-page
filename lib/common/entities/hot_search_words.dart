/// code : 200
/// data : {"tags":["62ab3d8c7d8b495db8f70b32","62ab3f4caae377f930517622","62ab3fd2aae377f93051762b","62ab408eaae377f930517639","62ab41c1aae377f93051765a","62ab531e304d78481750259b"],"tagNames":["姐姐","妖精","巨乳","后宫","内射","韩漫"]}
/// hash : false
/// msg : "success"
/// time : "2022-07-20T12:41:26.967Z"
/// tip : ""

class HotSearchWords {
  HotSearchWords({
      int? code, 
      Data? data, 
      bool? hash, 
      String? msg, 
      String? time, 
      String? tip,}){
    _code = code;
    _data = data;
    _hash = hash;
    _msg = msg;
    _time = time;
    _tip = tip;
}

  HotSearchWords.fromJson(dynamic json) {
    _code = json['code'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _hash = json['hash'];
    _msg = json['msg'];
    _time = json['time'];
    _tip = json['tip'];
  }
  int? _code;
  Data? _data;
  bool? _hash;
  String? _msg;
  String? _time;
  String? _tip;

  int? get code => _code;
  Data? get data => _data;
  bool? get hash => _hash;
  String? get msg => _msg;
  String? get time => _time;
  String? get tip => _tip;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = _code;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    map['hash'] = _hash;
    map['msg'] = _msg;
    map['time'] = _time;
    map['tip'] = _tip;
    return map;
  }

}

/// tags : ["62ab3d8c7d8b495db8f70b32","62ab3f4caae377f930517622","62ab3fd2aae377f93051762b","62ab408eaae377f930517639","62ab41c1aae377f93051765a","62ab531e304d78481750259b"]
/// tagNames : ["姐姐","妖精","巨乳","后宫","内射","韩漫"]

class Data {
  Data({
      List<String>? tags, 
      List<String>? tagNames,List<int>? kinds,}){
    _tags = tags;
    _tagNames = tagNames;
    _kinds = kinds;
}

  Data.fromJson(dynamic json) {
    _tags = json['tags'] != null ? json['tags'].cast<String>() : [];
    _tagNames = json['tagNames'] != null ? json['tagNames'].cast<String>() : [];
    _kinds = json['kinds'] != null ? json['kinds'].cast<int>() : [];
  }
  List<String>? _tags;
  List<String>? _tagNames;
  List<int>? _kinds;

  List<String>? get tags => _tags;
  List<String>? get tagNames => _tagNames;
  List<int>? get kinds => _kinds;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['tags'] = _tags;
    map['tagNames'] = _tagNames;
    map['kinds'] = _kinds;
    return map;
  }

}