import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/media_list_entity.dart';

MediaListEntity $MediaListEntityFromJson(Map<String, dynamic> json) {
	final MediaListEntity mediaListEntity = MediaListEntity();
	final List<MediaListMediaList>? mediaList = jsonConvert.convertListNotNull<MediaListMediaList>(json['MediaList']);
	if (mediaList != null) {
		mediaListEntity.mediaList = mediaList;
	}
	final bool? hasNext = jsonConvert.convert<bool>(json['hasNext']);
	if (hasNext != null) {
		mediaListEntity.hasNext = hasNext;
	}
	return mediaListEntity;
}

Map<String, dynamic> $MediaListEntityToJson(MediaListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['MediaList'] =  entity.mediaList?.map((v) => v.toJson()).toList();
	data['hasNext'] = entity.hasNext;
	return data;
}

MediaListMediaList $MediaListMediaListFromJson(Map<String, dynamic> json) {
	final MediaListMediaList mediaListMediaList = MediaListMediaList();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mediaListMediaList.id = id;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		mediaListMediaList.title = title;
	}
	final String? horizontalCover = jsonConvert.convert<String>(json['horizontalCover']);
	if (horizontalCover != null) {
		mediaListMediaList.horizontalCover = horizontalCover;
	}
	final String? verticalCover = jsonConvert.convert<String>(json['verticalCover']);
	if (verticalCover != null) {
		mediaListMediaList.verticalCover = verticalCover;
	}
	final List<String>? tags = jsonConvert.convertListNotNull<String>(json['tags']);
	if (tags != null) {
		mediaListMediaList.tags = tags;
	}
	final List<String>? tagNames = jsonConvert.convertListNotNull<String>(json['tagNames']);
	if (tagNames != null) {
		mediaListMediaList.tagNames = tagNames;
	}
	final String? summary = jsonConvert.convert<String>(json['summary']);
	if (summary != null) {
		mediaListMediaList.summary = summary;
	}
	final int? totalEpisode = jsonConvert.convert<int>(json['totalEpisode']);
	if (totalEpisode != null) {
		mediaListMediaList.totalEpisode = totalEpisode;
	}
	final String? mediaType = jsonConvert.convert<String>(json['mediaType']);
	if (mediaType != null) {
		mediaListMediaList.mediaType = mediaType;
	}
	final int? kind = jsonConvert.convert<int>(json['kind']);
	if (kind != null) {
		mediaListMediaList.kind = kind;
	}
	final int? price = jsonConvert.convert<int>(json['price']);
	if (price != null) {
		mediaListMediaList.price = price;
	}
	final int? permission = jsonConvert.convert<int>(json['permission']);
	if (permission != null) {
		mediaListMediaList.permission = permission;
	}
	final int? direction = jsonConvert.convert<int>(json['direction']);
	if (direction != null) {
		mediaListMediaList.direction = direction;
	}
	final int? sellType = jsonConvert.convert<int>(json['sellType']);
	if (sellType != null) {
		mediaListMediaList.sellType = sellType;
	}
	final String? general = jsonConvert.convert<String>(json['general']);
	if (general != null) {
		mediaListMediaList.general = general;
	}
	final int? generalSort = jsonConvert.convert<int>(json['generalSort']);
	if (generalSort != null) {
		mediaListMediaList.generalSort = generalSort;
	}
	final String? choice = jsonConvert.convert<String>(json['choice']);
	if (choice != null) {
		mediaListMediaList.choice = choice;
	}
	final int? choiceSort = jsonConvert.convert<int>(json['choiceSort']);
	if (choiceSort != null) {
		mediaListMediaList.choiceSort = choiceSort;
	}
	final bool? isActive = jsonConvert.convert<bool>(json['isActive']);
	if (isActive != null) {
		mediaListMediaList.isActive = isActive;
	}
	final int? countPurchases = jsonConvert.convert<int>(json['countPurchases']);
	if (countPurchases != null) {
		mediaListMediaList.countPurchases = countPurchases;
	}
	final int? countBrowse = jsonConvert.convert<int>(json['countBrowse']);
	if (countBrowse != null) {
		mediaListMediaList.countBrowse = countBrowse;
	}
	final int? countCollect = jsonConvert.convert<int>(json['countCollect']);
	if (countCollect != null) {
		mediaListMediaList.countCollect = countCollect;
	}
	final int? countLike = jsonConvert.convert<int>(json['countLike']);
	if (countLike != null) {
		mediaListMediaList.countLike = countLike;
	}
	final int? number = jsonConvert.convert<int>(json['number']);
	if (number != null) {
		mediaListMediaList.number = number;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		mediaListMediaList.createdAt = createdAt;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
	if (updatedAt != null) {
		mediaListMediaList.updatedAt = updatedAt;
	}



	final int? updateStatus = jsonConvert.convert<int>(json['updateStatus']);
	if (updateStatus != null) {
		mediaListMediaList.updateStatus = updateStatus;
	}

	final String? updatedDesc = jsonConvert.convert<String>(json['updatedDesc']);
	if (updatedDesc != null) {
		mediaListMediaList.updatedDesc = updatedDesc;
	}

	return mediaListMediaList;
}

Map<String, dynamic> $MediaListMediaListToJson(MediaListMediaList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['title'] = entity.title;
	data['horizontalCover'] = entity.horizontalCover;
	data['verticalCover'] = entity.verticalCover;
	data['tags'] =  entity.tags;
	data['tagNames'] =  entity.tagNames;
	data['summary'] = entity.summary;
	data['totalEpisode'] = entity.totalEpisode;
	data['mediaType'] = entity.mediaType;
	data['kind'] = entity.kind;
	data['price'] = entity.price;
	data['permission'] = entity.permission;
	data['direction'] = entity.direction;
	data['sellType'] = entity.sellType;
	data['general'] = entity.general;
	data['generalSort'] = entity.generalSort;
	data['choice'] = entity.choice;
	data['choiceSort'] = entity.choiceSort;
	data['isActive'] = entity.isActive;
	data['countPurchases'] = entity.countPurchases;
	data['countBrowse'] = entity.countBrowse;
	data['countCollect'] = entity.countCollect;
	data['countLike'] = entity.countLike;
	data['number'] = entity.number;
	data['createdAt'] = entity.createdAt;
	data['updatedAt'] = entity.updatedAt;

	data['updateStatus'] = entity.updateStatus;
	data['updatedDesc'] = entity.updatedDesc;
	return data;
}