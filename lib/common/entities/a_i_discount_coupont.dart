/// code : 200
/// data : {"list":[{"id":"66c5b585491faef8de2b7e09","uid":224411,"goodsName":"AI视频脸抵扣券","goodsType":4,"goodsValue":250,"goodsOrigin":"积分兑换","goodsDesc":"AI视频脸抵扣券(250金豆)\n","status":2,"expiredTime":"2024-09-20T09:38:13.57Z","useTime":"0001-01-01T00:00:00Z","createTimt":"2024-08-21T09:38:13.57Z"},{"id":"66c5b625491faef8de2b7e1c","uid":224411,"goodsName":"AI视频脸抵扣券","goodsType":4,"goodsValue":400,"goodsOrigin":"积分兑换","goodsDesc":"AI视频脸抵扣券(400金豆)","status":2,"expiredTime":"2024-11-19T09:40:53.618Z","useTime":"0001-01-01T00:00:00Z","createTimt":"2024-08-21T09:40:53.618Z"},{"id":"66c5b626491faef8de2b7e20","uid":224411,"goodsName":"AI视频脸抵扣券","goodsType":4,"goodsValue":400,"goodsOrigin":"积分兑换","goodsDesc":"AI视频脸抵扣券(400金豆)","status":2,"expiredTime":"2024-11-19T09:40:54.52Z","useTime":"0001-01-01T00:00:00Z","createTimt":"2024-08-21T09:40:54.52Z"},{"id":"66c5b627491faef8de2b7e24","uid":224411,"goodsName":"AI视频脸抵扣券","goodsType":4,"goodsValue":250,"goodsOrigin":"积分兑换","goodsDesc":"AI视频脸抵扣券(250金豆)\n","status":2,"expiredTime":"2024-09-20T09:40:55.61Z","useTime":"0001-01-01T00:00:00Z","createTimt":"2024-08-21T09:40:55.61Z"}],"total":4}
/// hash : false
/// msg : "success"
/// time : "2024-08-21T09:42:58.190Z"
/// tip : ""

class AIDiscountCoupont {
  AIDiscountCoupont({
    int? code,
    AIDiscountCoupontData? data,
    bool? hash,
    String? msg,
    String? time,
    String? tip,
  }) {
    _code = code;
    _data = data;
    _hash = hash;
    _msg = msg;
    _time = time;
    _tip = tip;
  }

  AIDiscountCoupont.fromJson(dynamic json) {
    _code = json['code'];
    _data = json['data'] != null ? AIDiscountCoupontData.fromJson(json['data']) : null;
    _hash = json['hash'];
    _msg = json['msg'];
    _time = json['time'];
    _tip = json['tip'];
  }
  int? _code;
  AIDiscountCoupontData? _data;
  bool? _hash;
  String? _msg;
  String? _time;
  String? _tip;

  int? get code => _code;
  AIDiscountCoupontData? get data => _data;
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

/// list : [{"id":"66c5b585491faef8de2b7e09","uid":224411,"goodsName":"AI视频脸抵扣券","goodsType":4,"goodsValue":250,"goodsOrigin":"积分兑换","goodsDesc":"AI视频脸抵扣券(250金豆)\n","status":2,"expiredTime":"2024-09-20T09:38:13.57Z","useTime":"0001-01-01T00:00:00Z","createTimt":"2024-08-21T09:38:13.57Z"},{"id":"66c5b625491faef8de2b7e1c","uid":224411,"goodsName":"AI视频脸抵扣券","goodsType":4,"goodsValue":400,"goodsOrigin":"积分兑换","goodsDesc":"AI视频脸抵扣券(400金豆)","status":2,"expiredTime":"2024-11-19T09:40:53.618Z","useTime":"0001-01-01T00:00:00Z","createTimt":"2024-08-21T09:40:53.618Z"},{"id":"66c5b626491faef8de2b7e20","uid":224411,"goodsName":"AI视频脸抵扣券","goodsType":4,"goodsValue":400,"goodsOrigin":"积分兑换","goodsDesc":"AI视频脸抵扣券(400金豆)","status":2,"expiredTime":"2024-11-19T09:40:54.52Z","useTime":"0001-01-01T00:00:00Z","createTimt":"2024-08-21T09:40:54.52Z"},{"id":"66c5b627491faef8de2b7e24","uid":224411,"goodsName":"AI视频脸抵扣券","goodsType":4,"goodsValue":250,"goodsOrigin":"积分兑换","goodsDesc":"AI视频脸抵扣券(250金豆)\n","status":2,"expiredTime":"2024-09-20T09:40:55.61Z","useTime":"0001-01-01T00:00:00Z","createTimt":"2024-08-21T09:40:55.61Z"}]
/// total : 4

class AIDiscountCoupontData {
  AIDiscountCoupontData({
    List<AIDiscountCoupontList>? list,
    int? total,
  }) {
    _list = list;
    _total = total;
  }

