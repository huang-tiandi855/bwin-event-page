/// code : 200
/// data : {"list":[{"photoType":0,"price":0,"status":true,"sort":1,"url":"cf230705/image/2uf/1xb/1qd/1ba/56eaf2854447150786d87ffdcba69857.png","createdAt":"2024-08-14T04:09:02.498Z","isBuy":false},{"photoType":1,"price":10,"status":true,"sort":1,"url":"cf230705/image/2i/1di/2ta/fr/4c2eb429a4c69692c7a4677fc81a9a8c.jpg","createdAt":"2024-08-14T08:47:49.815Z","isBuy":false},{"photoType":0,"price":0,"status":true,"sort":0,"url":"cf230705/image/347/2el/163/23/d67dabea06f6a227a4c9a7f9b9a6f678.jpg","createdAt":"2024-08-14T08:48:14.447Z","isBuy":false},{"photoType":2,"price":20,"status":true,"sort":0,"url":"cf230705/image/1t5/31h/ub/10/e203aa739176660b2fc16ac3339e89e9.jpg","createdAt":"2024-08-14T08:48:35.136Z","isBuy":false},{"photoType":3,"price":0,"status":true,"sort":0,"url":"cf230705/image/1dd/1gc/29j/2gj/d703f15b564b0237f6af5aff4401f250.jpg","createdAt":"2024-08-14T08:48:52.367Z","isBuy":false},{"photoType":0,"price":0,"status":true,"sort":0,"url":"cf230705/image/1yg/2q3/s3/ml/816613486b7d9336856768fbdede482d.jpg","createdAt":"2024-08-14T08:49:27.868Z","isBuy":false}],"total":6}
/// hash : false
/// msg : "success"
/// time : "2024-08-20T09:01:34.666Z"
/// tip : ""

class AvatarBorder {
  AvatarBorder({
      int? code,
    AvatarBorderData? data,
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

  AvatarBorder.fromJson(dynamic json) {
    _code = json['code'];
    _data = json['data'] != null ? AvatarBorderData.fromJson(json['data']) : null;
    _hash = json['hash'];
    _msg = json['msg'];
    _time = json['time'];
    _tip = json['tip'];
  }
  int? _code;
  AvatarBorderData? _data;
  bool? _hash;
  String? _msg;
  String? _time;
  String? _tip;

  int? get code => _code;
  AvatarBorderData? get data => _data;
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

/// list : [{"photoType":0,"price":0,"status":true,"sort":1,"url":"cf230705/image/2uf/1xb/1qd/1ba/56eaf2854447150786d87ffdcba69857.png","createdAt":"2024-08-14T04:09:02.498Z","isBuy":false},{"photoType":1,"price":10,"status":true,"sort":1,"url":"cf230705/image/2i/1di/2ta/fr/4c2eb429a4c69692c7a4677fc81a9a8c.jpg","createdAt":"2024-08-14T08:47:49.815Z","isBuy":false},{"photoType":0,"price":0,"status":true,"sort":0,"url":"cf230705/image/347/2el/163/23/d67dabea06f6a227a4c9a7f9b9a6f678.jpg","createdAt":"2024-08-14T08:48:14.447Z","isBuy":false},{"photoType":2,"price":20,"status":true,"sort":0,"url":"cf230705/image/1t5/31h/ub/10/e203aa739176660b2fc16ac3339e89e9.jpg","createdAt":"2024-08-14T08:48:35.136Z","isBuy":false},{"photoType":3,"price":0,"status":true,"sort":0,"url":"cf230705/image/1dd/1gc/29j/2gj/d703f15b564b0237f6af5aff4401f250.jpg","createdAt":"2024-08-14T08:48:52.367Z","isBuy":false},{"photoType":0,"price":0,"status":true,"sort":0,"url":"cf230705/image/1yg/2q3/s3/ml/816613486b7d9336856768fbdede482d.jpg","createdAt":"2024-08-14T08:49:27.868Z","isBuy":false}]
/// total : 6

class AvatarBorderData {
  AvatarBorderData({
      List<AvatarBorderDataList>? list,
      int? total,}){
    _list = list;
    _total = total;
}

  AvatarBorderData.fromJson(dynamic json) {
    if (json['list'] != null) {
      _list = [];
      json['list'].forEach((v) {
        _list?.add(AvatarBorderDataList.fromJson(v));
      });
    }
    _total = json['total'];
  }
  List<AvatarBorderDataList>? _list;
  int? _total;

  List<AvatarBorderDataList>? get list => _list;
  int? get total => _total;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_list != null) {
      map['list'] = _list?.map((v) => v.toJson()).toList();
    }
    map['total'] = _total;
    return map;
  }

}

/// photoType : 0
/// price : 0
/// status : true
/// sort : 1
/// url : "cf230705/image/2uf/1xb/1qd/1ba/56eaf2854447150786d87ffdcba69857.png"
/// createdAt : "2024-08-14T04:09:02.498Z"
/// isBuy : false

class AvatarBorderDataList {
  AvatarBorderDataList({
      int? photoType, 
      int? price, 
      bool? status, 
      int? sort, 
      String? url, 
      String? createdAt, 
      bool? isBuy,String? id,}){
    _photoType = photoType;
    _price = price;
    _status = status;
    _sort = sort;
    _url = url;
    _createdAt = createdAt;
    _isBuy = isBuy;
    _id = id;
}

  AvatarBorderDataList.fromJson(dynamic json) {
    _photoType = json['photoType'];
    _price = json['price'];
    _status = json['status'];
    _sort = json['sort'];
    _url = json['url'];
    _createdAt = json['createdAt'];
    _isBuy = json['isBuy'];
    _id = json['id'];
  }
  int? _photoType;
  int? _price;
  bool? _status;
  int? _sort;
  String? _url;
  String? _createdAt;
  bool? _isBuy;
  String? _id;

  int? get photoType => _photoType;
  int? get price => _price;
  bool? get status => _status;
  int? get sort => _sort;
  String? get url => _url;
  String? get createdAt => _createdAt;
  bool get isBuy => _isBuy??false;
  String? get id => _id;


  set isBuy(bool value) {
    _isBuy = value;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['photoType'] = _photoType;
    map['price'] = _price;
    map['status'] = _status;
    map['sort'] = _sort;
    map['url'] = _url;
    map['createdAt'] = _createdAt;
    map['isBuy'] = _isBuy;
    map['id'] = _id;
    return map;
  }

}