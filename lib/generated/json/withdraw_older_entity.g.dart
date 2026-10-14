import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/withdraw_older_entity.dart';

WithdrawOlderEntity $WithdrawOlderEntityFromJson(Map<String, dynamic> json) {
	final WithdrawOlderEntity withdrawOlderEntity = WithdrawOlderEntity();
	final bool? hasNext = jsonConvert.convert<bool>(json['hasNext']);
	if (hasNext != null) {
		withdrawOlderEntity.hasNext = hasNext;
	}
	final List<WithdrawOlderList>? list = jsonConvert.convertListNotNull<WithdrawOlderList>(json['list']);
	if (list != null) {
		withdrawOlderEntity.list = list;
	}
	final List<WithdrawOlderResult>? result = jsonConvert.convertListNotNull<WithdrawOlderResult>(json['result']);
	if (result != null) {
		withdrawOlderEntity.result = result;
	}
	final int? total = jsonConvert.convert<int>(json['total']);
	if (total != null) {
		withdrawOlderEntity.total = total;
	}
	return withdrawOlderEntity;
}

Map<String, dynamic> $WithdrawOlderEntityToJson(WithdrawOlderEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['hasNext'] = entity.hasNext;
	data['list'] =  entity.list?.map((v) => v.toJson()).toList();
	data['result'] =  entity.result?.map((v) => v.toJson()).toList();
	data['total'] = entity.total;
	return data;
}

WithdrawOlderList $WithdrawOlderListFromJson(Map<String, dynamic> json) {
	final WithdrawOlderList withdrawOlderList = WithdrawOlderList();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		withdrawOlderList.id = id;
	}
	final String? cid = jsonConvert.convert<String>(json['cid']);
	if (cid != null) {
		withdrawOlderList.cid = cid;
	}
	final int? uid = jsonConvert.convert<int>(json['uid']);
	if (uid != null) {
		withdrawOlderList.uid = uid;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		withdrawOlderList.name = name;
	}
	final int? amount = jsonConvert.convert<int>(json['amount']);
	if (amount != null) {
		withdrawOlderList.amount = amount;
	}
	final String? oid = jsonConvert.convert<String>(json['oid']);
	if (oid != null) {
		withdrawOlderList.oid = oid;
	}
	final int? money = jsonConvert.convert<int>(json['money']);
	if (money != null) {
		withdrawOlderList.money = money;
	}
	final int? payMoney = jsonConvert.convert<int>(json['payMoney']);
	if (payMoney != null) {
		withdrawOlderList.payMoney = payMoney;
	}
	final String? payType = jsonConvert.convert<String>(json['payType']);
	if (payType != null) {
		withdrawOlderList.payType = payType;
	}
	final int? withdrawType = jsonConvert.convert<int>(json['withdrawType']);
	if (withdrawType != null) {
		withdrawOlderList.withdrawType = withdrawType;
	}
	final String? actName = jsonConvert.convert<String>(json['actName']);
	if (actName != null) {
		withdrawOlderList.actName = actName;
	}
	final String? act = jsonConvert.convert<String>(json['act']);
	if (act != null) {
		withdrawOlderList.act = act;
	}
	final String? userIp = jsonConvert.convert<String>(json['userIp']);
	if (userIp != null) {
		withdrawOlderList.userIp = userIp;
	}
	final String? deviceType = jsonConvert.convert<String>(json['deviceType']);
	if (deviceType != null) {
		withdrawOlderList.deviceType = deviceType;
	}
	final String? devID = jsonConvert.convert<String>(json['devID']);
	if (devID != null) {
		withdrawOlderList.devID = devID;
	}
	final int? status = jsonConvert.convert<int>(json['status']);
	if (status != null) {
		withdrawOlderList.status = status;
	}
	final String? statusDesc = jsonConvert.convert<String>(json['statusDesc']);
	if (statusDesc != null) {
		withdrawOlderList.statusDesc = statusDesc;
	}
	final String? checkedAt = jsonConvert.convert<String>(json['checkedAt']);
	if (checkedAt != null) {
		withdrawOlderList.checkedAt = checkedAt;
	}
	final String? progressAt = jsonConvert.convert<String>(json['progressAt']);
	if (progressAt != null) {
		withdrawOlderList.progressAt = progressAt;
	}
	final String? failureAt = jsonConvert.convert<String>(json['failureAt']);
	if (failureAt != null) {
		withdrawOlderList.failureAt = failureAt;
	}
	final String? successAt = jsonConvert.convert<String>(json['successAt']);
	if (successAt != null) {
		withdrawOlderList.successAt = successAt;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
	if (updatedAt != null) {
		withdrawOlderList.updatedAt = updatedAt;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		withdrawOlderList.createdAt = createdAt;
	}
	final String? receivedAt = jsonConvert.convert<String>(json['receivedAt']);
	if (receivedAt != null) {
		withdrawOlderList.receivedAt = receivedAt;
	}
	final String? districtRemark = jsonConvert.convert<String>(json['districtRemark']);
	if (districtRemark != null) {
		withdrawOlderList.districtRemark = districtRemark;
	}
	final int? productType = jsonConvert.convert<int>(json['productType']);
	if (productType != null) {
		withdrawOlderList.productType = productType;
	}
	final String? bankCode = jsonConvert.convert<String>(json['bankCode']);
	if (bankCode != null) {
		withdrawOlderList.bankCode = bankCode;
	}
	final String? districtCode = jsonConvert.convert<String>(json['districtCode']);
	if (districtCode != null) {
		withdrawOlderList.districtCode = districtCode;
	}
	final String? promSeqe = jsonConvert.convert<String>(json['promSeqe']);
	if (promSeqe != null) {
		withdrawOlderList.promSeqe = promSeqe;
	}
	final bool? isDirect = jsonConvert.convert<bool>(json['isDirect']);
	if (isDirect != null) {
		withdrawOlderList.isDirect = isDirect;
	}
	final String? discBindAt = jsonConvert.convert<String>(json['DiscBindAt']);
	if (discBindAt != null) {
		withdrawOlderList.discBindAt = discBindAt;
	}
	return withdrawOlderList;
}