  AIDiscountCoupontData.fromJson(dynamic json) {
    if (json['list'] != null) {
      _list = [];
      json['list'].forEach((v) {
        _list?.add(AIDiscountCoupontList.fromJson(v));
      });
    }
    _total = json['total'];
  }
  List<AIDiscountCoupontList>? _list;
  int? _total;

  List<AIDiscountCoupontList>? get list => _list;
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

/// id : "66c5b585491faef8de2b7e09"
/// uid : 224411
/// goodsName : "AI视频脸抵扣券"
/// goodsType : 4
/// goodsValue : 250
/// goodsOrigin : "积分兑换"
/// goodsDesc : "AI视频脸抵扣券(250金豆)\n"
/// status : 2
/// expiredTime : "2024-09-20T09:38:13.57Z"
/// useTime : "0001-01-01T00:00:00Z"
/// createTimt : "2024-08-21T09:38:13.57Z"

class AIDiscountCoupontList {
  AIDiscountCoupontList({
    String? id,
    int? uid,
    String? goodsName,
    int? goodsType,
    int? goodsValue,
    String? goodsOrigin,
    String? goodsDesc,
    int? status,
    String? expiredTime,
    String? useTime,
    String? createTimt,
  }) {
    _id = id;
    _uid = uid;
    _goodsName = goodsName;
    _goodsType = goodsType;
    _goodsValue = goodsValue;
    _goodsOrigin = goodsOrigin;
    _goodsDesc = goodsDesc;
    _status = status;
    _expiredTime = expiredTime;
    _useTime = useTime;
    _createTimt = createTimt;
  }

  AIDiscountCoupontList.fromJson(dynamic json) {
    _id = json['id'];
    _uid = json['uid'];
    _goodsName = json['goodsName'];
    _goodsType = json['goodsType'];
    _goodsValue = json['goodsValue'];
    _goodsOrigin = json['goodsOrigin'];
    _goodsDesc = json['goodsDesc'];
    _status = json['status'];
    _expiredTime = json['expiredTime'];
    _useTime = json['useTime'];
    _createTimt = json['createTimt'];
  }
  String? _id;
  int? _uid;
  String? _goodsName;
  int? _goodsType;
  int? _goodsValue;
  String? _goodsOrigin;
  String? _goodsDesc;
  int? _status;
  String? _expiredTime;
  String? _useTime;
  String? _createTimt;

  bool? isSelected = false;

  String? get id => _id;
  int? get uid => _uid;
  String? get goodsName => _goodsName;
  int? get goodsType => _goodsType;
  int? get goodsValue => _goodsValue;
  String? get goodsOrigin => _goodsOrigin;
  String? get goodsDesc => _goodsDesc;
  int? get status => _status;
  String? get expiredTime => _expiredTime;
  String? get useTime => _useTime;
  String? get createTimt => _createTimt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['uid'] = _uid;
    map['goodsName'] = _goodsName;
    map['goodsType'] = _goodsType;
    map['goodsValue'] = _goodsValue;
    map['goodsOrigin'] = _goodsOrigin;
    map['goodsDesc'] = _goodsDesc;
    map['status'] = _status;
    map['expiredTime'] = _expiredTime;
    map['useTime'] = _useTime;
    map['createTimt'] = _createTimt;
    return map;
  }
}

//ai女友余额
class AIGirlFriendBalanceModel {
  num? balance;

  AIGirlFriendBalanceModel.fromJson(dynamic json) {
    json ??= {};
    balance = json['balance'];
  }
}

//ai跳转url
class AIGirlFriendUrlModel {
  String? url;

  AIGirlFriendUrlModel.fromJson(dynamic json) {
    json ??= {};
    url = json['url'];
  }
}

//ai跳转url
class AIGirlFriendCurrencys {
  List<AIGirlFriendCurrency>? list;

  AIGirlFriendCurrencys.fromJson(dynamic json) {
    json ??= {};
    if (json['list'] != null) {
      list = <AIGirlFriendCurrency>[];
      json['list'].forEach((v) {
        list!.add(AIGirlFriendCurrency.fromJson(v));
      });
    }
  }
}

class AIGirlFriendCurrency {
  String? id; //货币id
  String? name; //货币名称
  num? coins; //购买货币数(对应积分数量)
  num? price; //价格(对应需要支付的金币数量),
  String? couponDesc; //优惠描述
  int? type;

  AIGirlFriendCurrency.fromJson(dynamic json) {
    json ??= {};
    id = json['id'];
    name = json['name'];
    coins = json['coins'];
    price = json['price'];
    couponDesc = json['couponDesc'];
    type = json['type'];
  }
}
