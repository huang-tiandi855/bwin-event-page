import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/user_right_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class UserRightEntity {

	int? uid;
	List<UserRightWatchReadCoupon>? watchReadCoupon;
	dynamic cards;
	int? videoDiscount;
	String? vipExpireDate;
	String? goldVideoFreeExpire;
	int? louFengDiscount;
	String? loufengDiscountExpiration;
	int? loufengBookDiscount;
	String? loufengBookDiscountExpiration;
  
  UserRightEntity();

  factory UserRightEntity.fromJson(Map<String, dynamic> json) => $UserRightEntityFromJson(json);

  Map<String, dynamic> toJson() => $UserRightEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class UserRightWatchReadCoupon {

	String? id;
	int? uid;
	int? num;
	@JSONField(name: "source")
	String? xSource;
	bool? used;
	String? createdAt;
	String? updatedAt;
  
  UserRightWatchReadCoupon();

  factory UserRightWatchReadCoupon.fromJson(Map<String, dynamic> json) => $UserRightWatchReadCouponFromJson(json);

  Map<String, dynamic> toJson() => $UserRightWatchReadCouponToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}