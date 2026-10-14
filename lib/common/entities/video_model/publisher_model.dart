// ignore_for_file: public_member_api_docs, sort_constructors_first
T? asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

class PublisherModel {
  int? gender; // 性别 0:未知,1:男,2:女
  bool? hasFollowed; // 是否关注
  bool? hasLocked; //
  bool? hasBanned; //
  String? name; // 姓名
  String? portrait; // 头像
  int? uid; // 用户id
  String? vipExpireDate; // VIP过期时间
  int? vipLevel; // VIP等级
  bool? isVip; // 是否vip
  String? vipName; // 用户VIP名称
  int? rechargeLevel; //
  String? officialCertExpire; //
  int? superUser; //
  String? superUserExpire; //
  int? activeValue; //
  bool? officialCert; //
  int? age; // 年龄
  int? follows; //
  int? fans; //
  String? summary; //
  String? awards; //
  String? createdAt; //

  PublisherModel({
    this.gender,
    this.hasFollowed,
    this.hasLocked,
    this.hasBanned,
    this.name,
    this.portrait,
    this.uid,
    this.vipExpireDate,
    this.vipLevel,
    this.vipName,
    this.isVip,
    this.rechargeLevel,
    this.officialCertExpire,
    this.superUser,
    this.superUserExpire,
    this.activeValue,
    this.officialCert,
    this.age,
    this.follows,
    this.fans,
    this.summary,
    this.awards,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'gender': gender,
      'hasFollowed': hasFollowed,
      'hasLocked': hasLocked,
      'hasBanned': hasBanned,
      'name': name,
      'portrait': portrait,
      'uid': uid,
      'vipExpireDate': vipExpireDate,
      'vipLevel': vipLevel,
      'vipName': vipName,
      'isVip': isVip,
      'rechargeLevel': rechargeLevel,
      'officialCertExpire': officialCertExpire,
      'superUser': superUser,
      'superUserExpire': superUserExpire,
      'activeValue': activeValue,
      'officialCert': officialCert,
      'age': age,
      'follows': follows,
      'fans': fans,
      'summary': summary,
      'awards': awards,
      'createdAt': createdAt,
    };
  }

  factory PublisherModel.fromJson(Map<String, dynamic> map) {
    return PublisherModel(
      gender: asT<int>(map['gender']),
      hasFollowed: asT<bool>(map['hasFollowed']),
      hasLocked: asT<bool>(map['hasLocked']),
      hasBanned: asT<bool>(map['hasBanned']),
      name: asT<String>(map['name']),
      portrait: asT<String>(map['portrait']),
      uid: asT<int>(map['uid']),
      vipExpireDate: asT<String>(map['vipExpireDate']),
      vipLevel: asT<int>(map['vipLevel']),
      vipName: asT<String>(map['vipName']),
      isVip: asT<bool>(map['isVip']),
      rechargeLevel: asT<int>(map['rechargeLevel']),
      officialCertExpire: asT<String>(map['officialCertExpire']),
      superUser: asT<int>(map['superUser']),
      superUserExpire: asT<String>(map['superUserExpire']),
      activeValue: asT<int>(map['activeValue']),
      officialCert: asT<bool>(map['officialCert']),
      age: asT<int>(map['age']),
      follows: asT<int>(map['follows']),
      fans: asT<int>(map['fans']),
      summary: asT<String>(map['summary']),
      awards: asT<String>(map['awards']),
      createdAt: asT<String>(map['createdAt']),
    );
  }
}
