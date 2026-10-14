// 更多女优模型(关键数据)
class PayForModel {
  int? imId; //商人在聊天系统中的ID
  String? userId; //商人在代充系统中的ID
  String? avatar; //头像
  String? nickName; //昵称
  String? welcomeMsg; //商人欢迎语
  List<PayInfoModel>? payInfos;

  int? limit = 0;

  int? payMethod;
  List<int>? payType;

  static PayForModel? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    PayForModel model = PayForModel();
    model.imId = map['imId'];
    model.userId = map['userId'];
    model.avatar = map['avatar'];
    model.nickName = map['nickName'];
    model.welcomeMsg = map['welcomeMsg'];
    ////支付方式
    if (map['payInfos'] != null) {
      model.payInfos = [];
      for (var value in map['payInfos']) {
        var payInfoModel = PayInfoModel.fromMap(value);
        if (payInfoModel != null) model.payInfos?.add(payInfoModel);
      }
    }
    return model;
  }

  Map toJson() => {
        "imId": imId,
        "userId": userId,
        "avatar": avatar,
        "welcomeMsg": welcomeMsg,
        "nickName": nickName,
        "payInfos": payInfos,
      };

  PayForModel clone() {
    PayForModel model = PayForModel();
    model.imId = imId;
    model.userId = userId;
    model.avatar = avatar;
    model.nickName = nickName;
    model.welcomeMsg = welcomeMsg;
    model.payInfos = [];
    for (var value in payInfos!) {
      model.payInfos?.add(value.clone());
    }
    model.imId = imId;
    return model;
  }
}

//=====================================================================================
// 支付模型
class PayInfoModel {
  int? payMethod;
  List<int>? payType;

  static PayInfoModel? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    PayInfoModel model = PayInfoModel();
    model.payMethod = map["payMethod"];
    model.payType = [];
    for (var value in map["payType"]) {
      model.payType?.add(value);
    }
    return model;
  }

  Map toJson() => {
        "payMethod": payMethod,
        "payType": payType,
      };

  PayInfoModel clone() {
    PayInfoModel model = PayInfoModel();
    model.payMethod = payMethod;
    model.payType = [];
    for (var value in payType!) {
      model.payType?.add(value);
    }
    return model;
  }
}

//=====================================================================================

// 更多女优模型(关键数据)
class DCModel {
  bool? isReconnect;

  /// 商人列表  为空则不展示代充
  List<PayForModel>? traders;
  String? url;
  String? ordUrl;
  String? traderUrl;

  int? chargeMoney;

  ///大额支付 小额支付
  int? limit;
  String? userAgent;

  String? wsUrl;

  String? picUrl;

  /// 商品id,客户端添加，非后端返回，代充值给h5的时候使用
  String? productInfo;

  UserInfoModel2? userInfo;

  static DCModel? fromJson(Map<String, dynamic>? map) {
    if (map == null) return null;
    DCModel model = DCModel();
    model.isReconnect = map['isReconnect'];
    if (map['traders'] != null && (map['traders'] as List).isNotEmpty) {
      var payForModel = PayForModel.fromMap(map['traders'][0]);
      if (payForModel != null) model.traders = [payForModel];
    }
    model.url = map['url'];
    model.wsUrl = map['wsUrl'];
    model.picUrl = map['picUrl'];
    model.ordUrl = map['ordUrl'];
    model.traderUrl = map['traderUrl'];
    model.userInfo = UserInfoModel2.fromMap(map['userInfo']);
    model.chargeMoney = map['chargeMoney'];
    model.limit = map['limit'];
    model.userAgent = map['userAgent'];
    model.productInfo = map['productInfo'];
    return model;
  }

  Map toJson() => {
        "isReconnect": isReconnect,
        "traders": traders,
        "url": url,
        "ordUrl": ordUrl,
        "traderUrl": traderUrl,
        "userInfo": userInfo,
        "chargeMoney": chargeMoney,
        "limit": limit,
        "wsUrl": wsUrl,
        "picUrl": picUrl,
        "userAgent": userAgent,
        "productInfo": productInfo,
      };

  DCModel clone() {
    DCModel model = DCModel();
    model.isReconnect = isReconnect;

    model.traders = [];
    for (var value in traders!) {
      model.traders?.add(value.clone());
    }
    model.url = url;
    model.ordUrl = ordUrl;
    model.traderUrl = traderUrl;
    model.userInfo = userInfo?.clone();
    model.chargeMoney = chargeMoney;
    model.limit = limit;
    model.userAgent = userAgent;
    model.wsUrl = wsUrl;
    model.picUrl = picUrl;
    model.productInfo = productInfo;

    return model;
  }
}

//=====================================================================================
// 用户模型
class UserInfoModel2 {
  int? uid;

  String? name;
  String? portrait;

  static UserInfoModel2? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    UserInfoModel2 model = UserInfoModel2();
    model.uid = map['uid'];
    model.name = map['name'];
    model.portrait = map['portrait'];
    return model;
  }

  Map toJson() => {
        "uid": uid,
        "name": name,
        "portrait": portrait,
      };

  UserInfoModel2 clone() {
    UserInfoModel2 model = UserInfoModel2();
    model.uid = uid;
    model.name = name;
    model.portrait = portrait;
    return model;
  }
}
