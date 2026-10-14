import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/incomes_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class IncomesEntity {

	bool? hasNext;
	List<IncomesList>? list;
  
  IncomesEntity();

  factory IncomesEntity.fromJson(Map<String, dynamic> json) => $IncomesEntityFromJson(json);

  Map<String, dynamic> toJson() => $IncomesEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class IncomesList {

	String? id;
	int? uid;
	int? cashierUID;
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
	String? desc;
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

	String? vidTitle;
	String? cashierAvatar;
	String? cashierName;
	String? vidCover;
  IncomesList();

  factory IncomesList.fromJson(Map<String, dynamic> json) => $IncomesListFromJson(json);

  Map<String, dynamic> toJson() => $IncomesListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}