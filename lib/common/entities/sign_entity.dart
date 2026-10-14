import 'package:comics_app/generated/json/base/json_field.dart';
import 'package:comics_app/generated/json/sign_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class SignEntity {

	int? signCount;
	int? finishCondition;
	int? watchCount;
	bool? hasSign;
  
  SignEntity();

  factory SignEntity.fromJson(Map<String, dynamic> json) => $SignEntityFromJson(json);

  Map<String, dynamic> toJson() => $SignEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}