import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/media_info_entity.dart';

class TagsName{



	String? id;
	String? name;

	TagsName(this.id,this.name);

}

MediaInfoEntity $MediaInfoEntityFromJson(Map<String, dynamic> json) {
	final MediaInfoEntity mediaInfoEntity = MediaInfoEntity();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mediaInfoEntity.id = id;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		mediaInfoEntity.title = title;
	}
	final String? horizontalCover = jsonConvert.convert<String>(json['horizontalCover']);
	if (horizontalCover != null) {
		mediaInfoEntity.horizontalCover = horizontalCover;
	}
	final String? verticalCover = jsonConvert.convert<String>(json['verticalCover']);
	if (verticalCover != null) {
		mediaInfoEntity.verticalCover = verticalCover;
	}
	final List<String>? tags = jsonConvert.convertListNotNull<String>(json['tags']);
	if (tags != null) {
		mediaInfoEntity.tags = tags;
	}


	final List<String> tagNames = [];
	json['tagDetails'].forEach((element) {
		tagNames.add(element["name"]);
	});

	mediaInfoEntity.tagNames = tagNames;

	/*final List<tagsName>? tagNames = jsonConvert.convertListNotNull<tagsName>(json['tagDetails']);
	if (tagNames != null) {
		mediaInfoEntity.tagNames = tagNames;
	}*/


	final String? summary = jsonConvert.convert<String>(json['summary']);
	if (summary != null) {
		mediaInfoEntity.summary = summary;
	}
	final int? totalEpisode = jsonConvert.convert<int>(json['totalEpisode']);
	if (totalEpisode != null) {
		mediaInfoEntity.totalEpisode = totalEpisode;
	}
	final String? mediaType = jsonConvert.convert<String>(json['mediaType']);
	if (mediaType != null) {
		mediaInfoEntity.mediaType = mediaType;
	}
	final int? kind = jsonConvert.convert<int>(json['kind']);
	if (kind != null) {
		mediaInfoEntity.kind = kind;
	}
	final int? price = jsonConvert.convert<int>(json['price']);
	if (price != null) {
		mediaInfoEntity.price = price;
	}
	final int? direction = jsonConvert.convert<int>(json['direction']);
	if (direction != null) {
		mediaInfoEntity.direction = direction;
	}
	final int? sellType = jsonConvert.convert<int>(json['sellType']);
	if (sellType != null) {
		mediaInfoEntity.sellType = sellType;
	}
	final String? general = jsonConvert.convert<String>(json['general']);
	if (general != null) {
		mediaInfoEntity.general = general;
	}
	final int? generalSort = jsonConvert.convert<int>(json['generalSort']);
	if (generalSort != null) {
		mediaInfoEntity.generalSort = generalSort;
	}
	final String? choice = jsonConvert.convert<String>(json['choice']);
	if (choice != null) {
		mediaInfoEntity.choice = choice;
	}
	final int? choiceSort = jsonConvert.convert<int>(json['choiceSort']);
	if (choiceSort != null) {
		mediaInfoEntity.choiceSort = choiceSort;
	}
	final bool? isActive = jsonConvert.convert<bool>(json['isActive']);
	if (isActive != null) {
		mediaInfoEntity.isActive = isActive;
	}
	final int? countPurchases = jsonConvert.convert<int>(json['countPurchases']);
	if (countPurchases != null) {
		mediaInfoEntity.countPurchases = countPurchases;
	}
	final int? countBrowse = jsonConvert.convert<int>(json['countBrowse']);
	if (countBrowse != null) {
		mediaInfoEntity.countBrowse = countBrowse;
	}
	final int? countCollect = jsonConvert.convert<int>(json['countCollect']);
	if (countCollect != null) {
		mediaInfoEntity.countCollect = countCollect;
	}


	final int? countComment = jsonConvert.convert<int>(json['countComment']);
	if (countCollect != null) {
		mediaInfoEntity.countComment = countComment;
	}


	final int? countLike = jsonConvert.convert<int>(json['countLike']);
	if (countLike != null) {
		mediaInfoEntity.countLike = countLike;
	}
	final int? number = jsonConvert.convert<int>(json['number']);
	if (number != null) {
		mediaInfoEntity.number = number;
	}
	final int? permission = jsonConvert.convert<int>(json['permission']);
	if (permission != null) {
		mediaInfoEntity.permission = permission;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		mediaInfoEntity.createdAt = createdAt;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
	if (updatedAt != null) {
		mediaInfoEntity.updatedAt = updatedAt;
	}
	final List<MediaInfoContents>? contents = jsonConvert.convertListNotNull<MediaInfoContents>(json['contents']);
	if (contents != null) {
		mediaInfoEntity.contents = contents;
	}
	final bool? hasLiked = jsonConvert.convert<bool>(json['hasLiked']);
	if (hasLiked != null) {
		mediaInfoEntity.hasLiked = hasLiked;
	}
	final bool? hasPaid = jsonConvert.convert<bool>(json['hasPaid']);
	if (hasPaid != null) {
		mediaInfoEntity.hasPaid = hasPaid;
	}
	final bool? hasCollected = jsonConvert.convert<bool>(json['hasCollected']);
	if (hasCollected != null) {
		mediaInfoEntity.hasCollected = hasCollected;
	}
	final int? collects = jsonConvert.convert<int>(json['collects']);
	if (collects != null) {
		mediaInfoEntity.collects = collects;
	}
	return mediaInfoEntity;
}

