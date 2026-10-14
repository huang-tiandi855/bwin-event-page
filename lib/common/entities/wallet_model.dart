
class WalletModel {
  ///收益金币 毛/角
  int? income;
  int? uid;
  ///充值金币
  int? amount;
  int? performance;
  ///充值金币
  int? money;
  int? consumption;
  String? id;
  int? takeOut;
  int? current;
  int? limit;
  int? maxLevel;
  String? nudeChatIncome;
  int? fruitCoin;
  List<PrivilegeBean>? privilegeBeans;
  int? proxyIncome;
  num? vidIncome;
  int? point;
  int? aiUndressFreeTimes;
  WalletModel({
    this.income,
    this.uid,
    this.amount,
    this.performance,
    this.money,
    this.consumption,
    this.id,
    this.takeOut,
    this.current,
    this.limit,
    this.nudeChatIncome,
    this.fruitCoin,
    this.privilegeBeans,
    this.proxyIncome,
    this.vidIncome,
    this.point,
    this.aiUndressFreeTimes,
  });

  WalletModel.fromJson(Map<String, dynamic> json) {
    point = json['point'];
    income = json['income'];
    uid = json['uid'];
    aiUndressFreeTimes = json['aiUndressFreeTimes'];
    amount = json['amount'];
    performance = json['performance'];
    money = json['money'];
    consumption = json['consumption'];
    id = json['id'];
    current = json['current'];
    limit = json['limit'];
    nudeChatIncome = json['nudeChatIncome'];
    fruitCoin = json['fruitCoin'];
    takeOut = json['takeOut'];
    maxLevel = json['maxLevel'];
    proxyIncome = json['proxyIncome'];
    vidIncome = json['vidIncome'];
    privilegeBeans = [];

    if (json['privileges'] != null) {
      if ((json['privileges'] as List).isNotEmpty) {
        (json['privileges'] as List).map((e) {
          privilegeBeans?.add(PrivilegeBean.fromJson(e));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['point'] = point;
    data['income'] = income;
    data['uid'] = uid;
    data['amount'] = amount;
    data['performance'] = performance;
    data['money'] = money;
    data['consumption'] = consumption;
    data['id'] = id;
    data['takeOut'] = takeOut;
    data['maxLevel'] = maxLevel;
    data['nudeChatIncome'] = nudeChatIncome;
    data['fruitCoin'] = fruitCoin;
    data['proxyIncome'] = proxyIncome;
    data['vidIncome'] = vidIncome;
    data['aiUndressFreeTimes'] = aiUndressFreeTimes;
    return data;
  }
}

class PrivilegeBean {
  String? name;
  String? desc;
  int? icon;
  int? type;
  bool? enable;
  int? number;

  PrivilegeBean.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    desc = json['desc'];
    icon = json['icon'];
    type = json['type'];
    enable = json['enable'];
    number = json['number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['desc'] = desc;
    data['icon'] = icon;
    data['type'] = type;
    data['enable'] = enable;
    data['number'] = number;
    return data;
  }
}
