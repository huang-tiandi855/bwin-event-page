import 'package:comics_app/gen/assets.gen.dart';

class VipCardModel {
  VipCardModel({
    this.id,
    this.name,
    this.price,
    this.originalPrice,
    this.validDay,
    this.status,
    this.channelCode,
    this.position,
    this.type,
    this.gold,
    this.level,
    this.bg,
    this.gameGold,
    this.gifGold,
    this.newcomerCard,
    List<VipPayWayModel>? payWays,
    List<VipPrivilegeModel>? privileges,
    List<int>? memberPermissionIds,
    List<VipMemberPermissionModel>? memberPermissions,
  })  : payWays = payWays ?? [],
        privileges = privileges ?? [],
        memberPermissionIds = memberPermissionIds ?? [],
        memberPermissions = memberPermissions ?? [];

  int? id;
  String? name;
  //售价
  double? price;
  //划线原价（展示用）
  double? originalPrice;
  // 会员有效天数
  int? validDay;
  int? status;
  //渠道编码，特定通道套餐时使用
  String? channelCode;
  int? position;
  //套餐类型
  int? type;
  // 充值/赠送金币数量
  int? gold;
  //关联会员等级
  int? level;
  //套餐背景图地址或资源名
  String? bg;
  // 游戏币数量（若有）
  double? gameGold;
  //额外赠送金币数
  int? gifGold;
  //是否新人卡
  int? newcomerCard;
  List<VipPayWayModel> payWays;
  List<VipPrivilegeModel> privileges;
  List<int> memberPermissionIds;
  List<VipMemberPermissionModel> memberPermissions;

  factory VipCardModel.fromJson(Map<String, dynamic> json) {
    return VipCardModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      price: _parseDouble(json['price']),
      originalPrice: _parseDouble(json['originalPrice']),
      validDay: _parseInt(json['validDay']),
      status: _parseInt(json['status']),
      channelCode: json['channelCode']?.toString(),
      position: _parseInt(json['position']),
      type: _parseInt(json['type']),
      gold: _parseInt(json['gold']),
      level: _parseInt(json['level']),
      bg: json['bg']?.toString(),
      gameGold: _parseDouble(json['gameGold']),
      gifGold: _parseInt(json['gifGold']),
      newcomerCard: _parseInt(json['newcomerCard']),
      payWays: _parseList(
        json['payWays'],
        (e) => VipPayWayModel.fromJson(e),
      ),
      privileges: _parseList(
        json['privileges'],
        (e) => VipPrivilegeModel.fromJson(e),
      ),
      memberPermissionIds: _parseIntList(json['memberPermissionIds']),
      memberPermissions: _parseList(
        json['memberPermissions'],
        (e) => VipMemberPermissionModel.fromJson(e),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'originalPrice': originalPrice,
        'validDay': validDay,
        'status': status,
        'channelCode': channelCode,
        'position': position,
        'type': type,
        'gold': gold,
        'level': level,
        'bg': bg,
        'gameGold': gameGold,
        'gifGold': gifGold,
        'newcomerCard': newcomerCard,
        'payWays': payWays.map((e) => e.toJson()).toList(),
        'privileges': privileges.map((e) => e.toJson()).toList(),
        'memberPermissionIds': memberPermissionIds,
        'memberPermissions': memberPermissions.map((e) => e.toJson()).toList(),
      };
}

class VipPayWayModel {
  VipPayWayModel({
    this.id,
    this.productId,
    this.name,
    this.threeType,
    this.payType,
    this.channel,
    this.sort,
    this.content,
    this.status,
    this.img,
    this.money,
    this.showType,
    this.exchangeRate,
    this.backRate,
  });

  int? id;
  int? productId;
  String? name;
  int? threeType;

  ///0：微信  1：支付宝
  int? payType;
  String? channel;
  int? sort;
  String? content;
  int? status;
  String? img;
  double? money;
  int? showType;
  double? exchangeRate;
  double? backRate;

