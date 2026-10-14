/// code : 200
/// data : {"list":["异族","妖精","巨乳","人妻","少女","后入","调教","萝莉"]}
/// hash : false
/// msg : "success"
/// time : "2022-07-01T03:59:03.089Z"
/// tip : ""

class SearchHotTags {
  SearchHotTags({
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

  SearchHotTags.fromJson(dynamic json) {
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

/// list : ["异族","妖精","巨乳","人妻","少女","后入","调教","萝莉"]

class Data {
  Data({
      List<String>? list,}){
    _list = list;
}

  Data.fromJson(dynamic json) {
    _list = json['list'] != null ? json['list'].cast<String>() : [];
  }
  List<String>? _list;

  List<String>? get list => _list;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['list'] = _list;
    return map;
  }

}