class RechargeTypeModel {
  String? id;
  int? amount;
  int? money;
  int? firstGiveGold;
  String? typeName;
  String? couponDesc;
  List<RechargeTypeBean>? rechargeTypeList;
  List<Privilege>? privilege;
  int? giveGameCoin;
  int? giveGold;

  static RechargeTypeModel? fromJson(Map<String, dynamic>? map) {
    if (map == null) return null;
    RechargeTypeModel rechargeTypeListModelBean = RechargeTypeModel();
    rechargeTypeListModelBean.id = map['id'];
    rechargeTypeListModelBean.amount = map['amount'];
    rechargeTypeListModelBean.money = map['money'];
    rechargeTypeListModelBean.firstGiveGold = map['firstGiveGold'];
    rechargeTypeListModelBean.typeName = map['typeName'];
    rechargeTypeListModelBean.couponDesc = map['couponDesc'];
    rechargeTypeListModelBean.giveGameCoin = map['giveGameCoin'];
    rechargeTypeListModelBean.giveGold = map['giveGold'];

    rechargeTypeListModelBean.rechargeTypeList = [];
    if (map['rchgType'] != null) {
      map['rchgType'].forEach((o) {
        var result = RechargeTypeBean.fromMap(o);
        if (result != null) {
          rechargeTypeListModelBean.rechargeTypeList?.add(result);
          return result;
        }
        return null;
      });
    }

    rechargeTypeListModelBean.privilege = [];
    if (map['privilege'] != null) {
      map['privilege'].forEach((o) {
        var privilegeItem = Privilege.fromMap(o);
        if (privilegeItem != null) {
          rechargeTypeListModelBean.privilege?.add(privilegeItem);
          return privilegeItem;
        }
        return null;
      });
    }
    return rechargeTypeListModelBean;
  }

  Map toJson() => {
        "id": id,
        "amount": amount,
        "money": money,
        "typeName": typeName,
        "rchgType": rechargeTypeList,
        "couponDesc": couponDesc,
        "privilege": privilege,
        "firstGiveGold": firstGiveGold,
        "giveGameCoin": giveGameCoin,
        "giveGold": giveGold,
      };

  static List<RechargeTypeModel> toList(List<dynamic>? mapList) {
    List<RechargeTypeModel> list = [];
    if (mapList == null) return list;
    Iterator iterator = mapList.iterator;
    while (iterator.moveNext()) {
      Map<String, dynamic> current = iterator.current;
      RechargeTypeModel? item = fromJson(current);
      if (item != null) list.add(item);
    }
    return list;
  }
}

///特权信息
class Privilege {
  String? img;
  String? privilegeName;

  static Privilege? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    Privilege privilege = Privilege();
    privilege.img = map['img'];
    privilege.privilegeName = map['privilegeName'];
    return privilege;
  }

  Map toJson() => {
        "img": img,
        "privilegeName": privilegeName,
      };
}

class RechargeTypeBean {
  String? type;
  String? typeName;
  String? channel;
  String? incrAmount; //增加的优惠额度
  String?
      incTax; //按比率增加额外优惠额 0-1之间 ,如果 incrAmount 与 incrTax 同时存在 以 incrAmount 为准

  static RechargeTypeBean? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    RechargeTypeBean rechargeTypeBean = RechargeTypeBean();
    rechargeTypeBean.type = map['type'];
    rechargeTypeBean.typeName = map['typeName'];
    rechargeTypeBean.channel = map['channel'];
    rechargeTypeBean.incrAmount =
        map.containsKey('incrAmount') ? map['incrAmount'].toString() : '0';
    rechargeTypeBean.incTax =
        map.containsKey('incTax') ? map['incTax'].toString() : '0';
    return rechargeTypeBean;
  }

  Map toJson() => {
        "type": type,
        "typeName": typeName,
        "channel": channel,
        "incrAmount": incrAmount,
        "incTax": incTax,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RechargeTypeBean &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          typeName == other.typeName &&
          channel == other.channel;

  @override
  int get hashCode => type.hashCode ^ typeName.hashCode ^ channel.hashCode;
}
