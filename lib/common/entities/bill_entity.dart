import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/bill_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class BillEntity {

	String? income;
	String? expenditure;
	bool? hasNext;
	List<BillList>? list;
	bool? haxNextMonth;
	int? month;
	int? year;
  
  BillEntity();

  factory BillEntity.fromJson(Map<String, dynamic> json) => $BillEntityFromJson(json);

  Map<String, dynamic> toJson() => $BillEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class BillList {

	String? id;
	int? uid;
	String? purchaseOrder;
	dynamic productID;
	int? amount;
	int? actualAmount;
	int? tax;
	int? taxAmount;
	String? channelType;
	String? tranType;
	int? tranTypeInt;
	int? performance;
	int? rechargeId;
	String desc="";
	String? createdAt;
	String? sysType;
	int? agentLevel;
	int? vipLevel;
	String? realAmount;
	String? money;
	String? wlRealAmount;
	int? fruitCoin;
	int? fruitCoinBalance;
	String? districtCode;
	String? promSeqe;
	bool? isDirect;
	@JSONField(name: "DiscBindAt")
	String? discBindAt;
  
  BillList();

  factory BillList.fromJson(Map<String, dynamic> json) => $BillListFromJson(json);

  Map<String, dynamic> toJson() => $BillListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}