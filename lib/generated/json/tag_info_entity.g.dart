import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/tag_info_entity.dart';

TagInfoEntity $TagInfoEntityFromJson(Map<String, dynamic> json) {
	final TagInfoEntity tagInfoEntity = TagInfoEntity();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		tagInfoEntity.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		tagInfoEntity.name = name;
	}
	final String? coverImg = jsonConvert.convert<String>(json['coverImg']);
	if (coverImg != null) {
		tagInfoEntity.coverImg = coverImg;
	}
	final String? backgroundImg = jsonConvert.convert<String>(json['backgroundImg']);
	if (backgroundImg != null) {
		tagInfoEntity.backgroundImg = backgroundImg;
	}
	final String? tagDesc = jsonConvert.convert<String>(json['tagDesc']);
	if (tagDesc != null) {
		tagInfoEntity.tagDesc = tagDesc;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		tagInfoEntity.description = description;
	}
	final bool? hasCollected = jsonConvert.convert<bool>(json['hasCollected']);
	if (hasCollected != null) {
		tagInfoEntity.hasCollected = hasCollected;
	}
	final int? playCount = jsonConvert.convert<int>(json['playCount']);
	if (playCount != null) {
		tagInfoEntity.playCount = playCount;
	}
	return tagInfoEntity;
}

Map<String, dynamic> $TagInfoEntityToJson(TagInfoEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['coverImg'] = entity.coverImg;
	data['backgroundImg'] = entity.backgroundImg;
	data['tagDesc'] = entity.tagDesc;
	data['description'] = entity.description;
	data['hasCollected'] = entity.hasCollected;
	data['playCount'] = entity.playCount;
	return data;
}