import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/incomes_entity.dart';

IncomesEntity $IncomesEntityFromJson(Map<String, dynamic> json) {
	final IncomesEntity incomesEntity = IncomesEntity();
	final bool? hasNext = jsonConvert.convert<bool>(json['hasNext']);
	if (hasNext != null) {
		incomesEntity.hasNext = hasNext;
	}
	final List<IncomesList>? list = jsonConvert.convertListNotNull<IncomesList>(json['list']);
	if (list != null) {
		incomesEntity.list = list;
	}
	return incomesEntity;
}

Map<String, dynamic> $IncomesEntityToJson(IncomesEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['hasNext'] = entity.hasNext;
	data['list'] =  entity.list?.map((v) => v.toJson()).toList();
	return data;
}

IncomesList $IncomesListFromJson(Map<String, dynamic> json) {
	final IncomesList incomesList = IncomesList();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		incomesList.id = id;
	}
	final int? uid = jsonConvert.convert<int>(json['uid']);
	if (uid != null) {
		incomesList.uid = uid;
	}
	final String? purchaseOrder = jsonConvert.convert<String>(json['purchaseOrder']);
	if (purchaseOrder != null) {
		incomesList.purchaseOrder = purchaseOrder;
	}
	final dynamic productID = jsonConvert.convert<dynamic>(json['productID']);
	if (productID != null) {
		incomesList.productID = productID;
	}
	final int? amount = jsonConvert.convert<int>(json['amount']);
	if (amount != null) {
		incomesList.amount = amount;
	}
	final int? actualAmount = jsonConvert.convert<int>(json['actualAmount']);
	if (actualAmount != null) {
		incomesList.actualAmount = actualAmount;
	}
	final int? tax = jsonConvert.convert<int>(json['tax']);
	if (tax != null) {
		incomesList.tax = tax;
	}
	final int? taxAmount = jsonConvert.convert<int>(json['taxAmount']);
	if (taxAmount != null) {
		incomesList.taxAmount = taxAmount;
	}
	final String? channelType = jsonConvert.convert<String>(json['channelType']);
	if (channelType != null) {
		incomesList.channelType = channelType;
	}
	final String? tranType = jsonConvert.convert<String>(json['tranType']);
	if (tranType != null) {
		incomesList.tranType = tranType;
	}
	final int? tranTypeInt = jsonConvert.convert<int>(json['tranTypeInt']);
	if (tranTypeInt != null) {
		incomesList.tranTypeInt = tranTypeInt;
	}
	final int? performance = jsonConvert.convert<int>(json['performance']);
	if (performance != null) {
		incomesList.performance = performance;
	}
	final int? rechargeId = jsonConvert.convert<int>(json['rechargeId']);
	if (rechargeId != null) {
		incomesList.rechargeId = rechargeId;
	}
	final String? desc = jsonConvert.convert<String>(json['desc']);
	if (desc != null) {
		incomesList.desc = desc;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		incomesList.createdAt = createdAt;
	}
	final String? sysType = jsonConvert.convert<String>(json['sysType']);
	if (sysType != null) {
		incomesList.sysType = sysType;
	}
	final int? agentLevel = jsonConvert.convert<int>(json['agentLevel']);
	if (agentLevel != null) {
		incomesList.agentLevel = agentLevel;
	}
	final int? vipLevel = jsonConvert.convert<int>(json['vipLevel']);
	if (vipLevel != null) {
		incomesList.vipLevel = vipLevel;
	}
	final String? realAmount = jsonConvert.convert<String>(json['realAmount']);
	if (realAmount != null) {
		incomesList.realAmount = realAmount;
	}
	final String? money = jsonConvert.convert<String>(json['money']);
	if (money != null) {
		incomesList.money = money;
	}
	final String? wlRealAmount = jsonConvert.convert<String>(json['wlRealAmount']);
	if (wlRealAmount != null) {
		incomesList.wlRealAmount = wlRealAmount;
	}
	final int? fruitCoin = jsonConvert.convert<int>(json['fruitCoin']);
	if (fruitCoin != null) {
		incomesList.fruitCoin = fruitCoin;
	}
	final int? fruitCoinBalance = jsonConvert.convert<int>(json['fruitCoinBalance']);
	if (fruitCoinBalance != null) {
		incomesList.fruitCoinBalance = fruitCoinBalance;
	}
	final String? districtCode = jsonConvert.convert<String>(json['districtCode']);
	if (districtCode != null) {
		incomesList.districtCode = districtCode;
	}
	final String? promSeqe = jsonConvert.convert<String>(json['promSeqe']);
	if (promSeqe != null) {
		incomesList.promSeqe = promSeqe;
	}
	final bool? isDirect = jsonConvert.convert<bool>(json['isDirect']);
	if (isDirect != null) {
		incomesList.isDirect = isDirect;
	}
	final String? discBindAt = jsonConvert.convert<String>(json['DiscBindAt']);
	if (discBindAt != null) {
		incomesList.discBindAt = discBindAt;
	}
	final String? vidCover = jsonConvert.convert<String>(json['vidCover']);
	if (vidCover != null) {
		incomesList.vidCover = vidCover;
	}


	final String? vidTitle = jsonConvert.convert<String>(json['vidTitle']);
	if (vidTitle != null) {
		incomesList.vidTitle = vidTitle;
	}

	final String? cashierAvatar = jsonConvert.convert<String>(json['cashierAvatar']);
	if (cashierAvatar != null) {
		incomesList.cashierAvatar = cashierAvatar;
	}

	final String? cashierName = jsonConvert.convert<String>(json['cashierName']);
	if (cashierName != null) {
		incomesList.cashierName = cashierName;
	}
	final int? cashierUID = jsonConvert.convert<int>(json['cashierUID']);
	if (cashierUID != null) {
		incomesList.cashierUID = cashierUID;
	}


	return incomesList;
}

Map<String, dynamic> $IncomesListToJson(IncomesList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['uid'] = entity.uid;
	data['purchaseOrder'] = entity.purchaseOrder;
	data['productID'] = entity.productID;
	data['amount'] = entity.amount;
	data['actualAmount'] = entity.actualAmount;
	data['tax'] = entity.tax;
	data['taxAmount'] = entity.taxAmount;
	data['channelType'] = entity.channelType;
	data['tranType'] = entity.tranType;
	data['tranTypeInt'] = entity.tranTypeInt;
	data['performance'] = entity.performance;
	data['rechargeId'] = entity.rechargeId;
	data['desc'] = entity.desc;
	data['createdAt'] = entity.createdAt;
	data['sysType'] = entity.sysType;
	data['agentLevel'] = entity.agentLevel;
	data['vipLevel'] = entity.vipLevel;
	data['realAmount'] = entity.realAmount;
	data['money'] = entity.money;
	data['wlRealAmount'] = entity.wlRealAmount;
	data['fruitCoin'] = entity.fruitCoin;
	data['fruitCoinBalance'] = entity.fruitCoinBalance;
	data['districtCode'] = entity.districtCode;
	data['promSeqe'] = entity.promSeqe;
	data['isDirect'] = entity.isDirect;
	data['DiscBindAt'] = entity.discBindAt;
	return data;
}