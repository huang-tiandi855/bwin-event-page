import 'package:comics_app/common/entities/wallet_recharge_type_list_model.dart';

class ProductItemBean {
  String? productID;
  int? vipLevel;
  String? productName;
  String? alias;
  String? desc;
  int? duration;
  String? bgImg;
  String? bgImgType1;
  int? originalPrice;
  int? discountedPrice;
  int? productType;
  int? sort;
  bool? status;
  String? position;
  bool? unitPriceDisplay;
  String? actionDesc;
  String? privilegeDesc;
  int? showCountdownTime;
  bool? isAmountPay;
  String? updatedAt;
  String? createdAt;
  LoufengCard? loufengCard;
  List<RechargeTypeBean>? rchgType;
  List<Privilege>? privilege;

  int? giveCoin;
  int? giveGameCoin;
  int? louFengUnlockTimes;
  int? goldVideoFreeDay;

  String? details;

  int? louFengDiscount;

  ProductItemBean({
    this.productID,
    this.vipLevel,
    this.productName,
    this.alias,
    this.desc,
    this.duration,
    this.bgImg,
    this.bgImgType1,
    this.originalPrice,
    this.discountedPrice,
    this.productType,
    this.sort,
    this.status,
    this.position,
    this.unitPriceDisplay,
    this.actionDesc,
    this.privilegeDesc,
    this.showCountdownTime,
    this.isAmountPay,
    this.updatedAt,
    this.createdAt,
    this.rchgType,
    this.privilege,
    this.loufengCard,
    this.giveCoin,
    this.giveGameCoin,
    this.louFengUnlockTimes,
    this.goldVideoFreeDay,
    this.details,
    this.louFengDiscount,
  });

  ProductItemBean.fromJson(Map<String, dynamic> json) {
    productID = json['productID'];
    vipLevel = json['vipLevel'];
    productName = json['productName'];
    alias = json['alias'];
    desc = json['desc'];
    duration = json['duration'];
    bgImg = json['bgImg'];
    bgImgType1 = json['bgImgType1'];
    originalPrice = json['originalPrice'];
    discountedPrice = json['discountedPrice'];
    productType = json['productType'];
    sort = json['sort'];
    status = json['status'];
    position = json['position'];
    unitPriceDisplay = json['unitPriceDisplay'];
    actionDesc = json['actionDesc'];
    privilegeDesc = json['privilegeDesc'];
    showCountdownTime = json['showCountdownTime'];
    isAmountPay = json['isAmountPay'];
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];

    giveCoin = json['giveCoin'];
    giveGameCoin = json['giveGameCoin'];
    louFengUnlockTimes = json['louFengUnlockTimes'];
    goldVideoFreeDay = json['goldVideoFreeDay'];
    details = json['details'];

    louFengDiscount = json['louFengDiscount'];

    if (json['rchgType'] != null) {
      rchgType = <RechargeTypeBean>[];
      json['rchgType'].forEach((v) {
        var rechargeTypeItem = RechargeTypeBean.fromMap(v);
        if (rechargeTypeItem != null) rchgType?.add(rechargeTypeItem);
      });
    }
    if (json['privilege'] != null) {
      privilege = <Privilege>[];
      json['privilege'].forEach((v) {
        Privilege? privilegeItem = Privilege.fromMap(v);
        if (privilegeItem != null) privilege?.add(privilegeItem);
      });
    }
    loufengCard = json['discountCard'] != null
        ?  LoufengCard.fromJson(json['discountCard'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productID'] = productID;
    data['vipLevel'] = vipLevel;
    data['productName'] = productName;
    data['alias'] = alias;
    data['desc'] = desc;
    data['duration'] = duration;
    data['bgImg'] = bgImg;
    data['bgImgType1'] = bgImgType1;
    data['originalPrice'] = originalPrice;
    data['discountedPrice'] = discountedPrice;
    data['productType'] = productType;
    data['sort'] = sort;
    data['status'] = status;
    data['position'] = position;
    data['unitPriceDisplay'] = unitPriceDisplay;
    data['actionDesc'] = actionDesc;
    data['privilegeDesc'] = privilegeDesc;
    data['showCountdownTime'] = showCountdownTime;
    data['isAmountPay'] = isAmountPay;
    data['updatedAt'] = updatedAt;
    data['createdAt'] = createdAt;

    data['giveCoin'] = giveCoin;
    data['giveGameCoin'] = giveGameCoin;
    data['louFengUnlockTimes'] = louFengUnlockTimes;
    data['goldVideoFreeDay'] = goldVideoFreeDay;
    data['details'] = details;
    if (rchgType != null) {
      data['rchgType'] = rchgType?.map((v) => v.toJson()).toList();
    }
    if (privilege != null) {
      data['privilege'] = privilege?.map((v) => v.toJson()).toList();
    }
    if (loufengCard != null) {
      data['discountCard'] = loufengCard?.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'ProductItemBean{productID: $productID, vipLevel: $vipLevel, productName: $productName, alias: $alias, desc: $desc, duration: $duration, bgImg: $bgImg, bgImgType1: $bgImgType1, originalPrice: $originalPrice, discountedPrice: $discountedPrice, productType: $productType, sort: $sort, status: $status, position: $position, unitPriceDisplay: $unitPriceDisplay, actionDesc: $actionDesc, privilegeDesc: $privilegeDesc, showCountdownTime: $showCountdownTime, isAmountPay: $isAmountPay, updatedAt: $updatedAt, createdAt: $createdAt, loufengCard: $loufengCard, rchgType: $rchgType, privilege: $privilege, giveCoin: $giveCoin, giveGameCoin: $giveGameCoin, louFengUnlockTimes: $louFengUnlockTimes, goldVideoFreeDay: $goldVideoFreeDay, details: $details, louFengDiscount: $louFengDiscount}';
  }
}

class LoufengCard {
  bool? isReceived;
  String? expiration;
  String? expirationTime;
  bool? isBrought;

  LoufengCard(
      {this.isReceived, this.expiration, this.expirationTime, this.isBrought});

  LoufengCard.fromJson(Map<String, dynamic> json) {
    isReceived = json['isReceived'];
    expiration = json['expiration'];
    expirationTime = json['expirationTime'];
    isBrought = json['isBrought'];
  }

  Map<String, dynamic>? toJson() {
    final Map<String, dynamic> data = {};
    data['isReceived'] = isReceived;
    data['expiration'] = expiration;
    data['expirationTime'] = expirationTime;
    data['isBrought'] = isBrought;
    return data;
  }

  @override
  String toString() {
    return 'LoufengCard{isReceived: $isReceived, expiration: $expiration, expirationTime: $expirationTime, isBrought: $isBrought}';
  }
}
