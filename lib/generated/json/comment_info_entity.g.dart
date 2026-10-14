import 'package:comics_app/generated/json/base/json_convert_content.dart';
import 'package:comics_app/common/entities/comment_info_entity.dart';

CommentInfoEntity $CommentInfoEntityFromJson(Map<String, dynamic> json) {
	final CommentInfoEntity commentInfoEntity = CommentInfoEntity();
	final int? total = jsonConvert.convert<int>(json['total']);
	if (total != null) {
		commentInfoEntity.total = total;
	}
	final bool? hasNext = jsonConvert.convert<bool>(json['hasNext']);
	if (hasNext != null) {
		commentInfoEntity.hasNext = hasNext;
	}
	final List<CommentInfoList>? list = jsonConvert.convertListNotNull<CommentInfoList>(json['list']);
	if (list != null) {
		commentInfoEntity.list = list;
	}
	return commentInfoEntity;
}

Map<String, dynamic> $CommentInfoEntityToJson(CommentInfoEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['total'] = entity.total;
	data['hasNext'] = entity.hasNext;
	data['list'] =  entity.list?.map((v) => v.toJson()).toList();
	return data;
}

CommentInfoList $CommentInfoListFromJson(Map<String, dynamic> json) {
	final CommentInfoList commentInfoList = CommentInfoList();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		commentInfoList.id = id;
	}
	final String? objID = jsonConvert.convert<String>(json['objID']);
	if (objID != null) {
		commentInfoList.objID = objID;
	}
	final String? cid = jsonConvert.convert<String>(json['cid']);
	if (cid != null) {
		commentInfoList.cid = cid;
	}
	final int? userID = jsonConvert.convert<int>(json['userID']);
	if (userID != null) {
		commentInfoList.userID = userID;
	}
	final String? userName = jsonConvert.convert<String>(json['userName']);
	if (userName != null) {
		commentInfoList.userName = userName;
	}
	final String? userPortrait = jsonConvert.convert<String>(json['userPortrait']);
	if (userPortrait != null) {
		commentInfoList.userPortrait = userPortrait;
	}
	final int? toUserID = jsonConvert.convert<int>(json['toUserID']);
	if (toUserID != null) {
		commentInfoList.toUserID = toUserID;
	}
	final String? toUserName = jsonConvert.convert<String>(json['toUserName']);
	if (toUserName != null) {
		commentInfoList.toUserName = toUserName;
	}
	final String? content = jsonConvert.convert<String>(json['content']);
	if (content != null) {
		commentInfoList.content = content;
	}
	final int? likeCount = jsonConvert.convert<int>(json['likeCount']);
	if (likeCount != null) {
		commentInfoList.likeCount = likeCount;
	}
	final bool? isLike = jsonConvert.convert<bool>(json['isLike']);
	if (isLike != null) {
		commentInfoList.isLike = isLike;
	}
	final bool? isAuthor = jsonConvert.convert<bool>(json['isAuthor']);
	if (isAuthor != null) {
		commentInfoList.isAuthor = isAuthor;
	}
	final bool? isFollow = jsonConvert.convert<bool>(json['isFollow']);
	if (isFollow != null) {
		commentInfoList.isFollow = isFollow;
	}
	final bool? isDelete = jsonConvert.convert<bool>(json['isDelete']);
	if (isDelete != null) {
		commentInfoList.isDelete = isDelete;
	}
	final String? gender = jsonConvert.convert<String>(json['gender']);
	if (gender != null) {
		commentInfoList.gender = gender;
	}
	final int? status = jsonConvert.convert<int>(json['status']);
	if (status != null) {
		commentInfoList.status = status;
	}
	final String? city = jsonConvert.convert<String>(json['city']);
	if (city != null) {
		commentInfoList.city = city;
	}
	final String? createdAt = jsonConvert.convert<String>(json['createdAt']);
	if (createdAt != null) {
		commentInfoList.createdAt = createdAt;
	}
	final int? age = jsonConvert.convert<int>(json['age']);
	if (age != null) {
		commentInfoList.age = age;
	}
	final int? level = jsonConvert.convert<int>(json['level']);
	if (level != null) {
		commentInfoList.level = level;
	}
	final int? vipLevel = jsonConvert.convert<int>(json['vipLevel']);
	if (vipLevel != null) {
		commentInfoList.vipLevel = vipLevel;
	}
	final dynamic awards = jsonConvert.convert<dynamic>(json['awards']);
	if (awards != null) {
		commentInfoList.awards = awards;
	}
	final int? superUser = jsonConvert.convert<int>(json['superUser']);
	if (superUser != null) {
		commentInfoList.superUser = superUser;
	}
	final String? vipExpireDate = jsonConvert.convert<String>(json['vipExpireDate']);
	if (vipExpireDate != null) {
		commentInfoList.vipExpireDate = vipExpireDate;
	}
	return commentInfoList;
}

Map<String, dynamic> $CommentInfoListToJson(CommentInfoList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['objID'] = entity.objID;
	data['cid'] = entity.cid;
	data['userID'] = entity.userID;
	data['userName'] = entity.userName;
	data['userPortrait'] = entity.userPortrait;
	data['toUserID'] = entity.toUserID;
	data['toUserName'] = entity.toUserName;
	data['content'] = entity.content;
	data['likeCount'] = entity.likeCount;
	data['isLike'] = entity.isLike;
	data['isAuthor'] = entity.isAuthor;
	data['isFollow'] = entity.isFollow;
	data['isDelete'] = entity.isDelete;
	data['gender'] = entity.gender;
	data['status'] = entity.status;
	data['city'] = entity.city;
	data['createdAt'] = entity.createdAt;
	data['age'] = entity.age;
	data['level'] = entity.level;
	data['vipLevel'] = entity.vipLevel;
	data['awards'] = entity.awards;
	data['superUser'] = entity.superUser;
	data['vipExpireDate'] = entity.vipExpireDate;
	return data;
}