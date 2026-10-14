import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/bill_entity.dart';

BillEntity $BillEntityFromJson(Map<String, dynamic> json) {
	final BillEntity billEntity = BillEntity();
	final String? income = jsonConvert.convert<String>(json['income']);
	if (income != null) {
		billEntity.income = income;
	}
	final String? expenditure = jsonConvert.convert<String>(json['expenditure']);
	if (expenditure != null) {
		billEntity.expenditure = expenditure;
	}
	final bool? hasNext = jsonConvert.convert<bool>(json['hasNext']);
	if (hasNext != null) {
		billEntity.hasNext = hasNext;
	}
	final List<BillList>? list = jsonConvert.convertListNotNull<BillList>(json['list']);
	if (list != null) {
		billEntity.list = list;
	}
	final bool? haxNextMonth = jsonConvert.convert<bool>(json['haxNextMonth']);
	if (haxNextMonth != null) {
		billEntity.haxNextMonth = haxNextMonth;
	}
	final int? month = jsonConvert.convert<int>(json['month']);
	if (month != null) {
		billEntity.month = month;
	}
	final int? year = jsonConvert.convert<int>(json['year']);
	if (year != null) {
		billEntity.year = year;
	}
	return billEntity;
}

Map<String, dynamic> $BillEntityToJson(BillEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['income'] = entity.income;
	data['expenditure'] = entity.expenditure;
	data['hasNext'] = entity.hasNext;
	data['list'] =  entity.list?.map((v) => v.toJson()).toList();
	data['haxNextMonth'] = entity.haxNextMonth;
	data['month'] = entity.month;
	data['year'] = entity.year;
	return data;
}

BillList $BillListFromJson(Map<String, dynamic> json) {
	final BillList billList = BillList();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		billList.id = id;
	}
	final int? uid = jsonConvert.convert<int>(json['uid']);
	if (uid != null) {
		billList.uid = uid;
	}
	final String? purchaseOrder = jsonConvert.convert<String>(json['purchaseOrder']);
	if (purchaseOrder != null) {
		billList.purchaseOrder = purchaseOrder;
	}
	final dynamic productID = jsonConvert.convert<dynamic>(json['productID']);
	if (productID != null) {
		billList.productID = productID;
	}
	final int? amount = jsonConvert.convert<int>(json['amount']);
	if (amount != null) {
		billList.amount = amount;
	}
	final int? actualAmount = jsonConvert.convert<int>(json['actualAmount']);
	if (actualAmount != null) {
		billList.actualAmount = actualAmount;
	}
	final int? tax = jsonConvert.convert<int>(json['tax']);
	if (tax != null) {
		billList.tax = tax;
	}
	final int? taxAmount = jsonConvert.convert<int>(json['taxAmount']);
	if (taxAmount != null) {
		billList.taxAmount = taxAmount;
	}
	final String? channelType = jsonConvert.convert<String>(json['channelType']);
	if (channelType != null) {
		billList.channelType = channelType;
	}
	final String? tranType = jsonConvert.convert<String>(json['tranType']);
	if (tranType != null) {
		billList.tranType = tranType;
	}
	final int? tranTypeInt = jsonConvert.convert<int>(json['tranTypeInt']);
	if (tranTypeInt != null) {
		billList.tranTypeInt = tranTypeInt;
	}
	final int? performance = jsonConvert.convert<int>(json['performance']);
	if (performance != null) {
		billList.performance = performance;
	}
	final int? rechargeId = jsonConvert.convert<int>(json['rechargeId']);
	if (rechargeId != null) {
		billList.rechargeId = rechargeId;
	}
	final String? desc = jsonConvert.convert<String>(json['desc']);
	if (desc != null) {
		billList.desc = desc;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		billList.createdAt = createdAt;
	}
	final String? sysType = jsonConvert.convert<String>(json['sysType']);
	if (sysType != null) {
		billList.sysType = sysType;
	}
	final int? agentLevel = jsonConvert.convert<int>(json['agentLevel']);
	if (agentLevel != null) {
		billList.agentLevel = agentLevel;
	}
	final int? vipLevel = jsonConvert.convert<int>(json['vipLevel']);
	if (vipLevel != null) {
		billList.vipLevel = vipLevel;
	}
	final String? realAmount = jsonConvert.convert<String>(json['realAmount']);
	if (realAmount != null) {
		billList.realAmount = realAmount;
	}
	final String? money = jsonConvert.convert<String>(json['money']);
	if (money != null) {
		billList.money = money;
	}
	final String? wlRealAmount = jsonConvert.convert<String>(json['wlRealAmount']);
	if (wlRealAmount != null) {
		billList.wlRealAmount = wlRealAmount;
	}
	final int? fruitCoin = jsonConvert.convert<int>(json['fruitCoin']);
	if (fruitCoin != null) {
		billList.fruitCoin = fruitCoin;
	}
	final int? fruitCoinBalance = jsonConvert.convert<int>(json['fruitCoinBalance']);
	if (fruitCoinBalance != null) {
		billList.fruitCoinBalance = fruitCoinBalance;
	}
	final String? districtCode = jsonConvert.convert<String>(json['districtCode']);
	if (districtCode != null) {
		billList.districtCode = districtCode;
	}
	final String? promSeqe = jsonConvert.convert<String>(json['promSeqe']);
	if (promSeqe != null) {
		billList.promSeqe = promSeqe;
	}
	final bool? isDirect = jsonConvert.convert<bool>(json['isDirect']);
	if (isDirect != null) {
		billList.isDirect = isDirect;
	}
	final String? discBindAt = jsonConvert.convert<String>(json['DiscBindAt']);
	if (discBindAt != null) {
		billList.discBindAt = discBindAt;
	}
	return billList;
}

Map<String, dynamic> $BillListToJson(BillList entity) {
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