import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/user_right_entity.dart';

UserRightEntity $UserRightEntityFromJson(Map<String, dynamic> json) {
	final UserRightEntity userRightEntity = UserRightEntity();
	final int? uid = jsonConvert.convert<int>(json['uid']);
	if (uid != null) {
		userRightEntity.uid = uid;
	}
	final List<UserRightWatchReadCoupon>? watchReadCoupon = jsonConvert.convertListNotNull<UserRightWatchReadCoupon>(json['watchReadCoupon']);
	if (watchReadCoupon != null) {
		userRightEntity.watchReadCoupon = watchReadCoupon;
	}
	final dynamic cards = jsonConvert.convert<dynamic>(json['cards']);
	if (cards != null) {
		userRightEntity.cards = cards;
	}
	final int? videoDiscount = jsonConvert.convert<int>(json['videoDiscount']);
	if (videoDiscount != null) {
		userRightEntity.videoDiscount = videoDiscount;
	}
	final String? vipExpireDate = jsonConvert.convert<String>(json['vipExpireDate']);
	if (vipExpireDate != null) {
		userRightEntity.vipExpireDate = vipExpireDate;
	}
	final String? goldVideoFreeExpire = jsonConvert.convert<String>(json['goldVideoFreeExpire']);
	if (goldVideoFreeExpire != null) {
		userRightEntity.goldVideoFreeExpire = goldVideoFreeExpire;
	}
	final int? louFengDiscount = jsonConvert.convert<int>(json['louFengDiscount']);
	if (louFengDiscount != null) {
		userRightEntity.louFengDiscount = louFengDiscount;
	}
	final String? loufengDiscountExpiration = jsonConvert.convert<String>(json['loufengDiscountExpiration']);
	if (loufengDiscountExpiration != null) {
		userRightEntity.loufengDiscountExpiration = loufengDiscountExpiration;
	}
	final int? loufengBookDiscount = jsonConvert.convert<int>(json['loufengBookDiscount']);
	if (loufengBookDiscount != null) {
		userRightEntity.loufengBookDiscount = loufengBookDiscount;
	}
	final String? loufengBookDiscountExpiration = jsonConvert.convert<String>(json['loufengBookDiscountExpiration']);
	if (loufengBookDiscountExpiration != null) {
		userRightEntity.loufengBookDiscountExpiration = loufengBookDiscountExpiration;
	}
	return userRightEntity;
}

Map<String, dynamic> $UserRightEntityToJson(UserRightEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['uid'] = entity.uid;
	data['watchReadCoupon'] =  entity.watchReadCoupon?.map((v) => v.toJson()).toList();
	data['cards'] = entity.cards;
	data['videoDiscount'] = entity.videoDiscount;
	data['vipExpireDate'] = entity.vipExpireDate;
	data['goldVideoFreeExpire'] = entity.goldVideoFreeExpire;
	data['louFengDiscount'] = entity.louFengDiscount;
	data['loufengDiscountExpiration'] = entity.loufengDiscountExpiration;
	data['loufengBookDiscount'] = entity.loufengBookDiscount;
	data['loufengBookDiscountExpiration'] = entity.loufengBookDiscountExpiration;
	return data;
}

UserRightWatchReadCoupon $UserRightWatchReadCouponFromJson(Map<String, dynamic> json) {
	final UserRightWatchReadCoupon userRightWatchReadCoupon = UserRightWatchReadCoupon();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		userRightWatchReadCoupon.id = id;
	}
	final int? uid = jsonConvert.convert<int>(json['uid']);
	if (uid != null) {
		userRightWatchReadCoupon.uid = uid;
	}
	final int? num = jsonConvert.convert<int>(json['num']);
	if (num != null) {
		userRightWatchReadCoupon.num = num;
	}
	final String? xSource = jsonConvert.convert<String>(json['source']);
	if (xSource != null) {
		userRightWatchReadCoupon.xSource = xSource;
	}
	final bool? used = jsonConvert.convert<bool>(json['used']);
	if (used != null) {
		userRightWatchReadCoupon.used = used;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		userRightWatchReadCoupon.createdAt = createdAt;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
	if (updatedAt != null) {
		userRightWatchReadCoupon.updatedAt = updatedAt;
	}
	return userRightWatchReadCoupon;
}

Map<String, dynamic> $UserRightWatchReadCouponToJson(UserRightWatchReadCoupon entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['uid'] = entity.uid;
	data['num'] = entity.num;
	data['source'] = entity.xSource;
	data['used'] = entity.used;
	data['createdAt'] = entity.createdAt;
	data['updatedAt'] = entity.updatedAt;
	return data;
}