  AssetGenImage get payImg {
    if (payType == 0) {
      return AssetsGen.images.mine.icPayWechat;
    } else {
      return AssetsGen.images.mine.icPayAlipay;
    }
  }

  factory VipPayWayModel.fromJson(Map<String, dynamic> json) {
    return VipPayWayModel(
      id: _parseInt(json['id']),
      productId: _parseInt(json['productId']),
      name: json['name']?.toString(),
      threeType: _parseInt(json['threeType']),
      payType: _parseInt(json['payType']),
      channel: json['channel']?.toString(),
      sort: _parseInt(json['sort']),
      content: json['content']?.toString(),
      status: _parseInt(json['status']),
      img: json['img']?.toString(),
      money: _parseDouble(json['money']),
      showType: _parseInt(json['showType']),
      exchangeRate: _parseDouble(json['exchangeRate']),
      backRate: _parseDouble(json['backRate']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'name': name,
        'threeType': threeType,
        'payType': payType,
        'channel': channel,
        'sort': sort,
        'content': content,
        'status': status,
        'img': img,
        'money': money,
        'showType': showType,
        'exchangeRate': exchangeRate,
        'backRate': backRate,
      };
}

class VipPrivilegeModel {
  VipPrivilegeModel({
    this.id,
    this.advertiserId,
    this.resourceUrl,
    this.resourceType,
    this.title,
    this.description,
    this.externalLink,
    this.actionType,
    this.status,
    this.needUserToken,
    this.fullScreen,
    this.endTime,
  });

  int? id;
  int? advertiserId;
  String? resourceUrl;
  int? resourceType;
  String? title;
  String? description;
  String? externalLink;
  int? actionType;
  int? status;
  bool? needUserToken;
  bool? fullScreen;
  dynamic endTime;

  factory VipPrivilegeModel.fromJson(Map<String, dynamic> json) {
    return VipPrivilegeModel(
      id: _parseInt(json['id']),
      advertiserId: _parseInt(json['advertiserId']),
      resourceUrl: json['resourceUrl']?.toString(),
      resourceType: _parseInt(json['resourceType']),
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      externalLink: json['externalLink']?.toString(),
      actionType: _parseInt(json['actionType']),
      status: _parseInt(json['status']),
      needUserToken: _parseBool(json['needUserToken']),
      fullScreen: _parseBool(json['fullScreen']),
      endTime: json['endTime'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'advertiserId': advertiserId,
        'resourceUrl': resourceUrl,
        'resourceType': resourceType,
        'title': title,
        'description': description,
        'externalLink': externalLink,
        'actionType': actionType,
        'status': status,
        'needUserToken': needUserToken,
        'fullScreen': fullScreen,
        'endTime': endTime,
      };
}

class VipMemberPermissionModel {
  VipMemberPermissionModel({
    this.id,
    this.permissionKey,
    this.permissionCode,
    this.name,
    this.description,
    this.iconUrl,
  });

  int? id;
  String? permissionKey;
  String? permissionCode;
  String? name;
  String? description;
  String? iconUrl;

  factory VipMemberPermissionModel.fromJson(Map<String, dynamic> json) {
    return VipMemberPermissionModel(
      id: _parseInt(json['id']),
      permissionKey: json['permissionKey']?.toString(),
      permissionCode: json['permissionCode']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      iconUrl: json['iconUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'permissionKey': permissionKey,
        'permissionCode': permissionCode,
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
      };
}

List<T> _parseList<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) convert,
) {
  if (value is! List) return <T>[];
  return value
      .whereType<Map>()
      .map((e) => convert(Map<String, dynamic>.from(e)))
      .toList();
}

List<int> _parseIntList(dynamic value) {
  if (value is! List) return <int>[];
  return value.map(_parseInt).whereType<int>().toList();
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().toLowerCase();
  if (text == 'true') return true;
  if (text == 'false') return false;
  return null;
}
