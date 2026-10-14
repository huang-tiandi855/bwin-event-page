import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/hot_topic_entity.dart';

HotTopicEntity $HotTopicEntityFromJson(Map<String, dynamic> json) {
	final HotTopicEntity hotTopicEntity = HotTopicEntity();
	final List<HotTopicList>? list = jsonConvert.convertListNotNull<HotTopicList>(json['list']);
	if (list != null) {
		hotTopicEntity.list = list;
	}
	final bool? hasNext = jsonConvert.convert<bool>(json['hasNext']);
	if (hasNext != null) {
		hotTopicEntity.hasNext = hasNext;
	}
	return hotTopicEntity;
}

Map<String, dynamic> $HotTopicEntityToJson(HotTopicEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['list'] =  entity.list?.map((v) => v.toJson()).toList();
	data['hasNext'] = entity.hasNext;
	return data;
}

HotTopicList $HotTopicListFromJson(Map<String, dynamic> json) {
	final HotTopicList hotTopicList = HotTopicList();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		hotTopicList.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		hotTopicList.name = name;
	}
	final String? tagDesc = jsonConvert.convert<String>(json['tagDesc']);
	if (tagDesc != null) {
		hotTopicList.tagDesc = tagDesc;
	}
	final String? coverImg = jsonConvert.convert<String>(json['coverImg']);
	if (coverImg != null) {
		hotTopicList.coverImg = coverImg;
	}
	final int? playCount = jsonConvert.convert<int>(json['playCount']);
	if (playCount != null) {
		hotTopicList.playCount = playCount;
	}
	final int? collCount = jsonConvert.convert<int>(json['collCount']);
	if (collCount != null) {
		hotTopicList.collCount = collCount;
	}
	final bool? hasCollected = jsonConvert.convert<bool>(json['hasCollected']);
	if (hasCollected != null) {
		hotTopicList.hasCollected = hasCollected;
	}
	final bool? hasSelected = jsonConvert.convert<bool>(json['hasSelected']);
	if (hasSelected != null) {
		hotTopicList.hasSelected = hasSelected;
	}
	return hotTopicList;
}

Map<String, dynamic> $HotTopicListToJson(HotTopicList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['tagDesc'] = entity.tagDesc;
	data['coverImg'] = entity.coverImg;
	data['playCount'] = entity.playCount;
	data['collCount'] = entity.collCount;
	data['hasCollected'] = entity.hasCollected;
	data['hasSelected'] = entity.hasSelected;
	return data;
}