Map<String, dynamic> $WithdrawOlderListToJson(WithdrawOlderList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['cid'] = entity.cid;
	data['uid'] = entity.uid;
	data['name'] = entity.name;
	data['amount'] = entity.amount;
	data['oid'] = entity.oid;
	data['money'] = entity.money;
	data['payMoney'] = entity.payMoney;
	data['payType'] = entity.payType;
	data['withdrawType'] = entity.withdrawType;
	data['actName'] = entity.actName;
	data['act'] = entity.act;
	data['userIp'] = entity.userIp;
	data['deviceType'] = entity.deviceType;
	data['devID'] = entity.devID;
	data['status'] = entity.status;
	data['statusDesc'] = entity.statusDesc;
	data['checkedAt'] = entity.checkedAt;
	data['progressAt'] = entity.progressAt;
	data['failureAt'] = entity.failureAt;
	data['successAt'] = entity.successAt;
	data['updatedAt'] = entity.updatedAt;
	data['createdAt'] = entity.createdAt;
	data['receivedAt'] = entity.receivedAt;
	data['districtRemark'] = entity.districtRemark;
	data['productType'] = entity.productType;
	data['bankCode'] = entity.bankCode;
	data['districtCode'] = entity.districtCode;
	data['promSeqe'] = entity.promSeqe;
	data['isDirect'] = entity.isDirect;
	data['DiscBindAt'] = entity.discBindAt;
	return data;
}