Map<String, dynamic> $MediaInfoEntityToJson(MediaInfoEntity entity) {
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
	data['permission'] = entity.permission;
	data['createdAt'] = entity.createdAt;
	data['updatedAt'] = entity.updatedAt;
	data['contents'] =  entity.contents?.map((v) => v.toJson()).toList();
	data['hasLiked'] = entity.hasLiked;
	data['hasPaid'] = entity.hasPaid;
	data['hasCollected'] = entity.hasCollected;

	data['countComment'] = entity.countComment;
	data['collects'] = entity.collects;
	return data;
}

MediaInfoContents $MediaInfoContentsFromJson(Map<String, dynamic> json) {
	final MediaInfoContents mediaInfoContents = MediaInfoContents();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		mediaInfoContents.id = id;
	}
	final String? mediaID = jsonConvert.convert<String>(json['mediaID']??json['mediaId']);
	if (mediaID != null) {
		mediaInfoContents.mediaID = mediaID;
	}
	final int? episodeNumber = jsonConvert.convert<int>(json['episodeNumber']);
	if (episodeNumber != null) {
		mediaInfoContents.episodeNumber = episodeNumber;
	}
	final int? listenPermission = jsonConvert.convert<int>(json['listenPermission']);
	if (listenPermission != null) {
		mediaInfoContents.listenPermission = listenPermission;
	}
	final int? price = jsonConvert.convert<int>(json['price']);
	if (price != null) {
		mediaInfoContents.price = price;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		mediaInfoContents.name = name;
	}
	final String? text = jsonConvert.convert<String>(json['text']);
	if (text != null) {
		mediaInfoContents.text = text;
	}
	final String? md5 = jsonConvert.convert<String>(json['md5']);
	if (md5 != null) {
		mediaInfoContents.md5 = md5;
	}
	final String? videoUrl = jsonConvert.convert<String>(json['videoUrl']);
	if (videoUrl != null) {
		mediaInfoContents.videoUrl = videoUrl;
	}
	final List<dynamic>? urlSet = jsonConvert.convertListNotNull<dynamic>(json['urlSet']);
	if (urlSet != null) {
		mediaInfoContents.urlSet = urlSet;
	}
	final int? height = jsonConvert.convert<int>(json['height']);
	if (height != null) {
		mediaInfoContents.height = height;
	}
	final int? weight = jsonConvert.convert<int>(json['weight']);
	if (weight != null) {
		mediaInfoContents.weight = weight;
	}
	final int? mediaSize = jsonConvert.convert<int>(json['mediaSize']);
	if (mediaSize != null) {
		mediaInfoContents.mediaSize = mediaSize;
	}
	final int? playTime = jsonConvert.convert<int>(json['playTime']);
	if (playTime != null) {
		mediaInfoContents.playTime = playTime;
	}
	final int? status = jsonConvert.convert<int>(json['status']);
	if (status != null) {
		mediaInfoContents.status = status;
	}
	final bool? isActive = jsonConvert.convert<bool>(json['isActive']);
	if (isActive != null) {
		mediaInfoContents.isActive = isActive;
	}
	final bool? hasPaid = jsonConvert.convert<bool>(json['hasPaid']);
	if (hasPaid != null) {
		mediaInfoContents.hasPaid = hasPaid;
	}
	return mediaInfoContents;
}

Map<String, dynamic> $MediaInfoContentsToJson(MediaInfoContents entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['mediaID'] = entity.mediaID;
	data['episodeNumber'] = entity.episodeNumber;
	data['listenPermission'] = entity.listenPermission;
	data['price'] = entity.price;
	data['name'] = entity.name;
	data['text'] = entity.text;
	data['md5'] = entity.md5;
	data['videoUrl'] = entity.videoUrl;
	data['urlSet'] =  entity.urlSet;
	data['height'] = entity.height;
	data['weight'] = entity.weight;
	data['mediaSize'] = entity.mediaSize;
	data['playTime'] = entity.playTime;
	data['status'] = entity.status;
	data['isActive'] = entity.isActive;
	data['hasPaid'] = entity.hasPaid;
	return data;
}