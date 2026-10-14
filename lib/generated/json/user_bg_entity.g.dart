import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/user_bg_entity.dart';

UserBgEntity $UserBgEntityFromJson(Map<String, dynamic> json) {
	final UserBgEntity userBgEntity = UserBgEntity();
	final List<UserBgList>? list = jsonConvert.convertListNotNull<UserBgList>(json['list']);
	if (list != null) {
		userBgEntity.list = list;
	}
	final int? total = jsonConvert.convert<int>(json['total']);
	if (total != null) {
		userBgEntity.total = total;
	}
	return userBgEntity;
}

Map<String, dynamic> $UserBgEntityToJson(UserBgEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['list'] =  entity.list?.map((v) => v.toJson()).toList();
	data['total'] = entity.total;
	return data;
}

UserBgList $UserBgListFromJson(Map<String, dynamic> json) {
	final UserBgList userBgList = UserBgList();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		userBgList.id = id;
	}
	final String? resource = jsonConvert.convert<String>(json['resource']);
	if (resource != null) {
		userBgList.resource = resource;
	}
	final String? type = jsonConvert.convert<String>(json['type']);
	if (type != null) {
		userBgList.type = type;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updatedAt']);
	if (updatedAt != null) {
		userBgList.updatedAt = updatedAt;
	}
	return userBgList;
}

Map<String, dynamic> $UserBgListToJson(UserBgList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['resource'] = entity.resource;
	data['type'] = entity.type;
	data['updatedAt'] = entity.updatedAt;
	return data;
}