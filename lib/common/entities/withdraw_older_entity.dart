import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/withdraw_older_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class WithdrawOlderEntity {

	bool? hasNext;
	List<WithdrawOlderList>? list;
	List<WithdrawOlderResult>? result;
	int? total;
  
  WithdrawOlderEntity();

  factory WithdrawOlderEntity.fromJson(Map<String, dynamic> json) => $WithdrawOlderEntityFromJson(json);

  Map<String, dynamic> toJson() => $WithdrawOlderEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class WithdrawOlderList {

	String? id;
	String? cid;
	int? uid;
	String? name;
	int? amount;
	String? oid;
	int? money;
	int? payMoney;
	String? payType;
	int? withdrawType;
	String? actName;
	String? act;
	String? userIp;
	String? deviceType;
	String? devID;
	int? status;
	String? statusDesc;
	String? checkedAt;
	String? progressAt;
	String? failureAt;
	String? successAt;
	String? updatedAt;
	String? createdAt;
	String? receivedAt;
	String? districtRemark;
	int? productType;
	String? bankCode;
	String? districtCode;
	String? promSeqe;
	bool? isDirect;
	@JSONField(name: "DiscBindAt")
	String? discBindAt;
  
  WithdrawOlderList();

  factory WithdrawOlderList.fromJson(Map<String, dynamic> json) => $WithdrawOlderListFromJson(json);

  Map<String, dynamic> toJson() => $WithdrawOlderListToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class WithdrawOlderResult {

	String? id;
	String? cid;
	int? uid;
	String? name;
	int? amount;
	String? oid;
	int? money;
	int? payMoney;
	String? payType;
	int? withdrawType;
	String? actName;
	String? act;
	String? userIp;
	String? deviceType;
	String? devID;
	int? status;
	String? statusDesc;
	String? checkedAt;
	String? progressAt;
	String? failureAt;
	String? successAt;
	String? updatedAt;
	String? createdAt;
	String? receivedAt;
	String? districtRemark;
	int? productType;
	String? bankCode;
	String? districtCode;
	String? promSeqe;
	bool? isDirect;
	@JSONField(name: "DiscBindAt")
	String? discBindAt;
  
  WithdrawOlderResult();

  factory WithdrawOlderResult.fromJson(Map<String, dynamic> json) => $WithdrawOlderResultFromJson(json);

  Map<String, dynamic> toJson() => $WithdrawOlderResultToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}