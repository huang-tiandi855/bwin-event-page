import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/sign_entity.dart';

SignEntity $SignEntityFromJson(Map<String, dynamic> json) {
	final SignEntity signEntity = SignEntity();
	final int? signCount = jsonConvert.convert<int>(json['signCount']);
	if (signCount != null) {
		signEntity.signCount = signCount;
	}
	final int? finishCondition = jsonConvert.convert<int>(json['finishCondition']);
	if (finishCondition != null) {
		signEntity.finishCondition = finishCondition;
	}
	final int? watchCount = jsonConvert.convert<int>(json['watchCount']);
	if (watchCount != null) {
		signEntity.watchCount = watchCount;
	}
	final bool? hasSign = jsonConvert.convert<bool>(json['hasSign']);
	if (hasSign != null) {
		signEntity.hasSign = hasSign;
	}
	return signEntity;
}

Map<String, dynamic> $SignEntityToJson(SignEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['signCount'] = entity.signCount;
	data['finishCondition'] = entity.finishCondition;
	data['watchCount'] = entity.watchCount;
	data['hasSign'] = entity.hasSign;
	return data;
}