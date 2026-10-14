import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/user_fan_entity.dart';

UserFanEntity $UserFanEntityFromJson(Map<String, dynamic> json) {
	final UserFanEntity userFanEntity = UserFanEntity();
	final List<UserFanList>? list = jsonConvert.convertListNotNull<UserFanList>(json['list']);
	if (list != null) {
		userFanEntity.list = list;
	}
	final bool? hasNext = jsonConvert.convert<bool>(json['hasNext']);
	if (hasNext != null) {
		userFanEntity.hasNext = hasNext;
	}
	return userFanEntity;
}

Map<String, dynamic> $UserFanEntityToJson(UserFanEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['list'] =  entity.list?.map((v) => v.toJson()).toList();
	data['hasNext'] = entity.hasNext;
	return data;
}

UserFanList $UserFanListFromJson(Map<String, dynamic> json) {
	final UserFanList userFanList = UserFanList();
	final int? uid = jsonConvert.convert<int>(json['uid']);
	if (uid != null) {
		userFanList.uid = uid;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		userFanList.name = name;
	}
	final String? gender = jsonConvert.convert<String>(json['gender']);
	if (gender != null) {
		userFanList.gender = gender;
	}
	final String? portrait = jsonConvert.convert<String>(json['portrait']);
	if (portrait != null) {
		userFanList.portrait = portrait;
	}
	final bool? hasLocked = jsonConvert.convert<bool>(json['hasLocked']);
	if (hasLocked != null) {
		userFanList.hasLocked = hasLocked;
	}
	final bool? hasBanned = jsonConvert.convert<bool>(json['hasBanned']);
	if (hasBanned != null) {
		userFanList.hasBanned = hasBanned;
	}
	final int? vipLevel = jsonConvert.convert<int>(json['vipLevel']);
	if (vipLevel != null) {
		userFanList.vipLevel = vipLevel;
	}
	final bool? isVip = jsonConvert.convert<bool>(json['isVip']);
	if (isVip != null) {
		userFanList.isVip = isVip;
	}
	final bool? hasFollow = jsonConvert.convert<bool>(json['hasFollow']);
	if (hasFollow != null) {
		userFanList.hasFollow = hasFollow;
	}
	final String? via = jsonConvert.convert<String>(json['via']);
	if (via != null) {
		userFanList.via = via;
	}
	final int? fans = jsonConvert.convert<int>(json['fans']);
	if (fans != null) {
		userFanList.fans = fans;
	}
	final int? vnum = jsonConvert.convert<int>(json['vnum']);
	if (vnum != null) {
		userFanList.vnum = vnum;
	}
	final String? summary = jsonConvert.convert<String>(json['summary']);
	if (summary != null) {
		userFanList.summary = summary;
	}
	final int? superUser = jsonConvert.convert<int>(json['superUser']);
	if (superUser != null) {
		userFanList.superUser = superUser;
	}
	final dynamic awards = jsonConvert.convert<dynamic>(json['awards']);
	if (awards != null) {
		userFanList.awards = awards;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		userFanList.createdAt = createdAt;
	}
	return userFanList;
}

Map<String, dynamic> $UserFanListToJson(UserFanList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['uid'] = entity.uid;
	data['name'] = entity.name;
	data['gender'] = entity.gender;
	data['portrait'] = entity.portrait;
	data['hasLocked'] = entity.hasLocked;
	data['hasBanned'] = entity.hasBanned;
	data['vipLevel'] = entity.vipLevel;
	data['isVip'] = entity.isVip;
	data['hasFollow'] = entity.hasFollow;
	data['via'] = entity.via;
	data['fans'] = entity.fans;
	data['vnum'] = entity.vnum;
	data['summary'] = entity.summary;
	data['superUser'] = entity.superUser;
	data['awards'] = entity.awards;
	data['createdAt'] = entity.createdAt;
	return data;
}