WithdrawOlderResult $WithdrawOlderResultFromJson(Map<String, dynamic> json) {
	final WithdrawOlderResult withdrawOlderResult = WithdrawOlderResult();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		withdrawOlderResult.id = id;
	}
	final String? cid = jsonConvert.convert<String>(json['cid']);
	if (cid != null) {
		withdrawOlderResult.cid = cid;
	}
	final int? uid = jsonConvert.convert<int>(json['uid']);
	if (uid != null) {
		withdrawOlderResult.uid = uid;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		withdrawOlderResult.name = name;
	}
	final int? amount = jsonConvert.convert<int>(json['amount']);
	if (amount != null) {
		withdrawOlderResult.amount = amount;
	}
	final String? oid = jsonConvert.convert<String>(json['oid']);
	if (oid != null) {
		withdrawOlderResult.oid = oid;
	}
	final int? money = jsonConvert.convert<int>(json['money']);
	if (money != null) {
		withdrawOlderResult.money = money;
	}
	final int? payMoney = jsonConvert.convert<int>(json['payMoney']);
	if (payMoney != null) {
		withdrawOlderResult.payMoney = payMoney;
	}
	final String? payType = jsonConvert.convert<String>(json['payType']);
	if (payType != null) {
		withdrawOlderResult.payType = payType;
	}
	final int? withdrawType = jsonConvert.convert<int>(json['withdrawType']);
	if (withdrawType != null) {
		withdrawOlderResult.withdrawType = withdrawType;
	}
	final String? actName = jsonConvert.convert<String>(json['actName']);
	if (actName != null) {
		withdrawOlderResult.actName = actName;
	}
	final String? act = jsonConvert.convert<String>(json['act']);
	if (act != null) {
		withdrawOlderResult.act = act;
	}
	final String? userIp = jsonConvert.convert<String>(json['userIp']);
	if (userIp != null) {
		withdrawOlderResult.userIp = userIp;
	}
	final String? deviceType = jsonConvert.convert<String>(json['deviceType']);
	if (deviceType != null) {
		withdrawOlderResult.deviceType = deviceType;
	}
	final String? devID = jsonConvert.convert<String>(json['devID']);
	if (devID != null) {
		withdrawOlderResult.devID = devID;
	}
	final int? status = jsonConvert.convert<int>(json['status']);
	if (status != null) {
		withdrawOlderResult.status = status;
	}
	final String? statusDesc = jsonConvert.convert<String>(json['statusDesc']);
	if (statusDesc != null) {
		withdrawOlderResult.statusDesc = statusDesc;
	}
	final String? checkedAt = jsonConvert.convert<String>(json['checkedAt']);
	if (checkedAt != null) {
		withdrawOlderResult.checkedAt = checkedAt;
	}
	final String? progressAt = jsonConvert.convert<String>(json['progressAt']);
	if (progressAt != null) {
		withdrawOlderResult.progressAt = progressAt;
	}
	final String? failureAt = jsonConvert.convert<String>(json['failureAt']);
	if (failureAt != null) {
		withdrawOlderResult.failureAt = failureAt;
	}
	final String? successAt = jsonConvert.convert<String>(json['successAt']);
	if (successAt != null) {
		withdrawOlderResult.successAt = successAt;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
	if (updatedAt != null) {
		withdrawOlderResult.updatedAt = updatedAt;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		withdrawOlderResult.createdAt = createdAt;
	}
	final String? receivedAt = jsonConvert.convert<String>(json['receivedAt']);
	if (receivedAt != null) {
		withdrawOlderResult.receivedAt = receivedAt;
	}
	final String? districtRemark = jsonConvert.convert<String>(json['districtRemark']);
	if (districtRemark != null) {
		withdrawOlderResult.districtRemark = districtRemark;
	}
	final int? productType = jsonConvert.convert<int>(json['productType']);
	if (productType != null) {
		withdrawOlderResult.productType = productType;
	}
	final String? bankCode = jsonConvert.convert<String>(json['bankCode']);
	if (bankCode != null) {
		withdrawOlderResult.bankCode = bankCode;
	}
	final String? districtCode = jsonConvert.convert<String>(json['districtCode']);
	if (districtCode != null) {
		withdrawOlderResult.districtCode = districtCode;
	}
	final String? promSeqe = jsonConvert.convert<String>(json['promSeqe']);
	if (promSeqe != null) {
		withdrawOlderResult.promSeqe = promSeqe;
	}
	final bool? isDirect = jsonConvert.convert<bool>(json['isDirect']);
	if (isDirect != null) {
		withdrawOlderResult.isDirect = isDirect;
	}
	final String? discBindAt = jsonConvert.convert<String>(json['DiscBindAt']);
	if (discBindAt != null) {
		withdrawOlderResult.discBindAt = discBindAt;
	}
	return withdrawOlderResult;
}

Map<String, dynamic> $WithdrawOlderResultToJson(WithdrawOlderResult entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['cid'] = entity.cid;
	data['uid'] = entity.uid;
	data['name'] = entity.name;
	data['amount'] = entity.amount;
	data['oid'] = entity.oid;
	data['money'] = entity.money;
	data['payMoney'] = entity.payMoney;
	data['payType'] = entity.payType;
	data['withdrawType'] = entity.withdrawType;
	data['actName'] = entity.actName;
	data['act'] = entity.act;
	data['userIp'] = entity.userIp;
	data['deviceType'] = entity.deviceType;
	data['devID'] = entity.devID;
	data['status'] = entity.status;
	data['statusDesc'] = entity.statusDesc;
	data['checkedAt'] = entity.checkedAt;
	data['progressAt'] = entity.progressAt;
	data['failureAt'] = entity.failureAt;
	data['successAt'] = entity.successAt;
	data['updatedAt'] = entity.updatedAt;
	data['createdAt'] = entity.createdAt;
	data['receivedAt'] = entity.receivedAt;
	data['districtRemark'] = entity.districtRemark;
	data['productType'] = entity.productType;
	data['bankCode'] = entity.bankCode;
	data['districtCode'] = entity.districtCode;
	data['promSeqe'] = entity.promSeqe;
	data['isDirect'] = entity.isDirect;
	data['DiscBindAt'] = entity.discBindAt;
	return data;
}