import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/my_message_entity.dart';

MyMessageEntity $MyMessageEntityFromJson(Map<String, dynamic> json) {
	final MyMessageEntity myMessageEntity = MyMessageEntity();
	final bool? hasNext = jsonConvert.convert<bool>(json['hasNext']);
	if (hasNext != null) {
		myMessageEntity.hasNext = hasNext;
	}
	final List<MyMessageList>? list = jsonConvert.convertListNotNull<MyMessageList>(json['list']);
	if (list != null) {
		myMessageEntity.list = list;
	}
	return myMessageEntity;
}

Map<String, dynamic> $MyMessageEntityToJson(MyMessageEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['hasNext'] = entity.hasNext;
	data['list'] =  entity.list?.map((v) => v.toJson()).toList();
	return data;
}

MyMessageList $MyMessageListFromJson(Map<String, dynamic> json) {
	final MyMessageList myMessageList = MyMessageList();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		myMessageList.id = id;
	}
	final int? sendUid = jsonConvert.convert<int>(json['sendUid']);
	if (sendUid != null) {
		myMessageList.sendUid = sendUid;
	}
	final String? sendName = jsonConvert.convert<String>(json['sendName']);
	if (sendName != null) {
		myMessageList.sendName = sendName;
	}
	final String? sendAvatar = jsonConvert.convert<String>(json['sendAvatar']);
	if (sendAvatar != null) {
		myMessageList.sendAvatar = sendAvatar;
	}
	final String? sendGender = jsonConvert.convert<String>(json['sendGender']);
	if (sendGender != null) {
		myMessageList.sendGender = sendGender;
	}
	final int? superUser = jsonConvert.convert<int>(json['SuperUser']);
	if (superUser != null) {
		myMessageList.superUser = superUser;
	}
	final dynamic awards = jsonConvert.convert<dynamic>(json['awards']);
	if (awards != null) {
		myMessageList.awards = awards;
	}
	final String? msgType = jsonConvert.convert<String>(json['msgType']);
	if (msgType != null) {
		myMessageList.msgType = msgType;
	}
	final String? content = jsonConvert.convert<String>(json['content']);
	if (content != null) {
		myMessageList.content = content;
	}
	final bool? isRead = jsonConvert.convert<bool>(json['isRead']);
	if (isRead != null) {
		myMessageList.isRead = isRead;
	}
	final String? objId = jsonConvert.convert<String>(json['objId']);
	if (objId != null) {
		myMessageList.objId = objId;
	}
	final String? objName = jsonConvert.convert<String>(json['objName']);
	if (objName != null) {
		myMessageList.objName = objName;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		myMessageList.createdAt = createdAt;
	}
	final String? vipExpireDate = jsonConvert.convert<String>(json['vipExpireDate']);
	if (vipExpireDate != null) {
		myMessageList.vipExpireDate = vipExpireDate;
	}
	final int? vipLevel = jsonConvert.convert<int>(json['vipLevel']);
	if (vipLevel != null) {
		myMessageList.vipLevel = vipLevel;
	}
	return myMessageList;
}

Map<String, dynamic> $MyMessageListToJson(MyMessageList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['sendUid'] = entity.sendUid;
	data['sendName'] = entity.sendName;
	data['sendAvatar'] = entity.sendAvatar;
	data['sendGender'] = entity.sendGender;
	data['SuperUser'] = entity.superUser;
	data['awards'] = entity.awards;
	data['msgType'] = entity.msgType;
	data['content'] = entity.content;
	data['isRead'] = entity.isRead;
	data['objId'] = entity.objId;
	data['objName'] = entity.objName;
	data['createdAt'] = entity.createdAt;
	data['vipExpireDate'] = entity.vipExpireDate;
	data['vipLevel'] = entity.vipLevel;
	return data;
}